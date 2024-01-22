#!/usr/bin/env python3

# from datetime import datetime
import argparse
import logging
import os
import subprocess
import sys

# from typing import Dict
from typing import Optional
from typing import List
from typing import Sequence
from typing import TextIO
from typing import Any
from typing import Union
from typing import cast
from dataclasses import dataclass, field

_header = """
                    -`
    ...            .o+`
 .+++s+   .h`.    `ooo/
`+++%++  .h+++   `+oooo:
+++o+++ .hhs++. `+oooooo:
+s%%so%.hohhoo'  'oooooo+:
`+ooohs+h+sh++`/:  ++oooo+:
 hh+o+hoso+h+`/++++.+++++++:
  `+h+++h.+ `/++++++++++++++:
           `/+++ooooooooooooo/`
          ./ooosssso++osssssso+`
         .oossssso-````/osssss::`
        -osssssso.      :ssss``to.
       :osssssss/  Mike  osssl   +
      /ossssssss/   8a   +sssslb
    `/ossssso+/:-        -:/+ossss'.-
   `+sso+:-`                 `.-/+oso:
  `++:.                           `-/+/
  .`                                 `/
"""

_VERSION = "0.1.0"
_AUTHOR = "Mike"

_log: logging.Logger
# _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_SCRIPTNAME = os.path.basename(__file__)
_log_file: Optional[str] = os.path.splitext(_SCRIPTNAME)[0] + ".log"

_verbose = False
# _is_windows = os.name == 'nt'
# _home = os.environ['USERPROFILE' if _is_windows else 'HOME']


@dataclass
class Job(object):
    """docstring for Job"""

    cmd: Sequence[str]
    stdout: List[str] = field(init=False, repr=False)
    stderr: List[str] = field(init=False, repr=False)
    pid: int = field(init=False)
    rc: int = field(init=False)

    # # NOTE: Needed it with python < 3.7
    # def __init__(self, cmd: Sequence[str]):
    #     """Create a shell command wrapper
    #
    #     Args:
    #         cmd (Sequence[str]): command with its arguments, first element must
    #                              be and executable or a path to the executable
    #     """
    #     self.cmd = cmd

    def head(self, size: int = 10) -> List[str]:
        """Emulate head shell util

        Args:
            size (int): first N elements of the stdout

        Returns:
            List of string with the first N elements
        """
        if size <= 0:
            raise Exception("Size cannot be less than 0")
        return self.stdout[0:size]

    def tail(self, size: int = 10) -> List[str]:
        """Emulate tail shell util

        Args:
            size (int): last N elements of the stdout

        Returns:
            List of string with the last N elements
        """
        if size <= 0:
            raise Exception("Size cannot be less than 0")
        return self.stdout[::-1][0:size]

    def execute(self, background: bool = True, cwd: Optional[str] = None) -> int:
        """Execute the cmd

        Args:
            background (bool): execute as async process
            cwd (Optional[str]): path where the cmd is execute, default to CWD

        Returns:
            Return-code integer of the cmd
        """
        # Verbose always overrides background output
        background = background if not _verbose else False
        cwd = "." if cwd is None else cwd

        _log.debug(f"Executing cmd: {self.cmd}")
        _log.debug("Sending job to background" if background else "Running in foreground")
        process = subprocess.Popen(self.cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, cwd=cwd)
        self.pid = process.pid

        self.stdout = []
        self.stderr = []

        while True:
            stdout = cast(TextIO, process.stdout).readline()
            stderr = cast(TextIO, process.stderr).readline()
            if (stdout == "" and stderr == "") and process.poll() is not None:
                break
            elif stdout:
                stdout = stdout.strip().replace("\n", "")
                self.stdout.append(stdout)
                if background:
                    _log.debug(stdout)
                else:
                    _log.info(stdout)
            elif stderr:
                stderr = stderr.strip().replace("\n", "")
                self.stderr.append(stderr)
                _log.error(stderr)

        # self.rc = process.poll()
        self.rc = process.returncode

        if self.rc != 0:
            _log.error(f"Command exited with {self.rc}")

        if self.stdout is not None and len(self.stdout) > 0:
            _log.debug(f"stdout: {self.stdout}")

        if self.stderr is not None and len(self.stderr) > 0:
            _log.error(f"stderr: {self.stderr}")

        return self.rc


