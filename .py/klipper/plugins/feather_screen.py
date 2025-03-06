## Feather screen support macros
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

import os.path
import subprocess

TOOLBAR_REFRESH_TIME = 1


class FeatherScreenHelper:
    def __init__(self, debug=False):
        self.debug = debug
        self._process = None

    def start(self):
        os.system("killall typer")

        self._process = subprocess.Popen(
            [
                "/root/printer_data/bin/typer",
                *(["--debug"] if self.debug else []),
                "--double-buffered",
                "batch", "--pipe", "/tmp/typer"
            ],
            stdout=subprocess.PIPE if self.debug else subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )

    def stop(self):
        if self._process:
            self._process.terminate()
            self._process = None

    icon_extruder = '\ue119'
    icon_bed = '\ue003'

    icon_wifi = '\uE146'
    icon_servo = '\ue050'
    icon_active = '\ue076'
    icon_camera = '\ue03b'

    toolbar_y = 25

    def draw_toolbar(self, *, wifi, camera, motors, idle, extruder_temp, bed_temp):
        if not self._process or self._process.poll() is not None:
            raise RuntimeError("Screen is not running")

        extruder_temp_str = "%0.1f" % extruder_temp
        bed_temp_str = "%0.1f" % bed_temp

        extruder_color = "ff0000" if extruder_temp >= 50 else "ffffff"
        bed_color = "ff0000" if bed_temp >= 40 else "ffffff"

        wifi_color = "ffffff" if wifi else "606060"
        active_color = "ea00ff"
        servo_color = "ff9000"
        camera_color = "ffffff"

        offset_x = 770
        icon_width = 40
        icons = [
            f'--batch text -p {offset_x} {self.toolbar_y} -c {wifi_color}  -ha right '
            f'-va middle -f  "Typicons 12pt" -t "{self.icon_wifi}"',
        ]

        if camera:
            offset_x -= icon_width
            icons.append(
                f'--batch text -p {offset_x} {self.toolbar_y} -c {camera_color} -ha right '
                + f'-va middle -f  "Typicons 12pt" -t "{self.icon_camera}"'
            )

        if not idle:
            offset_x -= icon_width
            icons.append(
                f'--batch text -p {offset_x} {self.toolbar_y} -c {active_color} -ha right '
                + f'-va middle -f  "Typicons 12pt" -t "{self.icon_active}"'
            )

        if motors:
            offset_x -= icon_width
            icons.append(
                f'--batch text -p {offset_x} {self.toolbar_y} -c {servo_color} -ha right '
                + f'-va middle -f  "Typicons 12pt" -t "{self.icon_servo}"'
            )

        with open("/tmp/typer", 'w') as p:
            p.write('\n'.join([
                '--batch fill -p 0 0 -s 800 40',
                f'--batch text -p 30 {self.toolbar_y}',
                f'--batch text -c {bed_color}      -ha right -va middle -f  "Typicons 12pt"  -t "{self.icon_bed}"',
                f'--batch text -c {bed_color}      -ha left  -va middle -f  "Roboto 12pt"    -t " {bed_temp_str}  "',
                f'--batch text -c {extruder_color} -ha left  -va middle -f  "Typicons 12pt"  -t "{self.icon_extruder}"',
                f'--batch text -c {extruder_color} -ha left  -va middle -f  "Roboto 12pt"    -t " {extruder_temp_str}"',
                *icons,
                "--batch flush",
                "--end\n",
            ]))


class FeatherScreen:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.reactor = self.printer.get_reactor()
        self.gcode = self.printer.lookup_object('gcode')

        self.feather = FeatherScreenHelper(config.getboolean("debug", False))
        self._toolbar_timer = None

        self.printer.register_event_handler("klippy:ready", self._init)
        self.printer.register_event_handler("klippy:shutdown", self._shutdown)
        self.printer.register_event_handler("klippy:disconnect", self._shutdown)

    def _init(self):
        self.vcard = self.printer.lookup_object("virtual_sdcard")
        self.params = self.printer.lookup_object("mod_params")

        self.extruder = self.printer.lookup_object("extruder")
        self.heater_bed = self.printer.lookup_object("heater_bed")
        self.toolhead = self.printer.lookup_object("toolhead")

        self.idle_timeout = self.printer.lookup_object("idle_timeout")

        self.feather.start()
        self._toolbar_timer = self.reactor.register_timer(self._update_status_bar, self.reactor.NOW)

    def _shutdown(self):
        if self._toolbar_timer is not None:
            self.reactor.unregister_timer(self._toolbar_timer)
            self._toolbar_timer = None

        self.feather.stop()

    def _update_status_bar(self, eventtime):
        self.feather.draw_toolbar(
            wifi=os.path.exists("/tmp/net_connected_f"),
            camera=True,  # os.system('ps | grep -q "[m]jpg_streamer"') == 0,
            idle=self.idle_timeout.get_status(eventtime)["state"] == "Idle",
            motors=len(self.toolhead.get_status(eventtime)["homed_axes"]) > 0,
            extruder_temp=self.extruder.get_status(eventtime)["temperature"],
            bed_temp=self.heater_bed.get_status(eventtime)["temperature"],
        )

        return eventtime + TOOLBAR_REFRESH_TIME


def load_config(config):
    return FeatherScreen(config)
