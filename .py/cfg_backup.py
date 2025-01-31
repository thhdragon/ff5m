## Configuration backup and restore
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

import argparse
import os.path
import re
import sys

from abc import ABC, abstractmethod
from copy import deepcopy
from dataclasses import dataclass
from enum import Enum
from typing import Optional, Dict, Self, Iterable, Tuple, Set

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
        self._includes: Dict[str, Action] = dict()

    @property
    def sections(self) -> Iterable[SectionConfiguration]:
        return self._sections.values()

    @property
    def includes(self) -> Iterable[Tuple[str, Action]]:
        return self._includes.items()

    def start_section(self, section_name: str) -> SectionConfiguration:
        section = self._sections.get(section_name, None)
        if not section:
            section = SectionConfiguration(section_name)
            self._sections[section_name] = section

        return section

    def add_include(self, path: str, action: Action):
        if path in self._includes:
            raise ValueError(f"Include {path!r} already exists")

        self._includes[path] = action

    def include_action(self, path: str) -> Optional[Action]:
        return self._includes.get(path, None)

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

        if section.action(PARAM_WILDCARD) == Action.REMOVE:
            return not any(param.action != Action.REMOVE for param in section.parameters)

        return False

    def print(self):
        for path, action in self.includes:
            print(f"Include {'Add' if action == Action.ADD else 'Remove'} {path!r}")

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

    def include(self, path: str, action: Action = Action.ADD) -> Self:
        self._config.add_include(path, action)
        return self

    def start_section(self, name: str) -> _SectionBuilder:
        return self._SectionBuilder(self, self._config.start_section(name))

    def build(self) -> Configuration:
        return self._config


## Printer's configuration parsing
##########################################################################

INCLUDE_PATH_SYMBOLS = "a-zA-Z0-9./_"

INCLUDE_RE = re.compile(r"^\[include\s*([" + INCLUDE_PATH_SYMBOLS + r"]+)]$")
SECTION_RE = re.compile(r"^\[(\w+)(?:\s*(\w+))?]$")
PARAMETER_RE = re.compile(r"^(\w+)\s*[=:]\s*(.+)$")
AUTOGENERATED_BLOCK_RE = re.compile(r"^#\*#\s*<-+\s*SAVE_CONFIG\s*-+>\s*$")


class CfgToken(Enum):
    INCLUDE = 1
    SECTION = 2
    PARAMETER = 3
    COMMENT = 4
    BREAK = 5
    EDITABLE_BLOCK_END = 6
    OTHER = 7  # multi-line params, etc


def iterate_printer_config_tokens(file_path, *, callback):
    with open(file_path, "r") as in_f:
        editable_block_ends = False
        for line in in_f:
            s_line = line.strip()

            if s_line.startswith('#'):
                if not editable_block_ends and AUTOGENERATED_BLOCK_RE.match(s_line):
                    callback(CfgToken.EDITABLE_BLOCK_END, line=s_line)
                    editable_block_ends = True
                else:
                    callback(CfgToken.COMMENT, line=s_line)
            elif len(s_line) == 0:
                callback(CfgToken.BREAK, line="")
            elif m := INCLUDE_RE.match(s_line):
                callback(CfgToken.INCLUDE, line=s_line, path=m.group(1))
            elif m := SECTION_RE.match(s_line):
                if m.group(2):
                    callback(CfgToken.SECTION, line=s_line, type=m.group(1), key=m.group(2).strip())
                else:
                    callback(CfgToken.SECTION, line=s_line, key=m.group(1))
            elif m := PARAMETER_RE.match(s_line):
                callback(CfgToken.PARAMETER, line=s_line, key=m.group(1), value=m.group(2))
            else:
                callback(CfgToken.OTHER, line=line)

        if not editable_block_ends:
            callback(CfgToken.EDITABLE_BLOCK_END, line="")


## Backup/Restore configuration parsing
##########################################################################

PARAMETER_ADD_RE = re.compile(r"^(\[\w+\s*(?:\w+)?])\s+(\w+)\s*(?:#.*)?$")
PARAMETER_REMOVE_RE = re.compile(r"^-\s*(\[\w+\s*(?:\w+)?])\s+(\w+)\s*(?:#.*)?$")
SECTION_ADD_RE = re.compile(r"^(\[\w+\s*(?:\w+)?])\s*(?:#.*)?$")
SECTION_REMOVE_RE = re.compile(r"^-\s*(\[\w+\s*(?:\w+)?])\s*(?:#.*)?$")
INCLUDE_ADD_RE = re.compile(r"^\[include \s*([" + INCLUDE_PATH_SYMBOLS + r"]+)]\s*(?:#.*)?$")
INCLUDE_REMOVE_RE = re.compile(r"^-\s*\[include \s*([" + INCLUDE_PATH_SYMBOLS + r"]+)]\s*(?:#.*)?$")


