## Configuration backup and restore
##
## Copyright (C) 2025 Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

import argparse
import os.path
import re
import sys

from abc import ABC, abstractmethod
from copy import deepcopy
from enum import Enum
from typing import Optional, Dict, Self, Iterable

PARAM_WILDCARD = "*"
VERBOSE = False


## Backup configuration
##########################################################################

class Action(Enum):
    ADD = '+'
    REMOVE = '-'


class NameEqualable(ABC):
    @property
    @abstractmethod
    def name(self):
        return NotImplemented

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return self.name == other.name
        return NotImplemented

    def __lt__(self, other):
        if isinstance(other, self.__class__):
            return self.name < other.name
        return NotImplemented

    def __hash__(self):
        return self.name.__hash__()


class ParameterConfiguration(NameEqualable):
    def __init__(self, name: str, action: Action):
        self._name = name
        self._action = action

    @property
    def name(self):
        return self._name

    @property
    def action(self):
        return self._action


class SectionConfiguration(NameEqualable):
    def __init__(self, section_name):
        self._name = section_name
        self._parameters: Dict[str, ParameterConfiguration] = {}

    @property
    def name(self):
        return self._name

    @property
    def parameters(self) -> Iterable[ParameterConfiguration]:
        return self._parameters.values()

    def add(self, parameter: ParameterConfiguration):
        if parameter.name in self._parameters:
            raise ValueError(f"Section {self.name}: Parameter already exists {parameter.name!r}")

        self._parameters[parameter.name] = parameter

    def contains(self, param_name: str) -> bool:
        return self.action(param_name) is not None

    def action(self, param_name: str) -> Optional[Action]:
        param = self._parameters.get(param_name, None)
        if param is not None:
            return param.action

        param = self._parameters.get(PARAM_WILDCARD, None)
        if param is not None:
            return param.action

        return None


class Configuration:
    def __init__(self):
        self._sections: Dict[str, SectionConfiguration] = dict()

    @property
    def sections(self) -> Iterable[SectionConfiguration]:
        return self._sections.values()

    def start_section(self, section_name: str) -> SectionConfiguration:
        section = self._sections.get(section_name, None)
        if not section:
            section = SectionConfiguration(section_name)
            self._sections[section_name] = section

        return section

    def contains(self, section_name: str, *, param_name: Optional[str] = None) -> bool:
        if param_name:
            return self.action(section_name, param_name) is not None
        return section_name in self._sections

    def action(self, section_name: str, param_name: str) -> Optional[Action]:
        section = self._sections.get(section_name, None)
        return section.action(param_name) if section else None

    def is_saving(self, section_name, *, param_name: Optional[str] = None) -> bool:
        section = self._sections.get(section_name, None)
        if section is None:
            return False

        if param_name is not None:
            return section.action(param_name) == Action.ADD

        return any(param.action == Action.ADD for param in section.parameters)

    def is_removing(self, section_name, *, param_name: Optional[str] = None) -> bool:
        section = self._sections.get(section_name, None)
        if section is None:
            return False

        if param_name is not None:
            return section.action(param_name) == Action.REMOVE

        return all(param.action == Action.REMOVE for param in section.parameters)

    def print(self):
        for section in self.sections:
            params = list(section.parameters)
            if len(params) == 1 and section.contains(PARAM_WILDCARD):
                print(f"{'Save' if section.action(PARAM_WILDCARD) == Action.ADD else 'Remove'} entire section {section.name!r}")
                continue

            print(f"Section {section.name}")
            for param in params:
                print(f"\t {'Save' if param.action == Action.ADD else 'Remove'} "
                      f"{param.name if param.name != PARAM_WILDCARD else '<others>'}")


