# Run a shell command via gcode
#
# Changes:
# - Added background and exclusive parameters
#
# Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
#
# Copyright (C) 2019  Eric Callahan <arksine.code@gmail.com>
#
# This file may be distributed under the terms of the GNU GPLv3 license.

import os
import shlex
import subprocess
import logging
import threading


class ShellCommand:
    def __init__(self, config):
        self.name = config.get_name().split()[-1]
        self.printer = config.get_printer()
        self.gcode = self.printer.lookup_object('gcode')
        cmd = config.get('command')
        cmd = os.path.expanduser(cmd)
        self.command = shlex.split(cmd)
        self.timeout = config.getfloat('timeout', 2., above=0.)
        self.background = config.getboolean('background', False)
        self.exclusive = config.getboolean('exclusive', True)
        self.verbose = config.getboolean('verbose', True)
        self.proc_fd = None
        self.partial_output = ""
        self.running = False
        self.gcode.register_mux_command(
            "RUN_SHELL_COMMAND", "CMD", self.name,
            self.cmd_RUN_SHELL_COMMAND,
            desc=self.cmd_RUN_SHELL_COMMAND_help)

    def _process_output(self, eventime):
        if self.proc_fd is None:
            return
        try:
            data = os.read(self.proc_fd, 4096)
        except Exception:
            pass
        data = self.partial_output + data.decode()
        if '\n' not in data:
            self.partial_output = data
            return
        elif data[-1] != '\n':
            split = data.rfind('\n') + 1
            self.partial_output = data[split:]
            data = data[:split]
        else:
            self.partial_output = ""
        self.gcode.respond_info(data)

    cmd_RUN_SHELL_COMMAND_help = "Run a linux shell command"

    def cmd_RUN_SHELL_COMMAND(self, params):
        if self.running:
            raise self.gcode.error("Command already running.")

        gcode_params = params.get('PARAMS', '')
        gcode_params = shlex.split(gcode_params)
        reactor = self.printer.get_reactor()
        detached = self.background and not self.exclusive
        try:
            proc = subprocess.Popen(
                self.command + gcode_params,
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                start_new_session=detached)
        except Exception:
            logging.exception(
                "shell_command: Command {%s} failed" % (self.name))
            raise self.gcode.error("Error running command {%s}" % (self.name))

        if self.verbose and not self.background:
            self.proc_fd = proc.stdout.fileno()
            self.gcode.respond_info("Running Command {%s}...:" % (self.name))
            hdl = reactor.register_fd(self.proc_fd, self._process_output)

        if detached:
            logging.info(
                f"[gcode_shell_command {self.name}]: daemon mode configured. "
                f"Detach from process \"{proc.pid}\".")

            if self.verbose: self.gcode.respond_info(f"Process {self.name} ran in daemon mode.")
            return

        self.running = True
        if self.background:
            logging.info(
                f"[gcode_shell_command {self.name}]: background mode configured. "
                f"Wait process \"{proc.pid}\" to finish for {self.timeout}s.")

            thread = threading.Thread(target=lambda: self._wait_bg_process(proc, reactor), daemon=True)
            thread.start()

            if self.verbose: self.gcode.respond_info(f"Process {self.name} ran in background mode.")
            return

        eventtime = reactor.monotonic()
        endtime = eventtime + self.timeout
        complete = False

        while eventtime < endtime:
            eventtime = reactor.pause(eventtime + .05)
            if proc.poll() is not None:
                complete = True
                break

        if not complete:
            proc.terminate()

        self.running = False
        if self.verbose:
            if self.partial_output:
                self.gcode.respond_info(self.partial_output)
                self.partial_output = ""
            if complete:
                msg = "Command {%s} finished\n" % (self.name)
            else:
                msg = "Command {%s} timed out" % (self.name)
            self.gcode.respond_info(msg)
            reactor.unregister_fd(hdl)
            self.proc_fd = None

    def _wait_bg_process(self, proc, reactor):
        proc_fd = proc.stdout.fileno()
        proc.wait(self.timeout)

        not_finished = proc.poll() is None
        if not_finished:
            proc.terminate()
            logging.info(f"[gcode_shell_command {self.name}]: process \"{proc.pid}\" not finished within timeout. Terminate.")

            if self.verbose:
                self._async_response(reactor, self._read_stdout(proc_fd))
                self._async_response(reactor, f"!! Process {self.name} terminated due to timeout.")

        else:
            logging.info(f"[gcode_shell_command {self.name}]: process \"{proc.pid}\" done.")

            if self.verbose:
                self._async_response(reactor, self._read_stdout(proc_fd))
                self._async_response(reactor, f"// Process {self.name} done.")

        self.running = False

    def _read_stdout(self, fd):
        result = ""
        while os.path.exists(fd):
            data = os.read(fd, 4096)
            if not data: break

            result += data.decode()

        return result

    def _async_response(self, reactor, message):
        if not message: return

        def _callback(s):
            self.gcode.respond_raw(s)

        reactor.register_async_callback(
            (lambda e, cb=_callback, s=message: _callback(s)))


def load_config_prefix(config):
    return ShellCommand(config)