def createLogger(
    stdout_level: int = logging.INFO,
    file_level: int = logging.DEBUG,
    color: bool = True,
    filename: Optional[str] = "dummy.log",
    name: str = "MainLogger",
):
    """Creates logging obj

    Args:
        stdout_level: logging level displayed into the terminal
        file_level: logging level saved into the logging file
        color: Enable/Disable color console output

    Returns:
        Logger with file and tty handlers

    """
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)

    ColorFormatter: Any = None
    Formatter: Any = None
    try:
        from colorlog import ColoredFormatter

        Formatter = ColoredFormatter
        ColorFormatter = ColoredFormatter
    except ImportError:

        class PrimitiveFormatter(logging.Formatter):
            """Logging colored formatter, adapted from https://stackoverflow.com/a/56944256/3638629"""

            def __init__(self, fmt, log_colors=None):
                super().__init__()
                self.fmt = fmt

                colors = {
                    "grey": "\x1b[38;21m",
                    "green": "\x1b[32m",
                    "magenta": "\x1b[35m",
                    "purple": "\x1b[35m",
                    "blue": "\x1b[38;5;39m",
                    "yellow": "\x1b[38;5;226m",
                    "red": "\x1b[38;5;196m",
                    "bold_red": "\x1b[31;1m",
                    "reset": "\x1b[0m",
                }

                if log_colors is None:
                    log_colors = {}

                log_colors["DEBUG"] = log_colors["DEBUG"] if "DEBUG" in log_colors else "magenta"
                log_colors["INFO"] = log_colors["INFO"] if "INFO" in log_colors else "green"
                log_colors["WARNING"] = log_colors["WARNING"] if "WARNING" in log_colors else "yellow"
                log_colors["ERROR"] = log_colors["ERROR"] if "ERROR" in log_colors else "red"
                log_colors["CRITICAL"] = log_colors["CRITICAL"] if "CRITICAL" in log_colors else "bold_red"

                self.FORMATS = {
                    logging.DEBUG: colors[log_colors["DEBUG"]] + self.fmt + colors["reset"],
                    logging.INFO: colors[log_colors["INFO"]] + self.fmt + colors["reset"],
                    logging.WARNING: colors[log_colors["WARNING"]] + self.fmt + colors["reset"],
                    logging.ERROR: colors[log_colors["ERROR"]] + self.fmt + colors["reset"],
                    logging.CRITICAL: colors[log_colors["CRITICAL"]] + self.fmt + colors["reset"],
                }

            def format(self, record):
                log_fmt = self.FORMATS.get(record.levelno)
                formatter = logging.Formatter(log_fmt)
                return formatter.format(record)

        Formatter = PrimitiveFormatter

    # This means both 0 and 100 silence all output
    stdout_level = 100 if stdout_level == 0 else stdout_level

    has_color = ColorFormatter is not None and color

    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(stdout_level)
    logformat = "{color}%(levelname)-8s | %(message)s"
    logformat = logformat.format(
        color="%(log_color)s" if has_color else "",
        # reset='%(reset)s' if has_color else '',
    )
    stdout_format = Formatter(
        logformat,
        log_colors={
            "DEBUG": "purple",
            "INFO": "green",
            "WARNING": "yellow",
            "ERROR": "red",
            "CRITICAL": "red",
        },
    )
    stdout_handler.setFormatter(stdout_format)

    logger.addHandler(stdout_handler)

    if file_level > 0 and file_level < 100 and filename is not None:

        with open(filename, "a") as log:
            log.write(_header)
            # log.write(f'\nDate: {datetime.datetime.date()}')
            log.write(f"\nAuthor:   {_AUTHOR}\nVersion:  {_VERSION}\n\n")

        file_handler = logging.FileHandler(filename=filename)
        file_handler.setLevel(file_level)
        file_format = logging.Formatter("%(levelname)-8s | %(filename)s: [%(funcName)s] - %(message)s")
        file_handler.setFormatter(file_format)

        logger.addHandler(file_handler)

    return logger