class ConfigurationBuilder:
    class _SectionBuilder:
        def __init__(self, config_builder, section: SectionConfiguration):
            self._config_builder = config_builder
            self._section = section

        @property
        def section(self):
            return self._section

        def add_wildcard(self, action: Action = Action.ADD) -> Self:
            self.add(PARAM_WILDCARD, action)
            return self

        def add(self, name: str, action: Action = Action.ADD) -> Self:
            try:
                self._section.add(ParameterConfiguration(name, action))
            except ValueError as e:
                print(f"Error: {e}", file=sys.stderr)
                self._config_builder._has_errors = True

            return self

        def start_section(self, name: str):
            return self._config_builder.start_section(name)

        def build(self) -> Configuration:
            return self._config_builder.build()

    def __init__(self):
        self._config = Configuration()
        self._has_errors = False

    @property
    def has_errors(self):
        return self._has_errors

    def start_section(self, name: str) -> _SectionBuilder:
        return self._SectionBuilder(self, self._config.start_section(name))

    def build(self) -> Configuration:
        return self._config


## Printer's configuration parsing
##########################################################################

SECTION_RE = re.compile(r"^\[(\w+)(?:\s*(\w+))?]$")
PARAMETER_RE = re.compile(r"^(\w+)\s*[=:]\s*(.+)$")


class CfgToken(Enum):
    SECTION = 1
    PARAMETER = 2
    COMMENT = 3
    BREAK = 4
    OTHER = 5  # multi-line params, etc


def iterate_printer_config_tokens(file_path, *, callback):
    with open(file_path, "r") as in_f:
        for line in in_f:
            s_line = line.strip()

            if s_line.startswith('#'):
                callback(CfgToken.COMMENT, line=s_line)
            elif len(s_line) == 0:
                callback(CfgToken.BREAK, line="")
            elif m := SECTION_RE.match(s_line):
                if m.group(2):
                    callback(CfgToken.SECTION, line=s_line, type=m.group(1), key=m.group(2).strip())
                else:
                    callback(CfgToken.SECTION, line=s_line, key=m.group(1))
            elif m := PARAMETER_RE.match(s_line):
                callback(CfgToken.PARAMETER, line=s_line, key=m.group(1), value=m.group(2))
            else:
                callback(CfgToken.OTHER, line=line)


## Backup/Restore configuration parsing
##########################################################################

PARAMETER_ADD_RE = re.compile(r"^(\[\w+\s*(?:\w+)?])\s+(\w+)\s*(?:#.*)?$")
PARAMETER_REMOVE_RE = re.compile(r"^-\s*(\[\w+\s*(?:\w+)?])\s+(\w+)\s*(?:#.*)?$")
SECTION_ADD_RE = re.compile(r"^(\[\w+\s*(?:\w+)?])\s*(?:#.*)?$")
SECTION_REMOVE_RE = re.compile(r"^-\s*(\[\w+\s*(?:\w+)?])\s*(?:#.*)?$")


class ParametersToken(Enum):
    SECTION_PARAMETER_ADD = 1
    SECTION_PARAMETER_REMOVE = 2
    SECTION_ADD = 3
    SECTION_REMOVE = 4
    COMMENT = 5


def iterate_cmd_config_tokens(file_path, *, callback):
    with open(file_path, "r") as in_file:
        for line in in_file:
            s_line = line.strip()

            if len(s_line) == 0:
                continue
            elif s_line.startswith('#'):
                callback(ParametersToken.COMMENT, line=s_line)
            elif m := PARAMETER_ADD_RE.match(s_line):
                callback(ParametersToken.SECTION_PARAMETER_ADD, line=s_line, section=m.group(1), parameter=m.group(2))
            elif m := PARAMETER_REMOVE_RE.match(s_line):
                callback(ParametersToken.SECTION_PARAMETER_REMOVE,
                         line=s_line, section=m.group(1), parameter=m.group(2))
            elif m := SECTION_ADD_RE.match(s_line):
                callback(ParametersToken.SECTION_ADD, line=s_line, section=m.group(1))
            elif m := SECTION_REMOVE_RE.match(s_line):
                callback(ParametersToken.SECTION_REMOVE, line=s_line, section=m.group(1))
            else:
                print(f"Warning: Invalid parameter line: {s_line}", file=sys.stderr)


