#!/usr/bin/env python3

# from datetime import datetime
import argparse
import logging
import os
import re
import subprocess
import sys
from collections import namedtuple
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Sequence, TextIO, Union, cast

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

__version__ = "0.1.0"
__author__ = "Mike"

_log: logging.Logger
# _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_SCRIPTNAME: str = os.path.basename(__file__)
_log_file: Optional[str] = os.path.splitext(_SCRIPTNAME)[0] + ".log"

_has_colors: bool = True
_verbose: bool = False
# _is_windows = os.name == 'nt'
# _home = os.environ['USERPROFILE' if _is_windows else 'HOME']

Colors = namedtuple(
    "Colors",
    [
        "grey",
        "green",
        "magenta",
        "purple",
        "blue",
        "yellow",
        "red",
        "bold_white",
        "bold_red",
        "reset",
    ],
)

COLOR = Colors(
    grey="\x1b[38;21m",
    green="\x1b[32m",
    magenta="\x1b[35m",
    purple="\x1b[35m",
    blue="\x1b[44;1m",
    yellow="\x1b[38;5;226m",
    red="\x1b[38;5;196m",
    bold_white="\x1b[37;1m",
    bold_red="\x1b[31;1m",
    reset="\x1b[0m",
)


def color_str(msg: Any, color: str, bg: Optional[str] = None) -> str:
    if _has_colors:
        return "{color}{bg}{msg}{reset}".format(
            color=color, bg=bg if bg is not None else "", msg=msg, reset=COLOR.reset
        )
    return msg if isinstance(msg, str) else str(msg)


def clear_list(str_list: List[str]) -> List[str]:
    tmp = []
    empty_str = re.compile(r"^\s*$")
    for i in str_list:
        if i and not empty_str.match(i):
            tmp.append(i)
    return tmp


def uniq_list(duplicates: List[Any]) -> List[Any]:
    return list(set(duplicates))


def merge_uniq(src: List[Any], dest: List[Any]) -> List[Any]:
    tmp_src = set(src)
    tmp_dest = set(dest)
    return list(tmp_src.union(tmp_dest))


