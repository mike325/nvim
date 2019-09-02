#!/usr/bin/env python

from __future__ import print_function
from __future__ import division
from __future__ import unicode_literals
from __future__ import with_statement

import argparse
import logging
# import os
# import sys
# import platform

__header__ = """
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

_version = '0.1.0'
_author = 'Mike'
_mail = 'mickiller.25@gmail.com'


def _parseArgs():
    """ Parse CLI arguments
    :returns: argparse.ArgumentParser class instance

    """
    parser = argparse.ArgumentParser()

    parser.add_argument('--version',
                        dest='show_version',
                        action='store_true',
                        help='print script version and exit')

    parser.add_argument('-l',
                        '--logging',
                        dest='logging',
                        default="INFO",
                        type=str,
                        help='Enable debug messages')

    return parser.parse_args()


def main():
    """ Main function
    :returns: TODO

    """
    args = _parseArgs()

    if args.show_version:
        print(_version)
        return 0

    if args.logging:
        try:
            level = int(args.logging)
        except Exception:
            if args.logging.lower() == "debug":
                level = logging.DEBUG
            elif args.logging.lower() == "info":
                level = logging.INFO
            elif args.logging.lower() == "warn" or args.logging.lower() == "warning":
                level = logging.WARN
            elif args.logging.lower() == "error":
                level = logging.ERROR
            elif args.logging.lower() == "critical":
                level = logging.CRITICAL
            else:
                level = 0

    logging.basicConfig(level=level, format='[%(levelname)s] - %(message)s')

    return 0


if __name__ == "__main__":
    main()
else:
    pass
