#!/usr/bin/env python

from __future__ import unicode_literals
from __future__ import print_function
from __future__ import with_statement
from __future__ import division

# from distutils.sysconfig import get_python_inc

import os
import os.path
import logging
import ycm_core

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
    '-x',
    'c++',
]

LINUX_INCLUDES = [
    '-I/usr/lib/',
    '-I/usr/include/'
]

WINDOWS_INCLUDES = [
    # TODO
]

SOURCE_EXTENSIONS = ['.cpp', '.cxx', '.cc', '.c', '.m', '.mm', '.s']
HEADER_EXTENSIONS = ['.h', '.hxx', '.hpp', '.hh']
SOURCE_DIRECTORIES = ['src', 'lib']
HEADER_DIRECTORIES = ['include']
DIR_OF_THIS_SCRIPT = os.path.abspath(os.path.dirname(__file__))

# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# You can get CMake to generate this file for you by adding:
#   set( CMAKE_EXPORT_COMPILE_COMMANDS 1 )
# to your CMakeLists.txt file.
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags. Notice that YCM itself uses that approach.
compilation_database_folder = ''

if os.path.exists(compilation_database_folder):
    database = ycm_core.CompilationDatabase(compilation_database_folder)
else:
    database = None

if os.name == 'nt':
    BASE_FLAGS += WINDOWS_INCLUDES
else:
    BASE_FLAGS += LINUX_INCLUDES


def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS


def FindCorrespondingSourceFile(filename):
    if IsHeaderFile(filename):
        basename = os.path.splitext(filename)[0]
        for extension in SOURCE_EXTENSIONS:
            replacement_file = basename + extension
        if os.path.exists(replacement_file):
            return replacement_file
    return filename


def FindNearest(path, target, build_folder):
    candidate = os.path.join(path, target)
    if os.path.isfile(candidate) or os.path.isdir(candidate):
        logging.info("Found nearest {0} at {1}".format(target, candidate))
        return candidate

    parent = os.path.dirname(os.path.realpath(path))
    if (parent == path):
        raise RuntimeError("Could not find " + target)

    if (build_folder):
        candidate = os.path.join(parent, build_folder, target)
        if os.path.isfile(candidate) or os.path.isdir(candidate):
            logging.info("Found nearest {0} in build folder at {1}".format(target, candidate))
            return candidate

    return FindNearest(parent, target, build_folder)


def FlagsForClangComplete(root):
    try:
        clang_complete_path = FindNearest(root, '.clang_complete', None)
        with open(clang_complete_path, 'r') as flags:
            clang_complete_flags = flags.read().splitlines()

        clang_complete_path = FindNearest(root, '.clang', None)
        with open(clang_complete_path, 'r') as flags:
            clang_complete_flags += flags.read().splitlines()

        return clang_complete_flags
    except:
        return None


def FlagsForInclude(root):
    try:
        include_path = FindNearest(root, 'include')
        flags = []
        for dirroot, dirnames, filenames in os.walk(include_path):
            for dir_path in dirnames:
                real_path = os.path.realpath(os.path.join(dirroot, dir_path))
                flags += ["-I" + real_path]
        return flags
    except:
        return None


def Settings(**kwargs):
    language = kwargs['language']
    if language == 'python':
        return {
            'interpreter_path': '~/project/virtual_env/bin/python',
            'sys_path': ['~/project/third_party/module']
        }
    return {}


def FlagsForFile(filename, **kwargs):
    # If the file is a header, try to find the corresponding source file and
    # retrieve its flags from the compilation database if using one. This is
    # necessary since compilation databases don't have entries for header files.
    # In addition, use this source file as the translation unit. This makes it
    # possible to jump from a declaration in the header file to its definition in
    # the corresponding source file.
    filename = FindCorrespondingSourceFile(filename)

    if not database:
        root = os.path.realpath(filename)
        final_flags = BASE_FLAGS
        clang_flags = FlagsForClangComplete(root)
        if clang_flags:
            final_flags += clang_flags
        include_flags = FlagsForInclude(root)
        if include_flags:
            final_flags += include_flags
        return {
            'flags': final_flags,
            'do_cache': True
            'override_filename': filename
        }

    compilation_info = database.GetCompilationInfoForFile(filename)
    if not compilation_info.compiler_flags_:
        return None

    # Bear in mind that compilation_info.compiler_flags_ does NOT return a
    # python list, but a "list-like" StringVec object.
    final_flags = list(compilation_info.compiler_flags_)
    return {
        'flags': final_flags,
        'include_paths_relative_to_dir': compilation_info.compiler_working_dir_,
        'override_filename': filename
        'do_cache': True
    }
