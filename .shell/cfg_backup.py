## Configuration backup and restore
##
## Copyright (C) 2025 Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

import argparse
import os.path
import re
import sys
from posix import write

SECTION_RE = re.compile(r"^\[(\w+)(?:\s*(\w+))?]$")
PARAMETER_RE = re.compile(r"^(\w+):\s*(.+)$")

PARAMETER_CFG_RE = re.compile(r"^(\[\w+\s*(?:\w+)?])\s+(\w+)$")

PARAMETERS_TO_SAVE = {
    "[stepper_x]": {"rotation_distance"},
    "[stepper_y]": {"rotation_distance"},
    "[stepper_z]": {"rotation_distance"}
}

VERBOSE = False


class CfgToken:
    SECTION = 1
    PARAMETER = 2
    COMMENT = 3
    BREAK = 4
    OTHER = 5  # multi-line params, etc


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


def backup(config_path, dst_path, dry=False):
    print(f"Parsing config \"{config_path}\"...")

    tmp_path = dst_path + ".tmp"
    with open(tmp_path, "w") as out_f:
        empty = True
        section_cfg = None

        def _callback(token, line, **kwargs):
            nonlocal section_cfg, empty
            if token == CfgToken.SECTION and line in PARAMETERS_TO_SAVE:
                section_cfg = PARAMETERS_TO_SAVE[line]
                out_f.write(line + "\n")
                if VERBOSE: print(f"Section: {line}")
            elif section_cfg and token == CfgToken.PARAMETER and kwargs["key"] in section_cfg:
                out_f.write(line + "\n")
                if VERBOSE: print(f"  - {line}")
                empty = False

        parse_cfg(config_path, callback=_callback)

    if empty:
        sys.stderr.write("Unable to find any parameters in config. Backup not created\n")
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

    def _parse_data(token, line, **kwargs):
        nonlocal data, section
        if token == CfgToken.SECTION:
            if line not in data:
                data[line] = dict()
            section = data[line]
            if VERBOSE: print(f"Loaded section: {line}")
        elif section is not None and token == CfgToken.PARAMETER:
            if VERBOSE: print(f"  - Load Parameter {kwargs['key']}")
            section[kwargs["key"]] = kwargs["value"]

    parse_cfg(data_path, callback=_parse_data)

    if not all(len(d) for d in data.values()):
        sys.stderr.write("Backup file doesn't contains any properties")
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

            # Process section change
            if (token == CfgToken.BREAK or token == CfgToken.SECTION) and section is not None:
                for key, value in section.items():
                    out_f.write(f"{key}: {value}\n")
                    print(f"Added {section_name} {key}: <-- {value}")
                    restored = True

                del data[section_name]
                section = None
                section_name = None
            elif token == CfgToken.SECTION and line in data:
                section = data[line]
                section_name = line
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
    parser = argparse.ArgumentParser(description="Printer configuration backup script")

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
        sys.stderr.write(f"Config file doesn't exists: \"{config_path}\"\n")
        exit(2)

    if params_path and not os.path.isfile(params_path):
        sys.stderr.write(f"Parameters file doesn't exists: \"{params_path}\"\n")
        exit(2)

    if params_path:
        with open(params_path, "r") as in_file:
            print(f"Loading parameters from \"{params_path}\"...")
            PARAMETERS_TO_SAVE.clear()

            for line in in_file:
                line = line.strip()
                if not line:
                    continue

                if not (m := PARAMETER_CFG_RE.match(line)):
                    sys.stderr.write(f"Invalid parameter line: {line}\n")
                    continue

                [section, param] = m.groups()
                if section not in PARAMETERS_TO_SAVE:
                    PARAMETERS_TO_SAVE[section] = set()

                PARAMETERS_TO_SAVE[section].add(param)

                if VERBOSE: print(f"Added parameter {section} {param}")

            print()

    if len(PARAMETERS_TO_SAVE) == 0:
        sys.stderr.write(f"Parameters list is empty!\n")
        exit(5)

    if mode == "backup":
        backup(config_path, data_path, dry_run)
    elif mode == "restore":
        if not os.path.isfile(data_path):
            sys.stderr.write(f"Backup file doesn't exists: \"{data_path}\"\n")
            exit(2)

        restore(config_path, data_path, dry_run)
    else:
        parser.print_help(sys.stderr)
        exit(1)