## Parameters configuration loading
##########################################################################

def parse_cmd_configuration(file_path) -> Configuration:
    builder = ConfigurationBuilder()

    def _callback(token, line, **kwargs):
        if token == ParametersToken.SECTION_PARAMETER_ADD:
            builder.start_section(kwargs["section"]).add(kwargs["parameter"], Action.ADD)
        elif token == ParametersToken.SECTION_PARAMETER_REMOVE:
            builder.start_section(kwargs["section"]).add(kwargs["parameter"], Action.REMOVE)
        elif token == ParametersToken.SECTION_ADD:
            builder.start_section(kwargs["section"]).add_wildcard(Action.ADD)
        elif token == ParametersToken.SECTION_REMOVE:
            builder.start_section(kwargs["section"]).add_wildcard(Action.REMOVE)

    print(f"Loading parameters from \"{file_path}\"...")
    iterate_cmd_config_tokens(file_path, callback=_callback)

    new_config = builder.build()

    if VERBOSE:
        print("\nLoaded configuration:")
        new_config.print()
        print()

    for section in new_config.sections:
        wildcard_action = section.action(PARAM_WILDCARD)
        if wildcard_action is not None:
            if any(p.action == wildcard_action and p.name != PARAM_WILDCARD for p in section.parameters):
                print(f"Warning: Section {section.name!r} has redundant named rule(s) since it already contains "
                      f"{PARAM_WILDCARD!r} with same action {wildcard_action.name!r}", file=sys.stderr)

    # print(f"Warning: Section {self.name!r} adding {parameter.name!r}, "
    #       f"configuration contains both {PARAM_WILDCARD!r} and named parameters", file=sys.stderr)

    sys.stdout.flush()
    sys.stderr.flush()

    if builder.has_errors:
        print("Parameters configuration has errors. Exit.", file=sys.stderr)
        exit(6)

    return new_config


## Backup command implementation
##########################################################################

def backup(file_path, dst_path, dry=False):
    print(f"Parsing config \"{file_path}\"...")

    tmp_path = dst_path + ".tmp"
    with (open(tmp_path, "w") as out_f):
        empty = True
        section_key = None

        def _callback(token, line, **kwargs):
            nonlocal section_key, empty

            if token == CfgToken.SECTION and PARAMETERS.is_saving(line):
                section_key = line
                out_f.write(section_key + "\n")
                if VERBOSE: print(f"Section: {section_key}")
            elif token == CfgToken.PARAMETER and PARAMETERS.is_saving(section_key, param_name=kwargs["key"]):
                out_f.write(line + "\n")
                empty = False
                if VERBOSE: print(f"  - {line}")
            elif token in {CfgToken.BREAK, CfgToken.SECTION}:
                section_key = None

        iterate_printer_config_tokens(file_path, callback=_callback)

    if empty:
        print("Unable to find any parameters in config. Backup not created\n", file=sys.stderr)
        exit(3)

    if not dry:
        os.rename(tmp_path, dst_path)
        print(f"\nBackup created: \"{dst_path}\"")
    else:
        print(f"\nTemporary backup created: \"{tmp_path}\"")

    print("\nDone!")


## Restore command implementation
##########################################################################

def load_backup(file_path):
    print(f"Parsing backup \"{file_path}\"...")

    result = dict()
    section: Optional[Dict[str, dict]] = None
    section_name: Optional[str] = None

    def _parse_data(token, line, **kwargs):
        nonlocal result, section, section_name
        if token == CfgToken.SECTION and PARAMETERS.is_saving(line):
            section_name = line
            if section_name not in result: result[section_name] = dict()
            section = result[section_name]
            if VERBOSE: print(f"Loaded section: {section_name}")
        elif token == CfgToken.PARAMETER and section_name and PARAMETERS.is_saving(section_name, param_name=kwargs["key"]):
            section[kwargs["key"]] = kwargs["value"]
            if VERBOSE: print(f"  - Load Parameter {kwargs['key']}")
        elif token in {CfgToken.BREAK or CfgToken.SECTION}:
            section = None
            section_name = None

    iterate_printer_config_tokens(file_path, callback=_parse_data)

    if all(len(d) == 0 for d in result.values()):
        print("Backup file doesn't contains any properties", file=sys.stderr)
        exit(4)

    return result