class ParametersToken(Enum):
    SECTION_PARAMETER_ADD = 1
    SECTION_PARAMETER_REMOVE = 2
    INCLUDE_ADD = 3
    INCLUDE_REMOVE = 4
    SECTION_ADD = 5
    SECTION_REMOVE = 6
    COMMENT = 7


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
            elif m := INCLUDE_ADD_RE.match(s_line):
                callback(ParametersToken.INCLUDE_ADD, line=s_line, path=m.group(1))
            elif m := INCLUDE_REMOVE_RE.match(s_line):
                callback(ParametersToken.INCLUDE_REMOVE, line=s_line, path=m.group(1))
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

    def _callback(token, **kwargs):
        if token == ParametersToken.SECTION_PARAMETER_ADD:
            builder.start_section(kwargs["section"]).add(kwargs["parameter"], Action.ADD)
        elif token == ParametersToken.SECTION_PARAMETER_REMOVE:
            builder.start_section(kwargs["section"]).add(kwargs["parameter"], Action.REMOVE)
        elif token == ParametersToken.SECTION_ADD:
            builder.start_section(kwargs["section"]).add_wildcard(Action.ADD)
        elif token == ParametersToken.SECTION_REMOVE:
            builder.start_section(kwargs["section"]).add_wildcard(Action.REMOVE)
        elif token == ParametersToken.INCLUDE_ADD:
            builder.include(kwargs["path"], Action.ADD)
        elif token == ParametersToken.INCLUDE_REMOVE:
            builder.include(kwargs["path"], Action.REMOVE)

    print(f"Loading parameters from \"{file_path}\"...")
    iterate_cmd_config_tokens(file_path, callback=_callback)

    new_config = builder.build()

    if VERBOSE:
        print("\nLoaded configuration:")
        new_config.print()
        print()

    for section in new_config.sections:
        if (wildcard_action := section.action(PARAM_WILDCARD)) is not None \
                and any(p.action == wildcard_action and p.name != PARAM_WILDCARD for p in section.parameters):
            print(f"Warning: Section {section.name!r} has redundant named rule(s) "
                  f"since it already contains {PARAM_WILDCARD!r} "
                  f"with same action {wildcard_action.name!r}", file=sys.stderr)

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


## Auxiliary restore classes
##########################################################################

@dataclass
class RestoreState:
    @dataclass
    class SectionState:
        name: str
        data: Dict[str, str] | None = None

    data: Dict[str, Dict[str, str]]
    includes: Set[str]

    is_changed = False
    is_end = False
    current_section: Optional[SectionState] = None

    def load_section(self, section_name: str):
        self.current_section = self.SectionState(section_name, self.data.get(section_name))

    def pop_saved_value(self, param_name: str):
        if not self.current_section: raise Exception("Section not selected!")
        return self.current_section.data.pop(param_name)

    def pop_include(self, include_path: str):
        self.includes.remove(include_path)
        return include_path

    def has_section_data(self, param_name: str):
        if not self.current_section or not self.current_section.data: return False
        return param_name in self.current_section.data

    def is_saving(self, *, param_name: Optional[str] = None):
        if not self.current_section: raise Exception("Section not selected!")
        return PARAMETERS.is_saving(self.current_section.name, param_name=param_name)

    def is_removing(self, *, param_name: Optional[str] = None):
        if not self.current_section: raise Exception("Section not selected!")
        return PARAMETERS.is_removing(self.current_section.name, param_name=param_name)

    def mark_parameter_used(self, param_name: str):
        if not self.current_section or self.current_section.data is None:
            raise Exception(f"Trying to mark used parameter {param_name!r} without section selected")
        elif param_name not in self.current_section:
            raise Exception(f"Trying to mark used non-existing section's ${self.current_section.name!r} parameter {param_name!r}")

        del self.current_section.data[param_name]

    def mark_section_used(self):
        if not self.current_section: raise Exception("Trying to mark used empty section!")
        del self.data[self.current_section.name]
        self.current_section = None


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

    return result


## Restore command implementation
##########################################################################