def _str_to_logging(level: Union[int, str]) -> int:
    """Convert logging level string to a logging number

    Args:
        level: integer representation or a valid logging string
                    - debug/verbose
                    - info
                    - warn/warning
                    - error
                    - critical
                All non valid integer or logging strings defaults to 0 logging

    Returns:
        logging level of the given string
    """

    if isinstance(level, int):
        level = abs(level - 100)
    elif isinstance(level, str):
        try:
            level = abs(int(level) - 100)
        except Exception:
            level = cast(str, level).lower()
            if level == "debug" or level == "verbose":
                level = logging.DEBUG
            elif level == "info":
                level = logging.INFO
            elif level == "warn" or level == "warning":
                level = logging.WARN
            elif level == "error":
                level = logging.ERROR
            elif level == "critical":
                level = logging.CRITICAL
            else:
                level = 100

    return level


def _parseArgs():
    """Parse CLI arguments

    Returns
        argparse.ArgumentParser class instance

    """

    class NegateAction(argparse.Action):
        def __call__(self, parser, ns, values, option):
            global _protocol
            if len(option) == 2:
                setattr(ns, self.dest, True)
            else:
                setattr(ns, self.dest, option[2:4] != "no")

    class NegateActionWithArg(argparse.Action):
        def __call__(self, parser, ns, values, option):
            if len(option) < 4:
                setattr(ns, self.dest, True if values is None or values == "" else values)
            elif option[2:4] == "no":
                setattr(ns, self.dest, False)
            else:
                setattr(ns, self.dest, values)

    class ChangeLogFile(argparse.Action):
        def __call__(self, parser, ns, values, option):
            if option[2:4] == "no":
                setattr(ns, self.dest, None)
            else:
                pass
                setattr(ns, self.dest, values)

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--color",
        "--nocolor",
        "--no-color",
        dest="color",
        action=NegateAction,
        default=True,
        nargs=0,
        help="Disable colored output",
    )

    parser.add_argument(
        "--log",
        "--nolog",
        "--no-log",
        dest="logfile",
        action=ChangeLogFile,
        default=_log_file,
        nargs="?",
        type=str,
        help="Log filename or disable log file",
    )

    parser.add_argument(
        "--version",
        dest="show_version",
        action="store_true",
        help="Print script version and exit",
    )

    parser.add_argument(
        "--verbose",
        dest="verbose",
        action="store_true",
        default=False,
        help="Turn on console debug messages",
    )

    parser.add_argument(
        "--quiet",
        dest="quiet",
        action="store_true",
        default=False,
        help="Turn off all console messages",
    )

    parser.add_argument(
        "-l",
        "--logging",
        dest="stdout_logging",
        default="info",
        type=str,
        help="Console logger verbosity",
    )

    parser.add_argument(
        "-f",
        "--file-logging",
        dest="file_logging",
        default="debug",
        type=str,
        help="File logger verbosity",
    )

    return parser.parse_args()


def main():
    """Main function

    Returns
        exit code, 0 in success any other integer in failure

    """
    global _log

    args = _parseArgs()

    if args.show_version:
        print(f"{_header}\nAuthor:   {_AUTHOR}\nVersion:  {_VERSION}")
        return 0

    stdout_level = args.stdout_logging if not args.verbose else "debug"
    file_level = args.file_logging if not args.verbose else "debug"

    stdout_level = stdout_level if not args.quiet else 0
    file_level = file_level if not args.quiet else 0

    _log = createLogger(
        stdout_level=_str_to_logging(stdout_level),
        file_level=_str_to_logging(file_level),
        color=args.color,
        filename=args.logfile,
    )

    # _log.debug('This is a DEBUG message')
    # _log.info('This is a INFO message')
    # _log.warning('This is a WARNing message')
    # _log.error('This is a ERROR message')

    errors = 0
    try:
        pass
    except (Exception, KeyboardInterrupt) as e:
        _log.exception(f"Halting due to {str(e.__class__.__name__)} exception")
        errors = 1

    return errors


if __name__ == "__main__":
    exit(main())
else:
    _log = createLogger(
        stdout_level=_str_to_logging("INFO"),
        file_level=_str_to_logging("DEBUG"),
        color=True,
        filename=_log_file,
    )
