## Mod's parameters management
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license


import ast, configparser, logging

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


class LinePurgeEnum(Enum):
    ORCA = "_CLEAR1"
    FF1 = "_CLEAR2"
    FF2 = "_CLEAR3"
    SCHREIDER = "_CLEAR4"
    LINE_PURGE = "LINE_PURGE"


PARAMS = [
    Parameter(
        key="auto_reboot",
        type=bool, default=0,
        label="Автоперезапуск",
        options=["отключен", "через 1.5 минуты", "прошивки через 1.5 минуты"]
    ),
    Parameter(
        key="close_dialogs",
        type=int, default=0,
        label="Диалоги",
        options=["не закрывать", "закрывать через 20 секунд (медленно)", "закрывать через 20 секунд (быстро)"]
    ),
    Parameter(
        key="disable_priming",
        type=bool, default=0,
        label="Очистка сопла",
        options=["ДА", "НЕТ"]
    ),
    Parameter(
        key="disable_screen_led",
        type=bool, default=0,
        label="Разрешать экрану управлять LED",
        options=["ДА", "НЕТ"]
    ),
    Parameter(
        key="disable_skew",
        type=bool, default=1,
        label="SKEW коррекция",
        options=["ДА", "НЕТ"]
    ),
    Parameter(
        key="fix_e0017",
        type=bool, default=1,
        label="Исправлять ошибку E0017",
        options=["НЕТ", "ДА"]
    ),
    Parameter(
        key="check_md5",
        type=bool, default=1,
        label="Проверка MD5",
        options=["НЕТ", "ДА"]
    ),
    Parameter(
        key="cell_weight",
        type=int, default=0,
        label="Разрешенный пороговый вес на тензодатчиках",
    ),
    Parameter(
        key="load_zoffset",
        type=bool, default=0,
        label="Загрузка Z-OFFSET",
        options=["НЕТ", "ДА"]
    ),
    Parameter(
        key="z_offset",
        type=float, default=0,
        label="Z-OFFSET"
    ),
    Parameter(
        key="midi_on",
        type=str, default="",
        label="MIDI при вкючении",
    ),
    Parameter(
        key="midi_start",
        type=str, default="",
        label="MIDI при запуске печати",
    ),
    Parameter(
        key="midi_end",
        type=str, default="",
        label="MIDI при завершении печати",
    ),
    Parameter(
        key="new_save_config",
        type=bool, default=0,
        label="Использовать альт. SAVE_CONFIG",
        options=["НЕТ", "ДА"]
    ),
    Parameter(
        key="preclear",
        type=bool, default=0,
        label="Предочистка сопла",
        options=["НЕТ", "ДА"]
    ),
    Parameter(
        key="print_leveling",
        type=bool, default=0,
        label="Строить карту стола",
        options=["НЕТ", "ДА"]
    ),
    Parameter(
        key="stop_motor",
        type=bool, default=1,
        label="Моторы",
        options=["Не выключать", "Выключать автоматически"]
    ),
    Parameter(
        key="use_kamp",
        type=bool, default=0,
        label="Использование KAMP",
        options=["НЕТ", "ДА"]
    ),
    Parameter(
        key="use_swap",
        type=int, default=1,
        label="SWAP",
        options=["не используется", "используется на eMMC", "используется на USB"]
    ),
    Parameter(
        key="zclear",
        type=LinePurgeEnum, default=LinePurgeEnum.ORCA,
        label="Алгоритм очистки",
    ),

    Parameter(
        key="display_off",
        type=bool, default=0,
        label="Экран отключен",
        options=["НЕТ", "ДА"],
        readonly=True
    )
]

PARAMS_DICT = {p.key: p for p in PARAMS}


class ModParamManagement:
    def __init__(self, config):
        self.loaded = False

        self.config = config
        self.printer = config.get_printer()
        self.gcode = self.printer.lookup_object("gcode")

        self.filename = self.config.get("filename")
        self.variables = dict()

        self._reload()

        self.gcode.register_command("LIST_MOD_PARAMS", self.cmd_LIST_MOD_PARAMS)
        self.gcode.register_command("RELOAD_MOD_PARAMS", self.cmd_RELOAD_MOD_PARAMS)
        self.gcode.register_command("GET_MOD_PARAM", self.cmd_GET_MOD_PARAM)
        self.gcode.register_command("SET_MOD_PARAM", self.cmd_SET_MOD_PARAM)

    def _run_gcode(self, *cmds: str):
        self.gcode.run_script_from_command("\n".join(cmds))

    def _reload(self):
        result = dict()
        parser = configparser.ConfigParser()

        try:
            parser.read(self.filename)
            if not parser.has_section("Variables"): return

            parsed = dict()
            for key, value in parser.items("Variables"):
                if key not in PARAMS_DICT:
                    logging.error(f'Read unknown parameter while parsing: "{key}"')
                    continue

                parsed[key] = ast.literal_eval(value)

            for param in PARAMS:
                key = param.key
                result[key] = self._load_param(param, parsed.get(key))

        except Exception:
            msg = "Unable to parse existing variable file:"
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

        for param in PARAMS:
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
        for param in PARAMS:
            if param.hidden: continue

            value = self._transform(param, self.variables[param.key])
            gcmd.respond_raw(self._format_label(param, value))
            if not param.readonly:
                gcmd.respond_raw(f'  --> SET_MOD_PARAM PARAM="{param.key}" VALUE={repr(value)}')

    def cmd_RELOAD_MOD_PARAMS(self, gcmd):
        self._reload()

    def cmd_GET_MOD_PARAM(self, gcmd):
        key = gcmd.get('PARAM')
        if key not in PARAMS_DICT:
            raise gcmd.error(f'Unknown parameter: "{key}"')

        param = PARAMS_DICT[key]
        transformed = self._transform(param, self.variables[key])
        gcmd.respond_raw(self._format_label(param, transformed))

    def cmd_SET_MOD_PARAM(self, gcmd):
        key = gcmd.get('PARAM')
        value = gcmd.get('VALUE')
        force = gcmd.get('FORCE', 0)

        if key not in PARAMS_DICT:
            raise gcmd.error(f'Unknown parameter: "{key}"')

        param = PARAMS_DICT[key]
        if param.readonly and not force:
            raise gcmd.error(f'Updating readonly parameter "{key}" is forbidden.')

        try:
            new_value = self._load_param(param, value)
        except:
            raise gcmd.error(f'Failed to update parameter "{key}" with value: "{value}"')

        if new_value != self.variables[key]:
            self.variables[key] = new_value
            self._save_all()

        if not param.hidden:
            transformed = self._transform(param, self.variables[key])
            gcmd.respond_raw("SET: " + self._format_label(param, transformed))

    def get_status(self, _):
        return {'variables': self.variables}


def load_config(config):
    return ModParamManagement(config)