def restore(file_path, saved_data, dry=False):
    print(f"Restoring config \"{file_path}\"...\n")

    tmp_path = file_path + ".tmp"
    state = RestoreState(
        data=deepcopy(saved_data),
        includes={inc for inc, act in PARAMETERS.includes if act == Action.ADD}
    )

    def _handle_section_end(section):
        if section.data is None: return

        for key, value in section.data.items():
            out_f.write(f"{key}: {value}\n")
            state.is_changed = True
            print(f"Added {state.current_section.name} {key}: <-- {value}")

        state.mark_section_used()

    with open(tmp_path, "w") as out_f:
        def _parse_config(token, line, **kwargs):
            should_write_src_line = True

            if state.is_end and token in {CfgToken.SECTION, CfgToken.PARAMETER, CfgToken.INCLUDE}:
                print(f"Warning: read token {token.name!r} after end of editable file part: {kwargs}", file=sys.stderr)

            # Process section switch
            if token in {CfgToken.BREAK, CfgToken.SECTION}:
                if state.current_section:
                    _handle_section_end(state.current_section)

                if token == CfgToken.SECTION:
                    state.load_section(line)

            # Process removed sections/parameters
            if token == CfgToken.SECTION and state.is_removing():
                should_write_src_line = False
                state.is_changed = True
                print(f"Removed {state.current_section.name}")
            elif token == CfgToken.PARAMETER and state.is_removing(param_name=kwargs["key"]):
                should_write_src_line = False
                state.is_changed = True
                print(f"Removed {state.current_section.name} {kwargs['key']}")

            # Process saved sections/parameters
            elif token == CfgToken.PARAMETER and state.has_section_data(prop := kwargs["key"]):
                actual_value = kwargs["value"]
                saved_value = state.pop_saved_value(prop)

                # TODO: add to check for parameter duplicates after that

                if actual_value != saved_value:
                    state.is_changed = True
                    should_write_src_line = False
                    out_f.write(f"{prop}: {saved_value}\n")
                    print(f"Restored {state.current_section.name} {prop}: {actual_value} <-- {saved_value}")
                elif VERBOSE:
                    print(f"Not Changed {state.current_section.name} {prop}: {actual_value}")

            elif token == CfgToken.INCLUDE:
                act = PARAMETERS.include_action(kwargs["path"])

                if act == Action.ADD:
                    state.pop_include(kwargs["path"])
                elif act == Action.REMOVE:
                    state.is_changed = True
                    print(f"Removed Include {kwargs['path']!r}")

                # Skip all 'ADD' and 'REMOVE' includes, since we already added them at the beginning
                should_write_src_line = act is None

            elif token == CfgToken.EDITABLE_BLOCK_END:
                state.is_end = True

                # Check missing includes:
                for include_path in state.includes:
                    state.is_changed = True
                    print(f"Added Include {include_path!r}")

                # Handle last section (if any) unprocessed parameters
                if state.current_section:
                    _handle_section_end(state.current_section)

                # Add missing sections/props
                for name, section_data_ in state.data.items():
                    if len(section_data_) == 0:
                        continue

                    out_f.write(f"\n{name}\n")
                    state.is_changed = True
                    print(f"Added Section {name}")

                    for prop_key, prop_value in section_data_.items():
                        out_f.write(f"{prop_key}: {prop_value}\n")
                        print(f"Added {name} {prop_key}: <-- {prop_value}")

                out_f.write("\n")

            if should_write_src_line:
                out_f.write(line.rstrip() + "\n")

        # Add includes at the beginning
        for path, action in PARAMETERS.includes:
            if action == Action.ADD:
                out_f.write(f"[include {path}]\n")

        iterate_printer_config_tokens(file_path, callback=_parse_config)

    if not state.is_changed:
        print("Config doesn't contains changed properties!")
        return

    if not dry:
        print(f"Update config \"{file_path}\"")
        os.rename(tmp_path, file_path)
    else:
        print(f"Saved to \"{tmp_path}\"")

    print("\nDone!")


## Verify command implementation
##########################################################################

