## [gcode_macro LOAD_CELL_TARE]
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license
from encodings import search_function


class LoadCellTareGcode:
    def __init__(self, config):
        self.loaded = False

        self.config = config
        self.printer = config.get_printer()
        self.gcode = self.printer.lookup_object("gcode")
        self.gcode.register_command("LOAD_CELL_TARE", self.cmd_LOAD_CELL_TARE)

    def _lazy_load_printers_objects(self):
        if self.loaded: return

        self.loaded = True
        self.toolhead = self.printer.lookup_object("toolhead")
        self.weight = self.printer.lookup_object("temperature_sensor weightValue")
        self.probe = self.printer.lookup_object("probe")
        self.level_pin = self.printer.lookup_object("gcode_button check_level_pin")
        self.variables = self.printer.lookup_object("save_variables")

    def _run_gcode(self, *cmds: str):
        self.gcode.run_script_from_command("\n".join(cmds))

    def cmd_LOAD_CELL_TARE(self, gcmd):
        self._lazy_load_printers_objects()

        weight = self.weight.last_temp
        threshold_weight = self.variables.allVariables.get("cell_weight", 0)

        gcmd.respond_info(f"Started load cell tare. Weight: {weight}, threshold: {threshold_weight}")

        if weight < threshold_weight:
            gcmd.respond_info(f"Current weight threshold: {weight} < {threshold_weight}. Skipping tare.")
            return

        self._query_probe(gcmd)

        # Try to reset 5 times. IDK if there is any reason for this, but the original firmware does it 10 times
        ok = False
        for i in range(5):
            self._cell_tare()

            if self.level_pin.last_state:
                gcmd.respond_info(f"Load cell tared and confirmed.")
                ok = True
                break

            gcmd.respond_info(f"Attempt {i + 1}. No confirmation from level sensor. Weight: {self.weight.last_temp}")

        self._run_gcode("G4 P100")
        if abs(self.weight.last_temp) > threshold_weight:
            raise gcmd.error(f"Load cell tare failed: weight {self.weight.last_temp} > threshold {threshold_weight}")

        if not ok:
            if self.weight.last_temp < threshold_weight and self.config.getint("skip_tare_error", 0):
                gcmd.respond_info(f"Load cell tared, but no confirmation from level sensor; configured to skip.")
            else:
                raise gcmd.error("Load cell tare failed")

        # If we are here - tare is considered successful
        self._confirm_tare()

    def _query_probe(self, gcmd):
        self._run_gcode("QUERY_PROBE")

        if not self.probe.last_state:
            gcmd.respond_info("Load cell sensor is not activated. OK!")
            return

        self._run_gcode("SAVE_GCODE_STATE NAME=CELL_TARE")
        self.gcode.run_script_from_command("SAVE_GCODE_STATE NAME=CELL_TARE")

        kin_status = self.toolhead.get_kinematics().get_status(0)
        if "z" not in kin_status['homed_axes']:
            self._run_gcode("G28 Z")
        elif self.toolhead.get_position()[2] < 5:  # position.z
            self._run_gcode(
                "G90",
                "G1 Z10 F6000",
                "G4 P55",
            )

        self.gcode.run_script_from_command("RESTORE_GCODE_STATE NAME=CELL_TARE")
        self.gcode.respond_raw("!! Load cell sensor is activated. Please ensure the bed is clean!")

    def _cell_tare(self):
        # Tare is set by toggling level_h1 pin
        timeout = 250
        self._run_gcode(
            "SET_PIN PIN=level_h1 VALUE=0",
            f"G4 P{timeout}",
            "SET_PIN PIN=level_h1 VALUE=1",
            f"G4 P{timeout}",
            "SET_PIN PIN=level_h1 VALUE=0",
            f"G4 P{timeout}",
            "SET_PIN PIN=level_h1 VALUE=1",
            f"G4 P{timeout}",
        )

    def _confirm_tare(self):
        # Toggle level clear pins.
        # Not sure what the level clear pin does. But we do the same as the stock software.
        timeout = 10
        self._run_gcode(
            "SET_PIN PIN=level_clear VALUE=0",
            f"G4 P{timeout}",
            "SET_PIN PIN=level_clear VALUE=1",
            f"G4 P{timeout}",
        )


def load_config(config):
    return LoadCellTareGcode(config)
