#!/usr/bin/env python

from __future__ import unicode_literals
from __future__ import print_function
from __future__ import with_statement
from __future__ import division

# from distutils.sysconfig import get_python_inc

import os
import os.path as p
import sys
import logging
try:
    import ycm_core

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

    database = None
    if p.exists(compilation_database_folder):
        database = ycm_core.CompilationDatabase(compilation_database_folder)
except ImportError:
    compilation_database_folder = ''
    database = None

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
    '-Wno-c++98-compat',
    '-std=c++17',
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
DIR_OF_THIS_SCRIPT = p.abspath(p.dirname(__file__))

if os.name == 'nt':
    BASE_FLAGS += WINDOWS_INCLUDES
else:
    BASE_FLAGS += LINUX_INCLUDES


def IsHeaderFile(filename):
    extension = p.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS


def FindCorrespondingSourceFile(filename):
    if IsHeaderFile(filename):
        basename = p.splitext(filename)[0]
        for extension in SOURCE_EXTENSIONS:
            replacement_file = basename + extension
        if p.exists(replacement_file):
            return replacement_file
    return filename


def FindNearest(path, target, build_folder=None):
    candidate = p.join(path, target)
    if p.isfile(candidate) or p.isdir(candidate):
        logging.info("Found nearest {0} at {1}".format(target, candidate))
        return candidate

    parent = p.dirname(p.realpath(path))
    if (parent == path):
        raise RuntimeError("Could not find " + target)

    if (build_folder):
        candidate = p.join(parent, build_folder, target)
        if p.isfile(candidate) or p.isdir(candidate):
            logging.info("Found nearest {0} in build folder at {1}".format(target, candidate))
            return candidate

    return FindNearest(parent, target, build_folder)


def FlagsForClangComplete(root):
    try:
        clang_complete_path = FindNearest(root, '.clang_complete')
        with open(clang_complete_path, 'r') as flags:
            clang_complete_flags = flags.read().splitlines()

        clang_complete_path = FindNearest(root, '.clang')
        with open(clang_complete_path, 'r') as flags:
            clang_complete_flags += flags.read().splitlines()

        return clang_complete_flags
    except RuntimeError:
        return None


def FlagsForInclude(root):
    try:
        include_path = FindNearest(root, 'include')
        flags = []
        for dirroot, dirnames, filenames in os.walk(include_path):
            for dir_path in dirnames:
                real_path = p.realpath(p.join(dirroot, dir_path))
                flags += ["-I" + real_path]
        return flags
    except RuntimeError:
        return None


def Settings(**kwargs):
    language = kwargs['language'] if 'language' in kwargs else ''
    if language == 'cfamily':
        # If the file is a header, try to find the corresponding source file and
        # retrieve its flags from the compilation database if using one. This is
        # necessary since compilation databases don't have entries for header files.
        # In addition, use this source file as the translation unit. This makes it
        # possible to jump from a declaration in the header file to its definition in
        # the corresponding source file.
        filename = FindCorrespondingSourceFile(kwargs['filename'])

        csetup = {
            "override_filename": filename,
            "do_cache": True,
        }

        if database:
            compilation_info = database.GetCompilationInfoForFile(filename)
            if not compilation_info.compiler_flags_:
                return None

            # Bear in mind that compilation_info.compiler_flags_ does NOT return a
            # python list, but a "list-like" StringVec object.
            final_flags = list(compilation_info.compiler_flags_)
            csetup["flags"] = final_flags
            csetup["include_paths_relative_to_dir"] = compilation_info.compiler_working_dir_
        else:
            root = p.realpath(filename)
            final_flags = BASE_FLAGS
            clang_flags = FlagsForClangComplete(root)
            if clang_flags:
                final_flags += clang_flags
            include_flags = FlagsForInclude(root)
            if include_flags:
                final_flags += include_flags

            csetup["flags"] = final_flags

        return csetup

    elif language == 'python':
        pysetup = {
            "interpreter_path": sys.executable,
        }

        if p.isdir(p.abspath(p.join(DIR_OF_THIS_SCRIPT, "env"))):
            virtualenv = p.abspath(p.join(DIR_OF_THIS_SCRIPT, "env"))
            pysetup["interpreter_path"] = virtualenv

        if p.isdir(p.abspath(p.join(DIR_OF_THIS_SCRIPT, "third_party/module"))):
            pypath = p.abspath(p.join(DIR_OF_THIS_SCRIPT, "third_party/module"))
            pysetup["sys_path"] = pypath

        return pysetup

    return {}


# def PythonSysPath(**kwargs):
#     """
#
#     Customize Python sys path, this function may be call after Settings()
#
#     :kwargs: Dict, Has all extra data passed from (n)vim instance likeL
#         - client_data
#         - sys_path
#         - language
#     :returns: Dict, the resturn dictionary should have one or more of the folloing
#                     keys
#         - interpreter_path:
#             (Optionale) Str
#                 The python interpeter path
#         - sys_path:
#             (Optional) List
#                 The paths to append to the current sys path
#     """
#     pass


# NOTE: deprecated, Kept for backward compatibility
# Use Settings instead
# https://github.com/Valloric/ycmd/commit/66030cd94299114ae316796f3cad181cac8a007c
def FlagsForFile(filename, **kwargs):
    """ DEPRECATED

    Resolve compilation flags for every C/C++ files

    :filename: Str, The abspath of the current file
    :kwargs: Dict, Has all extra data passed from (n)vim instance like client_data
    :returns: Dict, the resturn dictionary should have one or more of the folloing
                    keys
        - flags:
            (Mandatory) List
                The complete compiler flags for the current file
        - include_paths_relative_to_dir:
            (Optional) Str
                Directory to which the include paths in the list are relative
            Default: ycmd working directory
        - override_filename:
            (Optional) Str
                The filename to parse as the translation unit for the given filename
        - do_cache:
            (Optional) Boolean
                Indicate whether or not the result of this call should be cached
                for this filename
            Default: True
        - flags_ready:
            (Optional) Boolean
                Indicaes that the flags are ready to use
            Default: True

    """

    extension = p.splitext(filename)[1]
    if extension in HEADER_EXTENSIONS or extension in SOURCE_EXTENSIONS:
        language = kwargs.get("language", "cfamily")
    else:
        language = kwargs.get("language", "")

    if "client_data" in kwargs:
        return Settings(filename=filename, language=language, client_data=kwargs["client_data"])

    return Settings(filename=filename, language=language)
