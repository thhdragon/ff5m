#!/usr/bin/python

## Audio tone playing for Flashforge AD5M
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


import sys
from time import sleep
from audio import PWMAudio

def play(notes):
    duration = sum(d / 1000 for (_, d) in notes)
    notes_cnt = len([freq for (freq, _) in notes if freq > 0])

    print(f"Playing tune: duration: {duration:.2f}s, notes: {notes_cnt}")

    pwm = PWMAudio(0, 6)
    for tone, duration in notes:
        if tone > 0:
            pwm.set(tone)
            pwm.enable()
        else:
            pwm.disable()

        sleep(duration/1000.)
    
    pwm.disable()


if __name__ == '__main__':
    if len(sys.argv) <= 1:
        print(f"Usage {sys.argv[0]} <tone:duration> [<tone2:duration2> ...]")
        exit(1)

    play([
        (float(pair[0]), float(pair[1])) if len(pair) == 2 else (0.0, float(pair[0]))
        for arg in sys.argv[1:]
        for pair in [arg.split(":", maxsplit=1)]
    ])