def has_changes(file_path, saved_data):
    print(f"Verifying config \"{file_path}\"...\n")

    state = RestoreState(
        data=deepcopy(saved_data),
        includes={inc for inc, act in PARAMETERS.includes if act == Action.ADD}
    )

    def _handle_section_end(section: RestoreState.SectionState):
        if section.data is None: return

        for key, value in section.data.items():
            state.is_changed = True
            print(f"To Add {state.current_section.name} {key}: <-- {value}")

        state.mark_section_used()

    def _parse_config(token, line, **kwargs):
        if state.is_end and token in {CfgToken.SECTION, CfgToken.PARAMETER, CfgToken.INCLUDE}:
            print(f"Warning: read token {token.name!r} after end of editable file part: {kwargs}", file=sys.stderr)

        # Process section switch
        if token in {CfgToken.BREAK, CfgToken.SECTION}:
            if state.current_section:
                _handle_section_end(state.current_section)

            if token == CfgToken.SECTION:
                state.load_section(line)

        # Process removed sections/parameters
        if token == CfgToken.SECTION and state.is_removing():
            state.is_changed = True
            print(f"To Remove section {state.current_section.name}")
        elif token == CfgToken.PARAMETER and state.is_removing(param_name=kwargs["key"]):
            state.is_changed = True
            print(f"To Remove {state.current_section.name} {kwargs['key']}")

        # Process saved sections/parameters
        elif token == CfgToken.PARAMETER and state.has_section_data(prop := kwargs["key"]):
            actual_value = kwargs["value"]
            saved_value = state.pop_saved_value(prop)

            # TODO: add to check for parameter duplicates after that

            if actual_value != saved_value:
                state.is_changed = True
                print(f"To Restore {state.current_section.name} {prop}: {actual_value} <-- {saved_value}")
            elif VERBOSE:
                print(f"Not Changed {state.current_section.name} {prop}: {actual_value}")

        elif token == CfgToken.INCLUDE and (a := PARAMETERS.include_action(kwargs["path"])) is not None:
            if a == Action.ADD:
                state.pop_include(kwargs["path"])
            else:
                state.is_changed = True
                print(f"To Remove Include {kwargs['path']!r}")

        elif token == CfgToken.EDITABLE_BLOCK_END:
            state.is_end = True

            # Check missing includes
            for include in state.includes:
                state.is_changed = True
                print(f"To Add Include {include!r}")

            # Handle last section (if any) unprocessed parameters
            if state.current_section:
                _handle_section_end(state.current_section)

            # Check missing sections/props
            for name, section_data_ in state.data.items():
                if len(section_data_) == 0:
                    continue

                print(f"To Add Section {name}")

                for prop_key, prop_value in section_data_.items():
                    state.is_changed = True
                    print(f"To Add {name} {prop_key}: <-- {prop_value}")

    iterate_printer_config_tokens(file_path, callback=_parse_config)

    return state.is_changed


## Main code
##########################################################################


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
    parser.add_argument("-n", "--no_data", action="store_true",
                        help="Run without data source (useful when you only need to delete parameters)", default=False)
    parser.add_argument("-w", "--avoid_writes", action="store_true",
                        help="Avoid additional writes to disk", default=False)
    parser.add_argument("--dry", action="store_true",
                        help='Dry run', default=False)
    parser.add_argument("--verbose", action="store_true",
                        help='Dry run', default=False)

    args = parser.parse_args()

    config_path = args.config
    data_path = args.data
    params_path = args.params
    mode = args.mode
    no_data = args.no_data
    avoid_writes = args.avoid_writes
    dry_run = args.dry
    VERBOSE = args.verbose

    if not os.path.isfile(config_path):
        print(f"Config file doesn't exists: \"{config_path}\"\n", file=sys.stderr)
        exit(2)

    if params_path and not os.path.isfile(params_path):
        print(f"Parameters file doesn't exists: \"{params_path}\"\n", file=sys.stderr)
        exit(2)

    if params_path:
        PARAMETERS = parse_cmd_configuration(params_path)
        print()

    if len(list(PARAMETERS.sections)) == 0 and len(list(PARAMETERS.includes)) == 0:
        print(f"Parameters list is empty!\n", file=sys.stderr)
        exit(5)

    if mode == "backup":
        backup(config_path, data_path, dry_run)
    elif mode == "restore":
        if not no_data:
            if not os.path.isfile(data_path):
                print(f"Backup file doesn't exists: \"{data_path}\"\n", file=sys.stderr)
                exit(2)

            backup_data = load_backup(data_path)
        else:
            backup_data = dict()

        if not avoid_writes or has_changes(config_path, backup_data):
            print()
            restore(config_path, backup_data, dry_run)
        else:
            print("Config doesn't contains changed properties!")
    elif mode == "verify":
        if not no_data:
            backup_data = load_backup(data_path)
        else:
            backup_data = dict()

        if has_changes(config_path, backup_data):
            print("\nConfig changed!")
            exit(1)

        print("Config doesn't contains changed properties!")
    else:
        parser.print_help(sys.stderr)
        exit(1)
