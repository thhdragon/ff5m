## Configuration backup and restore
##
## Copyright (C) 2025 Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

import argparse
import os.path
import re
import sys

from enum import Enum

VERBOSE = 0

PARAMETERS_TO_ADD = {
    "[stepper_x]": {"rotation_distance"},
    "[stepper_y]": {"rotation_distance"},
    "[stepper_z]": {"rotation_distance"}
}

PARAMETERS_TO_REMOVE = dict()

SECTIONS_TO_ADD = set()
SECTIONS_TO_REMOVE = set()


class CfgToken(Enum):
    SECTION = 1
    PARAMETER = 2
    COMMENT = 3
    BREAK = 4
    OTHER = 5  # multi-line params, etc


SECTION_RE = re.compile(r"^\[(\w+)(?:\s*(\w+))?]$")
PARAMETER_RE = re.compile(r"^(\w+):\s*(.+)$")


def parse_cfg(file_path, *, callback):
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


class ParametersToken(Enum):
    SECTION_PARAMETER_ADD = 1
    SECTION_PARAMETER_REMOVE = 2
    SECTION_ADD = 3
    SECTION_REMOVE = 4
    COMMENT = 5


PARAMETER_ADD_RE = re.compile(r"^(\[\w+\s*(?:\w+)?])\s+(\w+)\s*(?:#.*)?$")
PARAMETER_REMOVE_RE = re.compile(r"^-\s*(\[\w+\s*(?:\w+)?])\s+(\w+)\s*(?:#.*)?$")
SECTION_ADD_RE = re.compile(r"^(\[\w+\s*(?:\w+)?])\s*(?:#.*)?$")
SECTION_REMOVE_RE = re.compile(r"^-\s*(\[\w+\s*(?:\w+)?])\s*(?:#.*)?$")


def parse_parameters(file_path, *, callback):
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
                print(f"Invalid parameter line: {s_line}\n", file=sys.stderr)


def load_parameters(file_path):
    def _callback(token, line, **kwargs):
        def _add_param(dict_, section, param):
            if section not in dict_:
                dict_[section] = set()

            dict_[section].add(param)

        if token == ParametersToken.SECTION_PARAMETER_ADD:
            _add_param(PARAMETERS_TO_ADD, kwargs["section"], kwargs["parameter"])
            if VERBOSE: print(f"Parameter to add: {kwargs['section']} {kwargs['parameter']}")

        elif token == ParametersToken.SECTION_PARAMETER_REMOVE:
            _add_param(PARAMETERS_TO_REMOVE, kwargs["section"], kwargs["parameter"])
            if VERBOSE: print(f"Parameter to remove: {kwargs['section']} {kwargs['parameter']}")

        elif token == ParametersToken.SECTION_ADD:
            SECTIONS_TO_ADD.add(kwargs["section"])
            if VERBOSE: print(f"Section to add: {kwargs['section']}")

        elif token == ParametersToken.SECTION_REMOVE:
            SECTIONS_TO_REMOVE.add(kwargs["section"])
            if VERBOSE: print(f"Section to remove: {kwargs['section']}")

    PARAMETERS_TO_ADD.clear()
    PARAMETERS_TO_REMOVE.clear()
    SECTIONS_TO_ADD.clear()
    SECTIONS_TO_REMOVE.clear()

    print(f"Loading parameters from \"{file_path}\"...")
    parse_parameters(file_path, callback=_callback)

    for section in SECTIONS_TO_REMOVE:
        if section in PARAMETERS_TO_REMOVE:
            print(f"Entire section {section} will be deleted. No need to delete individual props")
            del PARAMETERS_TO_REMOVE[section]

        # TODO: it's may be useful to delete entire section and then add only needed parameters
        if section in SECTIONS_TO_ADD or section in PARAMETERS_TO_ADD:
            print(f"Entire section {section} will be removed. Adding parameters is forbidden!\n", file=sys.stderr)
            exit(6)

    for section, parameters in PARAMETERS_TO_REMOVE.items():
        if section not in PARAMETERS_TO_ADD:
            continue

        section_add = PARAMETERS_TO_ADD[section]
        for param in parameters:
            if param in section_add:
                print(f"Parameter in {section} {param} marked for removal but also for addition!\n", file=sys.stderr)
                exit(6)

    for section in SECTIONS_TO_ADD:
        if section in PARAMETERS_TO_ADD:
            print(f"Entire section {section} will be saved. No need to add individual props")
            del PARAMETERS_TO_ADD[section]


def backup(config_path, dst_path, dry=False):
    print(f"Parsing config \"{config_path}\"...")

    tmp_path = dst_path + ".tmp"
    with (open(tmp_path, "w") as out_f):
        empty = True
        section_key = None
        section_cfg = None

        def _callback(token, line, **kwargs):
            nonlocal section_key, section_cfg, empty
            if token == CfgToken.SECTION:
                section_key = line

                if line in PARAMETERS_TO_ADD:
                    section_cfg = PARAMETERS_TO_ADD[line]
                elif line not in SECTIONS_TO_ADD:
                    return

                out_f.write(line + "\n")
                if VERBOSE: print(f"Section: {line}")
            elif token == CfgToken.PARAMETER and (section_cfg and kwargs["key"] in section_cfg or
                                                  section_key and section_key in SECTIONS_TO_ADD):
                out_f.write(line + "\n")
                if VERBOSE: print(f"  - {line}")
                empty = False
            elif token == CfgToken.BREAK:
                section_key = None
                section_cfg = None

        parse_cfg(config_path, callback=_callback)

    if empty:
        print("Unable to find any parameters in config. Backup not created\n", file=sys.stderr)
        exit(3)

    if not dry:
        os.rename(tmp_path, dst_path)
        print(f"\nBackup created: \"{dst_path}\"")
    else:
        print(f"\nTemporary backup created: \"{tmp_path}\"")

    print("\nDone!")


