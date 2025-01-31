## Mod's parameters management
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license


import ast, configparser, logging
import json

from dataclasses import dataclass
from enum import Enum
from typing import List, Any, Dict, Type, Union, Optional


@dataclass
class Parameter:
    key: str
    type: Type
    default: Any
    label: str
    options: Union[List[str], Dict[Any, str], None] = None
    readonly: bool = False
    hidden: bool = False
    order: int = 0


class ModParamManagement:
    def __init__(self, config):
        self.loaded = False

        self.config = config
        self.printer = config.get_printer()
        self.gcode = self.printer.lookup_object("gcode")

        self.declaration = self.config.get("declaration")
        self.filename = self.config.get("filename")
        self.variables = dict()

        self.reactor = self.printer.get_reactor()
        gcode_macro = self.printer.load_object(config, "gcode_macro")
        self.changes_gcode_present = config.get("changes_gcode", None) is not None
        if self.changes_gcode_present:
            self.changes_template = gcode_macro.load_template(config, "changes_gcode")

        self.params: List[Parameter] = list()
        self.params_map: Dict[str, Parameter] = dict()
        self.type_mapping: Dict[str, Type] = dict()

        self._load_declaration()
        self._reload()

        self.gcode.register_command("LIST_MOD_PARAMS", self.cmd_LIST_MOD_PARAMS)
        self.gcode.register_command("RELOAD_MOD_PARAMS", self.cmd_RELOAD_MOD_PARAMS)
        self.gcode.register_command("GET_MOD_PARAM", self.cmd_GET_MOD_PARAM)
        self.gcode.register_command("SET_MOD_PARAM", self.cmd_SET_MOD_PARAM)

    def _run_gcode(self, *cmds: str):
        self.gcode.run_script_from_command("\n".join(cmds))

    def _load_declaration(self):
        try:
            with open(self.declaration, 'r', encoding="utf-8") as file:
                data = json.load(file)
        except:
            msg = "Unable to load declaration file."
            logging.exception(msg)
            raise self.printer.command_error(msg)

        self.type_mapping = {
            "bool": bool,
            "int": int,
            "float": float,
            "str": str
        }

        for enum_name, enum_data in data.get("enums", {}).items():
            if enum_name in self.type_mapping:
                logging.error(f'[mod_params]: Type "{enum_name}" already exists!')
                continue

            new_enum = self._create_enum_from_json(enum_name, enum_data)
            self.type_mapping[enum_name] = new_enum

        params = []
        for param_data in sorted(data["parameters"], key=lambda p: [p.get("order", 0), p.get("label", "")]):
            param_type = self.type_mapping.get(param_data['type'])
            if not param_type:
                logging.error(f'[mod_params]: Parameter "{param_data["key"]}" has wrong type "{param_data["type"]}"!')
                continue

            # Handle enum default values
            if issubclass(param_type, Enum):
                param_data["default"] = param_type[param_data["default"]]

            param = Parameter(
                key=param_data["key"],
                type=param_type,
                default=param_data["default"],
                label=param_data["label"],
                options=param_data.get("options"),
                readonly=param_data.get("readonly", False),
                hidden=param_data.get("hidden", False),
                order=param_data.get("order", 0)
            )
            params.append(param)

        self.params = params
        self.params_map = {p.key: p for p in params}

    def _create_enum_from_json(self, enum_name: str, enum_data: Dict[str, Any]) -> Type[Enum]:
        try:
            return Enum(enum_name, enum_data["values"])
        except:
            msg = f'Unable to build enum {enum_name} from declaration file.'
            logging.exception(msg)
            raise self.printer.command_error(msg)

    def _reload(self):
        result = dict()
        parser = configparser.ConfigParser()

        try:
            parser.read(self.filename)
            if not parser.has_section("Variables"): return

            parsed = dict()
            for key, value in parser.items("Variables"):
                if key not in self.params_map:
                    logging.error(f'[mod_params]: Read unknown parameter while parsing: "{key}"')
                    continue

                parsed[key] = ast.literal_eval(value)

            for param in self.params:
                key = param.key
                result[key] = self._load_param(param, parsed.get(key))

        except Exception:
            msg = "Unable to parse existing variable file."
            logging.exception(msg)
            raise self.printer.command_error(msg)

        self.variables = result

    def _load_param(self, param: Parameter, value: Optional[str]):
        if issubclass(param.type, Enum):
            return param.type[value.strip()].value if value is not None else param.default.value

        if param.type == bool:
            return param.type(int(value)) if value is not None else param.default

        return param.type(value) if value is not None else param.default

    def _transform(self, param: Parameter, value: Optional[Any]):
        if issubclass(param.type, Enum):
            return param.type(value).name if value is not None else param.default.name

        elif param.type == bool:
            return int(value if value is not None else param.default)

        return value if value is not None else param.default

    def _save_all(self):
        parser = configparser.ConfigParser()
        parser.add_section("Variables")

        for param in self.params:
            value = self.variables.get(param.key)
            value_to_save = self._transform(param, value)
            parser.set("Variables", param.key, repr(value_to_save))

        try:
            with open(self.filename, "w") as f:
                parser.write(f)

        except:
            msg = "Unable to save variable"
            logging.exception(msg)
            raise self.gcode.error(msg)

    def _format_label(self, param: Parameter, value: Any):
        if param.options:
            return f'{param.label}: {param.options[value]}'

        return f'{param.label}: {value}'

    def cmd_LIST_MOD_PARAMS(self, gcmd):
        for param in self.params:
            if param.hidden: continue

            value = self._transform(param, self.variables[param.key])
            gcmd.respond_raw(self._format_label(param, value))
            if issubclass(param.type, Enum):
                gcmd.respond_raw(f'  // {[value.name for value in param.type]}')
            if not param.readonly:
                gcmd.respond_raw(f'  --> SET_MOD_PARAM PARAM="{param.key}" VALUE={repr(value)}')

    def cmd_RELOAD_MOD_PARAMS(self, _):
        self._reload()

    def cmd_GET_MOD_PARAM(self, gcmd):
        key = gcmd.get('PARAM')
        if key not in self.params_map:
            raise gcmd.error(f'Unknown parameter: "{key}"')

        param = self.params_map[key]
        transformed = self._transform(param, self.variables[key])
        gcmd.respond_raw(self._format_label(param, transformed))

    def cmd_SET_MOD_PARAM(self, gcmd):
        key = gcmd.get('PARAM')
        value = gcmd.get('VALUE')
        force = gcmd.get('FORCE', 0)

        if key not in self.params_map:
            raise gcmd.error(f'Unknown parameter: "{key}"')

        param = self.params_map[key]
        if param.readonly and not force:
            raise gcmd.error(f'Updating readonly parameter "{key}" is forbidden.')

        try:
            new_value = self._load_param(param, value)
        except:
            raise gcmd.error(f'Failed to update parameter "{key}" with value: "{value}"')

        if new_value != self.variables[key]:
            self.variables[key] = new_value
            self._save_all()

            if self.changes_gcode_present:
                self.reactor.register_callback(lambda _, __param=param: self._notify_changed(__param))

        if not param.hidden:
            transformed = self._transform(param, self.variables[key])
            gcmd.respond_raw("SET: " + self._format_label(param, transformed))

    def _notify_changed(self, param: Parameter):
        context = self.changes_template.create_template_context()

        key = param.key
        value = self.variables[key]

        context["changes"] = {
            "key": key,
            "value": self._transform(param, self.variables[key]),
            "raw": value,
        }

        template = self.changes_template.render(context)

        try:
            self.gcode.run_script(template)
        except:
            logging.exception(f"mod_params: Script running error:\n{template}")

    def get_status(self, _):
        return {'variables': self.variables}


def load_config(config):
    return ModParamManagement(config)
