# Axis Correction Module for Klipper
#
# Provides per-axis linear scaling at the toolhead layer, using
# user-friendly percent-based configuration.
#
# Copyright (C) 2025  Your Name <your@email.com>
#
# This file may be distributed under the terms of the GNU GPLv3 license.

class AxisCorrection:
    def __init__(self, config):
        self.printer = config.get_printer()
        acfg = config.getsection('axis_correction')
        self.x_correction = acfg.getfloat('x_correction', 0.0)
        self.y_correction = acfg.getfloat('y_correction', 0.0)
        self.z_correction = acfg.getfloat('z_correction', 0.0)
        self.x_scale = 1.0 + self.x_correction / 100.0
        self.y_scale = 1.0 + self.y_correction / 100.0
        self.z_scale = 1.0 + self.z_correction / 100.0
        self.printer.register_event_handler("klippy:ready", self._hook_toolhead)
        self.toolhead_hooked = False

    def _hook_toolhead(self):
        if self.toolhead_hooked:
            return
        toolhead = self.printer.lookup_object('toolhead')
        orig_move = toolhead.move
        orig_set_position = toolhead.set_position

        def scaled_move(newpos, speed, *args, **kwargs):
            scaled = list(newpos)
            if len(scaled) > 0:
                scaled[0] = scaled[0] * self.x_scale
            if len(scaled) > 1:
                scaled[1] = scaled[1] * self.y_scale
            if len(scaled) > 2:
                scaled[2] = scaled[2] * self.z_scale
            return orig_move(scaled, speed, *args, **kwargs)

        def scaled_set_position(newpos, *args, **kwargs):
            # Do NOT scale during homing
            if 'homing_axes' in kwargs and kwargs['homing_axes']:
                return orig_set_position(newpos, *args, **kwargs)
            scaled = list(newpos)
            if len(scaled) > 0:
                scaled[0] = scaled[0] * self.x_scale
            if len(scaled) > 1:
                scaled[1] = scaled[1] * self.y_scale
            if len(scaled) > 2:
                scaled[2] = scaled[2] * self.z_scale
            return orig_set_position(scaled, *args, **kwargs)

        toolhead.move = scaled_move
        toolhead.set_position = scaled_set_position
        self.toolhead_hooked = True

    def get_status(self, eventtime=None):
        return {
            "x_correction_percent": self.x_correction,
            "y_correction_percent": self.y_correction,
            "z_correction_percent": self.z_correction,
            "x_scale": self.x_scale,
            "y_scale": self.y_scale,
            "z_scale": self.z_scale,
        }

def load_config(config):
    return AxisCorrection(config)