def restore(config_path, data_path, dry=False):
    print(f"Parsing backup \"{data_path}\"...")

    data = dict()
    section = None
    section_name = None

    def _parse_data(token, line, **kwargs):
        nonlocal data, section, section_name
        if token == CfgToken.SECTION and (line in SECTIONS_TO_ADD
                                          or line in PARAMETERS_TO_ADD):
            if line not in data:
                data[line] = dict()
            section = data[line]
            section_name = line
            if VERBOSE: print(f"Loaded section: {section_name}")

        elif token == CfgToken.PARAMETER and section is not None and ((section_name not in PARAMETERS_TO_REMOVE
                                                                       or kwargs['key'] not in PARAMETERS_TO_REMOVE[
                                                                           section_name])
                                                                      and (section_name in SECTIONS_TO_ADD
                                                                           or kwargs['key'] in PARAMETERS_TO_ADD[
                                                                               section_name])):
            if VERBOSE: print(f"  - Load Parameter {kwargs['key']}")
            section[kwargs["key"]] = kwargs["value"]

    parse_cfg(data_path, callback=_parse_data)

    if not all(len(d) for d in data.values()):
        print("Backup file doesn't contains any properties", file=sys.stderr)
        exit(4)

    print(f"Restoring config \"{config_path}\"...\n")

    restored = False
    tmp_path = config_path + ".tmp"

    with open(tmp_path, "w") as out_f:
        section = None
        section_name = None
        last_token = None

        def _parse_config(token, line, **kwargs):
            nonlocal restored, data, section, section_name, last_token
            should_write_src_line = True

            # Process section switch
            if token == CfgToken.BREAK or token == CfgToken.SECTION:
                if section is not None:
                    for key, value in section.items():
                        out_f.write(f"{key}: {value}\n")
                        print(f"Added {section_name} {key}: <-- {value}")
                        restored = True

                    del data[section_name]

                section = None
                section_name = None

            if token == CfgToken.SECTION and line in SECTIONS_TO_REMOVE:
                section_name = line
                should_write_src_line = False
                restored = True
                print(f"Deleted {section_name}")

            elif token == CfgToken.SECTION and line in data:
                section = data[line]
                section_name = line

            elif token == CfgToken.PARAMETER and (section_name in SECTIONS_TO_REMOVE
                                                  or (section_name in PARAMETERS_TO_REMOVE
                                                      and kwargs["key"] in PARAMETERS_TO_REMOVE[section_name])):
                should_write_src_line = False
                restored = True
                print(f"Deleted {section_name} {kwargs["key"]}")

            elif token == CfgToken.PARAMETER and section is not None and kwargs["key"] in section:
                prop = kwargs["key"]
                actual_value = kwargs["value"]
                saved_value = section[prop]
                del section[prop]

                if actual_value != saved_value:
                    out_f.write(f"{prop}: {saved_value}\n")
                    print(f"Restored {section_name} {prop}: {actual_value} <-- {saved_value}")
                    should_write_src_line = False
                    restored = True
                elif VERBOSE:
                    print(f"Not Changed {section_name} {prop}: {actual_value}")

            if should_write_src_line:
                out_f.write(line + "\n")
            last_token = token

        parse_cfg(config_path, callback=_parse_config)

        if last_token != CfgToken.BREAK:
            out_f.write("\n")

        # Add missing sections/props
        for section_name, section in data.items():
            if len(section) == 0:
                continue

            out_f.write(f"\n{section_name}\n")
            print(f"Added Section {section_name}")

            for key, value in section.items():
                out_f.write(f"{key}: {value}\n")
                print(f"Added {section_name} {key}: <-- {value}")
                restored = True

    if not restored:
        print("Config doesn't contains changed properties!")
        return

    if not dry:
        print(f"Update config \"{config_path}\"")
        os.rename(tmp_path, config_path)

    print("\nDone!")


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
                        choices=["backup", "restore"],
                        help="Mode: (backup, restore)")
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

    if not os.path.isfile(config_path):
        print(f"Config file doesn't exists: \"{config_path}\"\n", file=sys.stderr)
        exit(2)

    if params_path and not os.path.isfile(params_path):
        print(f"Parameters file doesn't exists: \"{params_path}\"\n", file=sys.stderr)
        exit(2)

    if params_path:
        load_parameters(params_path)
        print()

    if len(PARAMETERS_TO_ADD) == 0 and len(PARAMETERS_TO_REMOVE) == 0 and len(SECTIONS_TO_REMOVE) == 0:
        print(f"Parameters list is empty!\n", file=sys.stderr)
        exit(5)

    if mode == "backup":
        backup(config_path, data_path, dry_run)
    elif mode == "restore":
        if not os.path.isfile(data_path):
            print(f"Backup file doesn't exists: \"{data_path}\"\n", file=sys.stderr)
            exit(2)

        restore(config_path, data_path, dry_run)
    else:
        parser.print_help(sys.stderr)
        exit(1)
