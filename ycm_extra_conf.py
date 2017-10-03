#!/usr/bin/env python

from __future__ import unicode_literals
from __future__ import print_function
from __future__ import with_statement
from __future__ import division
import os
import os.path
import logging
# import fnmatch
# import ycm_core
# import re

__header__ = """

    Credits to https://jonasdevlieghere.com/a-better-youcompleteme-config/

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


BASE_FLAGS = [
    '-Wall',
    '-Wextra',
    '-Werror',
    '-Weverything',
    '-Wno-missing-prototypes',
    '-Wno-long-long',
    '-Wno-variadic-macros',
    '-fexceptions',
    '-ferror-limit=10000',
    '-DNDEBUG',
    # '-Wno-c++98-compat',
    # '-std=c++11',
    # '-xc++',
]

LINUX_INCLUDES = [
    '-I/usr/lib/',
    '-I/usr/include/'
]

WINDOWS_INCLUDES = [
    # TODO
]

SOURCE_EXTENSIONS = [
    '.cpp',
    '.cxx',
    '.cc',
    '.c',
    '.m',
    '.mm'
]

SOURCE_DIRECTORIES = [
    'src',
    'lib'
]

HEADER_EXTENSIONS = [
    '.h',
    '.hxx',
    '.hpp',
    '.hh'
]

HEADER_DIRECTORIES = [
    'include'
]

if os.name == 'nt':
    BASE_FLAGS += WINDOWS_INCLUDES
else:
    BASE_FLAGS += LINUX_INCLUDES


def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS


def FindNearest(path, target, build_folder):
    candidate = os.path.join(path, target)
    if(os.path.isfile(candidate) or os.path.isdir(candidate)):
        logging.info("Found nearest " + target + " at " + candidate)
        return candidate

    parent = os.path.dirname(os.path.abspath(path))
    if(parent == path):
        raise RuntimeError("Could not find " + target)

    if(build_folder):
        candidate = os.path.join(parent, build_folder, target)
        if(os.path.isfile(candidate) or os.path.isdir(candidate)):
            logging.info("Found nearest " + target +
                         " in build folder at " + candidate)
            return candidate

    return FindNearest(parent, target, build_folder)


def FlagsForClangComplete(root):
    try:
        clang_complete_path = FindNearest(root, '.clang_complete')
        clang_complete_flags = open(
            clang_complete_path, 'r').read().splitlines()

        clang_complete_path = FindNearest(root, '.clang')
        clang_complete_flags += open(clang_complete_path,
                                     'r').read().splitlines()
        return clang_complete_flags
    except:
        return None


def FlagsForInclude(root):
    try:
        include_path = FindNearest(root, 'include')
        flags = []
        for dirroot, dirnames, filenames in os.walk(include_path):
            for dir_path in dirnames:
                real_path = os.path.join(dirroot, dir_path)
                flags = flags + ["-I" + real_path]
        return flags
    except:
        return None


def FlagsForFile(filename):
    root = os.path.realpath(filename)
    final_flags = BASE_FLAGS
    clang_flags = FlagsForClangComplete(root)
    if clang_flags:
        final_flags = final_flags + clang_flags
    include_flags = FlagsForInclude(root)
    if include_flags:
        final_flags = final_flags + include_flags
    return {
        'flags': final_flags,
        'do_cache': True
    }
