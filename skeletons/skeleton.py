#!/usr/bin/env python

import argparse
import logging
import os
import sys
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
_MAIL = 'mickiller.25@gmail.com'

# _log = None
_log = logging.getLogger('MainLogger')
_log.setLevel(logging.DEBUG)
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_SCRIPTNAME = os.path.basename(__file__)
_log_file = os.path.splitext(_SCRIPTNAME)[0] + '.log'


def _createLogger(
        stdout_level: int = logging.INFO,
        file_level: int = logging.DEBUG,
        color: bool = True):
    """ Creaters logging obj

    stdout_level: int: logging level displayed into the terminal
    file_level: int: logging level saved into the logging file
    color: bool: Enable/Disable color console output

    """
    global _log

    try:
        from colorlog import ColoredFormatter as ColorFormatter
        Formatter = ColorFormatter
    except ImportError:
        ColorFormatter = None
        Formatter = logging.Formatter

    has_color = ColorFormatter is not None and color

    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(stdout_level)
    logformat = '{color}%(levelname)-8s | %(message)s'
    logformat = logformat.format(
        color='%(log_color)s' if has_color else '',
        # reset='%(reset)s' if has_color else '',
    )
    stdout_format = Formatter(logformat)
    stdout_handler.setFormatter(stdout_format)

    _log.addHandler(stdout_handler)

    if file_level > 0:

        with open(_log_file, 'a') as log:
            log.write(_header)
            # log.write(f'\nDate: {datetime.datetime.date()}')
            log.write(f'\nAuthor:   {_AUTHOR}\nContact:  {_MAIL}\nVersion:  {_VERSION}\n\n')

        file_handler = logging.FileHandler(filename=_log_file)
        file_handler.setLevel(file_level)
        file_format = logging.Formatter('%(levelname)-8s | %(filename)s: [%(funcName)s] - %(message)s')
        file_handler.setFormatter(file_format)

        _log.addHandler(file_handler)


def _str_to_logging(level: str):
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
            level = 99

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


def main():
    """ Main function
    :returns: TODO

    """
    args = _parseArgs()

    if args.show_version:
        print(f'{_header}\nAuthor:   {_AUTHOR}\nContact:  {_MAIL}\nVersion:  {_VERSION}')
        return 0

    stdout_level = _str_to_logging(args.stdout_logging)
    file_level = _str_to_logging(args.file_logging)
    _createLogger(
        stdout_level=stdout_level,
        file_level=file_level,
        color=args.no_color,
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
    pass
