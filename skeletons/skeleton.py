#!/usr/bin/env python3

import argparse
import logging
import os
import sys
from typing import Union
# from subprocess import PIPE, Popen
# from datetime import datetime

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

_VERSION = '0.1.0'
_AUTHOR = 'Mike'

_log = None
# _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_SCRIPTNAME = os.path.basename(__file__)
_log_file = os.path.splitext(_SCRIPTNAME)[0] + '.log'


def _createLogger(
        stdout_level: int = logging.INFO,
        file_level: int = logging.DEBUG,
        color: bool = True,
        filename: str = 'dummy.log',
        name: str = 'MainLogger'
    ):
    """ Creaters logging obj

    stdout_level: int: logging level displayed into the terminal
    file_level: int: logging level saved into the logging file
    color: bool: Enable/Disable color console output

    """
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)

    try:
        from colorlog import ColoredFormatter as ColorFormatter
        Formatter = ColorFormatter
    except ImportError:
        ColorFormatter = None

        class PrimitiveFormatter(logging.Formatter):
            """Logging colored formatter, adapted from https://stackoverflow.com/a/56944256/3638629"""

            def __init__(self, fmt, log_colors=None):
                super().__init__()
                self.fmt = fmt

                colors = {
                    'grey': '\x1b[38;21m',
                    'green': '\x1b[32m',
                    'magenta': '\x1b[35m',
                    'purple': '\x1b[35m',
                    'blue': '\x1b[38;5;39m',
                    'yellow': '\x1b[38;5;226m',
                    'red': '\x1b[38;5;196m',
                    'bold_red': '\x1b[31;1m',
                    'reset': '\x1b[0m',
                }

                if log_colors is None:
                    log_colors = {}

                log_colors['DEBUG'] = log_colors['DEBUG'] if 'DEBUG' in log_colors else 'magenta'
                log_colors['INFO'] = log_colors['INFO'] if 'INFO' in log_colors else 'green'
                log_colors['WARNING'] = log_colors['WARNING'] if 'WARNING' in log_colors else 'yellow'
                log_colors['ERROR'] = log_colors['ERROR'] if 'ERROR' in log_colors else 'red'
                log_colors['CRITICAL'] = log_colors['CRITICAL'] if 'CRITICAL' in log_colors else 'bold_red'

                self.FORMATS = {
                    logging.DEBUG: colors[log_colors['DEBUG']] + self.fmt + colors['reset'],
                    logging.INFO: colors[log_colors['INFO']] + self.fmt + colors['reset'],
                    logging.WARNING: colors[log_colors['WARNING']] + self.fmt + colors['reset'],
                    logging.ERROR: colors[log_colors['ERROR']] + self.fmt + colors['reset'],
                    logging.CRITICAL: colors[log_colors['CRITICAL']] + self.fmt + colors['reset']
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
    logformat = '{color}%(levelname)-8s | %(message)s'
    logformat = logformat.format(
        color='%(log_color)s' if has_color else '',
        # reset='%(reset)s' if has_color else '',
    )
    stdout_format = Formatter(logformat, log_colors={
        'DEBUG': 'purple',
        'INFO': 'green',
        'WARNING': 'yellow',
        'ERROR': 'red',
        'CRITICAL': 'red',
    })
    stdout_handler.setFormatter(stdout_format)

    logger.addHandler(stdout_handler)

    if file_level > 0 and file_level < 100:

        with open(filename, 'a') as log:
            log.write(_header)
            # log.write(f'\nDate: {datetime.datetime.date()}')
            log.write(f'\nAuthor:   {_AUTHOR}\nVersion:  {_VERSION}\n\n')

        file_handler = logging.FileHandler(filename=filename)
        file_handler.setLevel(file_level)
        file_format = logging.Formatter('%(levelname)-8s | %(filename)s: [%(funcName)s] - %(message)s')
        file_handler.setFormatter(file_format)

        logger.addHandler(file_handler)

    return logger


def _str_to_logging(level: Union[int, str]) -> int:
    """ Convert logging level string to a logging number

    :level: str: integer representation or a valid logging string
                - debug/verbose
                - info
                - warn/warning
                - error
                - critical
            All non valid integer or logging strings defaults to 0 logging
    :returns: int: logging level from the given string

    """

    if isinstance(level, int):
        level = abs(level - 100)
    elif isinstance(level, str):
        try:
            level = abs(int(level) - 100)
        except Exception:
            level = level.lower()
            if level == "debug" or level == 'verbose':
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
    """ Parse CLI arguments
    :returns: argparse.ArgumentParser class instance

    """
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--version',
        dest='show_version',
        action='store_true',
        help='print script version and exit',
    )

    parser.add_argument(
        '--verbose',
        dest='verbose',
        action='store_true',
        default=False,
        help='Turn on Debug messages',
    )

    parser.add_argument(
        '--quiet',
        dest='quiet',
        action='store_true',
        default=False,
        help='Turn off all messages',
    )

    parser.add_argument(
        '-l',
        '--logging',
        dest='stdout_logging',
        default="info",
        type=str,
        help='File logger verbosity',
    )

    parser.add_argument(
        '-f',
        '--file-logging',
        dest='file_logging',
        default='debug',
        type=str,
        help='File logger verbosity'
    )

    parser.add_argument(
        '--no-color',
        dest='no_color',
        action='store_false',
        help='Disable colored output'
    )

    return parser.parse_args()


# def _execute(cmd: list, background: bool):
#     """ Execute a synchronous command
#     :cmd: list: command to execute
#     :returns: Popen obj: command object after execution
#     """
#     stdout = sys.stdout if not background else PIPE
#     stderr = sys.stderr if not background else PIPE
#     _log.debug(f'Executing cmd: {cmd}')
#     cmd_obj = Popen(cmd, stdout=stdout, stderr=stderr, text=True)
#     out, err = cmd_obj.communicate()
#     if out is not None and len(out) > 0:
#         _log.debug(out)
#     if cmd_obj.returncode != 0:
#         _log.error(f'Command exited with {cmd_obj.returncode}')
#         if err is not None:
#             _log.error(err)
#     return cmd_obj


def main():
    """ Main function
    :returns: int: exit code, 0 in success any other integer in failure

    """
    global _log

    args = _parseArgs()

    if args.show_version:
        print(f'{_header}\nAuthor:   {_AUTHOR}\nVersion:  {_VERSION}')
        return 0

    stdout_level = args.stdout_logging if not args.verbose else 'debug'
    file_level = args.file_logging if not args.verbose else 'debug'

    stdout_level = stdout_level if not args.quiet else 0
    file_level = file_level if not args.quiet else 0

    _log = _createLogger(
        stdout_level=_str_to_logging(stdout_level),
        file_level=_str_to_logging(file_level),
        color=args.no_color,
        filename=_log_file,
    )

    # _log.debug('This is a DEBUG message')
    # _log.info('This is a INFO message')
    # _log.warning('This is a WARNing message')
    # _log.error('This is a ERROR message')

    errors = 0
    try:
        pass
    except (Exception, KeyboardInterrupt) as e:
        _log.exception(f'Halting due to {str(e.__class__.__name__)} exception')
        errors = 1

    return errors


if __name__ == "__main__":
    exit(main())
else:
    _log = _createLogger(
        stdout_level=_str_to_logging('INFO'),
        file_level=_str_to_logging('DEBUG'),
        color=True,
        filename=_log_file,
    )