@dataclass
class Job:
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
        # NOTE: Python 3.6 does not support text= arg
        # process = subprocess.Popen(self.cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=cwd)
        self.pid = process.pid

        self.stdout = []
        self.stderr = []

        while True:
            stdout = cast(TextIO, process.stdout).readline()
            stderr = cast(TextIO, process.stderr).readline()
            # if (stdout == b"" and stderr == b"") and process.poll() is not None: # for python 3.6
            if (stdout == "" and stderr == "") and process.poll() is not None:
                break
            elif stdout:
                # stdout = stdout.rstrip().decode("utf-8") # python 3.6
                stdout = stdout.strip().replace("\n", "")
                self.stdout.append(stdout)
                if background:
                    _log.debug(stdout)
                else:
                    _log.info(stdout)
            elif stderr:
                # stderr = stderr.rstrip().decode("utf-8") # python 3.6
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
) -> logging.Logger:
    """Creates logging obj

    Args:
        stdout_level (int): = logging.INFO, logging level displayed into the terminal
        file_level (int): = logging.DEBUG, logging level saved into the logging file
        color (bool): = True, Enable/Disable color console output
        filename (Optional[str]): = "dummy.log", Location of the logging file
        name (str): = "MainLogger", Name of the logger object

    Returns:
        Logger with file and tty handlers

    """
    global _has_colors

    _has_colors = color

    logger = logging.getLogger(name)
    if len(logger.handlers) > 0:
        return logger
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

            def __init__(self, fmt, log_colors: Optional[Dict[str, str]] = None):
                global _has_colors

                super().__init__()
                self.fmt = fmt

                self.FORMATS = {}
                if _has_colors:
                    log_colors = log_colors if log_colors is not None else {}

                    log_colors["DEBUG"] = log_colors.get("DEBUG", COLOR.magenta)
                    log_colors["INFO"] = log_colors.get("INFO", COLOR.green)
                    log_colors["WARNING"] = log_colors.get("WARNING", COLOR.yellow)
                    log_colors["ERROR"] = log_colors.get("ERROR", COLOR.red)
                    log_colors["CRITICAL"] = log_colors.get("CRITICAL", COLOR.bold_red)

                    self.FORMATS[logging.DEBUG] = log_colors["DEBUG"] + self.fmt + COLOR.reset
                    self.FORMATS[logging.INFO] = log_colors["INFO"] + self.fmt + COLOR.reset
                    self.FORMATS[logging.WARNING] = log_colors["WARNING"] + self.fmt + COLOR.reset
                    self.FORMATS[logging.ERROR] = log_colors["ERROR"] + self.fmt + COLOR.reset
                    self.FORMATS[logging.CRITICAL] = log_colors["CRITICAL"] + self.fmt + COLOR.reset
                else:
                    self.FORMATS[logging.DEBUG] = self.fmt
                    self.FORMATS[logging.INFO] = self.fmt
                    self.FORMATS[logging.WARNING] = self.fmt
                    self.FORMATS[logging.ERROR] = self.fmt
                    self.FORMATS[logging.CRITICAL] = self.fmt

            def format(self, record):
                log_fmt = self.FORMATS.get(record.levelno)
                formatter = logging.Formatter(log_fmt)
                return formatter.format(record)

        Formatter = PrimitiveFormatter

    # This means both 0 and 100 silence all output
    stdout_level = 100 if stdout_level == 0 else stdout_level

    has_color_formatter = ColorFormatter is not None and color

    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(stdout_level)
    logformat = "{color}%(levelname)-8s | %(message)s"
    logformat = logformat.format(
        color="%(log_color)s" if has_color_formatter else "",
        # reset='%(reset)s' if has_color_formatter else '',
    )
    stdout_format = Formatter(
        logformat,
        log_colors={
            "DEBUG": COLOR.purple,
            "INFO": COLOR.green,
            "WARNING": COLOR.yellow,
            "ERROR": COLOR.red,
            "CRITICAL": COLOR.bold_red,
        },
    )
    stdout_handler.setFormatter(stdout_format)

    logger.addHandler(stdout_handler)

    if file_level > 0 and file_level < 100 and filename is not None:
        with open(filename, "a") as log:
            log.write(_header)
            # log.write(f'\nDate: {datetime.datetime.date()}')
            log.write(f"\nAuthor:   {__author__}\nVersion:  {__version__}\n\n")

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
        def __call__(self, parser, namespace, values, option_string=None):
            if option_string is not None and len(option_string) < 4:
                setattr(namespace, self.dest, True)
            else:
                setattr(namespace, self.dest, option_string[2:4] != "no")

    class NegateActionWithArg(argparse.Action):
        def __call__(self, parser, namespace, values, option_string=None):
            if option_string is not None and len(option_string) < 4:
                setattr(namespace, self.dest, True if values is None or values == "" else values)
            elif option_string[2:4] == "no":
                setattr(namespace, self.dest, False)
            else:
                setattr(namespace, self.dest, values)

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
        action=NegateActionWithArg,
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
        "-v",
        "--verbose",
        dest="verbose",
        action="store_true",
        default=False,
        help="Turn on console debug messages",
    )

    parser.add_argument(
        "-q",
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
    global _log, _has_colors

    args = _parseArgs()

    if args.show_version:
        print(f"{_header}\nAuthor:   {__author__}\nVersion:  {__version__}")
        return 0

    stdout_level = args.stdout_logging if not args.verbose else "debug"
    file_level = args.file_logging if not args.verbose else "debug"

    stdout_level = stdout_level if not args.quiet else 0
    file_level = file_level if not args.quiet else 0

    _has_colors = args.color

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