def restore(file_path, saved_data, dry=False):
    print(f"Restoring config \"{file_path}\"...\n")

    file_changed = False
    tmp_path = file_path + ".tmp"

    data = deepcopy(saved_data)

    with open(tmp_path, "w") as out_f:
        section_data: Dict[str, Dict[str, str]] | None = None
        section_name: Optional[str] = None
        last_token: Optional[CfgToken] = None

        def _parse_config(token, line, **kwargs):
            nonlocal file_changed, data, section_data, section_name, last_token
            should_write_src_line = True

            # Process section switch
            if token == CfgToken.BREAK or token == CfgToken.SECTION:
                if section_data is not None:
                    for key, value in section_data.items():
                        out_f.write(f"{key}: {value}\n")
                        print(f"Added {section_name} {key}: <-- {value}")
                        file_changed = True

                    del data[section_name]

                section_data = None
                section_name = line if token == CfgToken.SECTION else None

            # Process removed sections/parameters
            if token == CfgToken.SECTION and PARAMETERS.is_removing(section_name):
                should_write_src_line = False
                file_changed = True
                print(f"Deleted {section_name}")
            elif token == CfgToken.PARAMETER and PARAMETERS.is_removing(section_name, param_name=kwargs["key"]):
                should_write_src_line = False
                file_changed = True
                print(f"Deleted {section_name} {kwargs['key']}")

            # Process saved sections/parameters
            elif token == CfgToken.SECTION and section_name in data:
                section_data = data[section_name]
            elif token == CfgToken.PARAMETER and section_data and kwargs["key"] in section_data:
                prop = kwargs["key"]
                actual_value = kwargs["value"]
                saved_value = section_data[prop]
                del section_data[prop]

                if actual_value != saved_value:
                    out_f.write(f"{prop}: {saved_value}\n")
                    should_write_src_line = False
                    file_changed = True
                    print(f"Restored {section_name} {prop}: {actual_value} <-- {saved_value}")
                elif VERBOSE:
                    print(f"Not Changed {section_name} {prop}: {actual_value}")

            last_token = token
            if should_write_src_line:
                out_f.write(line + "\n")

        iterate_printer_config_tokens(file_path, callback=_parse_config)

        # Add missing sections/props
        for name, section_data in data.items():
            if len(section_data) == 0:
                continue

            # Check if previous (only) section has unprocessed parameters
            if section_name != name:
                out_f.write(f"\n{name}\n")
                print(f"Added Section {section_name}")

            section_name = None

            for prop_key, prop_value in section_data.items():
                out_f.write(f"{prop_key}: {prop_value}\n")
                file_changed = True
                print(f"Added {name} {prop_key}: <-- {prop_value}")

    if not file_changed:
        print("Config doesn't contains changed properties!")
        return

    if not dry:
        print(f"Update config \"{file_path}\"")
        os.rename(tmp_path, file_path)

    print("\nDone!")


