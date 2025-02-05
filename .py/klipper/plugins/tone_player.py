## Audio player for Flashforge AD5M
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license
##
################################################################
## PwmAudio implementation:
##
## link: https://github.com/consp/flashforge_adm5_audio
##
## Copyright (C) 2025, Tristan <https://github.com/consp>


import logging
from pathlib import Path


class PWMAudio:
    chip = 0
    device = 0
    PWMEXPORT = "/sys/class/pwm/pwmchip%d/export"
    PWMCLASS = "/sys/class/pwm/pwmchip%d/pwm%d/%s"
    ENABLE = "enable"
    PERIOD = "period"
    DUTY_CYCLE = "duty_cycle"

    DC = 0.5  # fixed
    enabled = False

    def __init__(self, chip, device):
        self.chip = chip
        self.device = device
        self.export()
        self.disable()

    def pwmdevice(self, end):
        return self.PWMCLASS % (self.chip, self.device, end)

    def export(self):
        # check if exists
        pwmpath = Path(self.PWMEXPORT[:-6] % (self.chip) + "/pwm%d" % (self.device))
        if pwmpath.is_dir():
            return
        with open(self.PWMEXPORT % self.chip, 'wb') as f:
            f.write(b"%d" % self.device)
            f.flush()

    def enable(self, enable=True):
        self.enabled = enable

        if self.period == 0:  # period needs to be set otherwise errors will be thrown
            self.set(1000)
        with open(self.pwmdevice(self.ENABLE), "wb") as f:
            f.write(b"1" if enable else b"0")
            f.flush()

    def disable(self):
        self.enable(enable=False)

    @property
    def period(self):
        with open(self.pwmdevice(self.PERIOD), "rb") as f:
            return int(f.read())

    @period.setter
    def period(self, period):
        with open(self.pwmdevice(self.PERIOD), "wb") as f:
            f.write(b"%d" % period)
            f.flush()

    @property
    def duty_cycle(self):
        with open(self.pwmdevice(self.DUTY_CYCLE), "rb") as f:
            return int(f.read())

    @duty_cycle.setter
    def duty_cycle(self, dc):
        with open(self.pwmdevice(self.DUTY_CYCLE), "wb") as f:
            f.write(b"%d" % dc)
            f.flush()

    def set(self, frequency):
        period = 1000000000 / frequency
        dc = int(period * self.DC)
        if period < self.duty_cycle:
            self.duty_cycle = dc
            self.period = period
        else:
            self.period = period
            self.duty_cycle = dc


class TonePlayer:
    def __init__(self, config):
        self.config = config
        self.printer = config.get_printer()
        self.reactor = self.printer.get_reactor()
        self.gcode = self.printer.lookup_object("gcode")

        self.verbose = config.getboolean("verbose", False)

        self.gcode.register_command("TONE", self.cmd_TONE)

    def cmd_TONE(self, gcmd):
        notes = self._parse_notes(gcmd)

        if self.verbose:
            duration = sum(d / 1000 for (_, d) in notes)
            notes_cnt = len([freq for (freq, _) in notes if freq > 0])
            gcmd.respond_raw(f"Playing tune: duration: {duration:.2f}s, notes: {notes_cnt}")

        pwm = PWMAudio(0, 6)
        for tone, duration in notes:
            if tone > 0:
                pwm.set(tone)
                pwm.enable()
            else:
                pwm.disable()

            now = self.reactor.monotonic()
            self.reactor.pause(now + duration / 1000)

        pwm.disable()

        if self.verbose:
            gcmd.respond_raw("Done")

    def _parse_notes(self, gcmd):
        notes_str = gcmd.get("NOTES")

        try:
            return [
                (float(pair[0]), float(pair[1])) if len(pair) == 2 else (0.0, float(pair[0]))
                for note in notes_str.strip().split(" ")
                for pair in [note.split(":", maxsplit=1)]
            ]
        except:
            msg = "Unable to parse notes."
            logging.exception(f"[tone_player] {msg}\n{notes_str}")
            raise gcmd.error(msg)


def load_config(config):
    return TonePlayer(config)