def has_changes(file_path, saved_data):
    print(f"Verifying config \"{file_path}\"...\n")

    file_changed = False
    data = deepcopy(saved_data)

    section_data: Dict[str, Dict[str, str]] | None = None
    section_name: Optional[str] = None

    def _parse_config(token, line, **kwargs):
        nonlocal data, file_changed, section_data, section_name

        # Process section switch
        if token == CfgToken.BREAK or token == CfgToken.SECTION:
            if section_data is not None:
                for key, value in section_data.items():
                    file_changed = True
                    print(f"To add {section_name} {key}: <-- {value}")

                del data[section_name]

            section_data = None
            section_name = line if token == CfgToken.SECTION else None

        # Process removed sections/parameters
        if token == CfgToken.SECTION and PARAMETERS.is_removing(section_name):
            file_changed = True
            print(f"To delete section {section_name}")
        elif token == CfgToken.PARAMETER and PARAMETERS.is_removing(section_name, param_name=kwargs["key"]):
            file_changed = True
            print(f"To delete {section_name} {kwargs['key']}")

        # Process saved sections/parameters
        elif token == CfgToken.SECTION and section_name in data:
            section_data = data[section_name]
        elif token == CfgToken.PARAMETER and section_data and kwargs["key"] in section_data:
            prop = kwargs["key"]
            actual_value = kwargs["value"]
            saved_value = section_data[prop]
            del section_data[prop]

            if actual_value != saved_value:
                print(f"To restore {section_name} {prop}: {actual_value} <-- {saved_value}")
                file_changed = True
            elif VERBOSE:
                print(f"Not Changed {section_name} {prop}: {actual_value}")

    iterate_printer_config_tokens(file_path, callback=_parse_config)

    # Check missing sections/props
    for name, section_data in data.items():
        if len(section_data) == 0:
            continue

        if section_name != name:
            print(f"To add section {name}")

        section_name = None

        for prop_key, prop_value in section_data.items():
            file_changed = True
            print(f"To add {name} {prop_key}: <-- {prop_value}")

    return file_changed


# @formatter:off
PARAMETERS = (
    ConfigurationBuilder()
        .start_section("[stepper_x ]")
            .add("rotation_distance")
        .start_section("[stepper_y]")
            .add("rotation_distance")
        .start_section("[stepper_z]")
            .add("rotation_distance")
        .build()
)
# @formatter:on

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Printer configuration backup & restore script")

    parser.add_argument("-c", "--config", type=str,
                        help="Path to printer configuration",
                        default="/opt/config/printer.base.cfg")
    parser.add_argument("-d", "--data", type=str,
                        help="Path to saved printer values",
                        default="/opt/config/printer.base.cfg.bak")
    parser.add_argument("-p", "--params", type=str,
                        help="Path to backup parameters configuration file", )
    parser.add_argument("-m", "--mode", type=str,
                        choices=["backup", "restore", "verify"],
                        help="Mode: (backup, restore, verify)")
    parser.add_argument("-w", "--avoid_writes", action="store_true",
                        help="Avoid additional writes to disk", default=False)
    parser.add_argument("--dry", action="store_true",
                        help='Dry run', default=False)
    parser.add_argument("--verbose", action="store_true",
                        help='Dry run', default=False)

    args = parser.parse_args()

    config_path = args.config
    data_path = args.data
    mode = args.mode
    dry_run = args.dry
    params_path = args.params
    VERBOSE = args.verbose
    avoid_writes = args.avoid_writes

    if not os.path.isfile(config_path):
        print(f"Config file doesn't exists: \"{config_path}\"\n", file=sys.stderr)
        exit(2)

    if params_path and not os.path.isfile(params_path):
        print(f"Parameters file doesn't exists: \"{params_path}\"\n", file=sys.stderr)
        exit(2)

    if params_path:
        PARAMETERS = parse_cmd_configuration(params_path)
        print()

    if len(list(PARAMETERS.sections)) == 0:
        print(f"Parameters list is empty!\n", file=sys.stderr)
        exit(5)

    if mode == "backup":
        backup(config_path, data_path, dry_run)
    elif mode == "restore":
        if not os.path.isfile(data_path):
            print(f"Backup file doesn't exists: \"{data_path}\"\n", file=sys.stderr)
            exit(2)

        backup_data = load_backup(data_path)
        if not avoid_writes or has_changes(config_path, backup_data):
            restore(config_path, backup_data, dry_run)
        else:
            print("Config doesn't contains changed properties!")
    elif mode == "verify":
        backup_data = load_backup(data_path)
        if has_changes(config_path, backup_data):
            print("Config changed!")
            exit(1)

        print("Config doesn't contains changed properties!")
    else:
        parser.print_help(sys.stderr)
        exit(1)
