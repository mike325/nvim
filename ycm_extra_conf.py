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
import re
try:
    import ycm_core
except ImportError:
    logging.warn('No ycm_core module found')

__DEBUG = True

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

LINUX_INCLUDES = ['-I/usr/lib/', '-I/usr/include/']

WINDOWS_INCLUDES = [
    # TODO
]

SOURCE_EXTENSIONS = [
    '.cpp',
    '.cxx',
    '.cc',
    '.c',
    '.s',
    '.m',
    '.mm',
]

SOURCE_DIRECTORIES = ['src', 'lib']

HEADER_EXTENSIONS = ['.h', '.hxx', '.hpp', '.hh']

HEADER_DIRECTORIES = ['include']

DIR_OF_THIS_SCRIPT = p.abspath(p.dirname(__file__))

if os.name == 'nt':
    BASE_FLAGS += WINDOWS_INCLUDES
else:
    BASE_FLAGS += LINUX_INCLUDES


COMPILE_DB = [
    'compile_commands.json',
]


def GetCompilationDatabase():
    """TODO: Docstring for GetCompilationDatabase.
    :returns: TODO

    """
    cwd = os.getcwd()
    compilation_database_folder = ''
    parent = p.abspath(p.join(cwd, '..'))

    logging.info('CWD: {0}, Parent: {1}'.format(cwd, parent))

    while cwd != parent:
        files = os.listdir(cwd)
        if 'compile_commands.json' in files:
            compilation_database_folder = cwd
            logging.info('Database found {0}'.format(compilation_database_folder))
            break
        cwd = parent
        parent = p.abspath(p.join(cwd, '..'))
        logging.info('CWD: {0}, Parent: {1}'.format(cwd, parent))

    if compilation_database_folder == '':
        logging.info('No compilation database found')

    return compilation_database_folder


def NormalizePath(path):
    """TODO: Docstring for NormalizePath.

    :path: TODO
    :returns: TODO

    """
    return path if os.name != 'nt' else path.replace('\\', '/')


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


def PathToPythonUsedDuringBuild():
    try:
        filepath = p.join(DIR_OF_THIS_SCRIPT, 'python_version.txt')
        with open(filepath) as f:
            return f.read().strip()
        # We need to check for IOError for Python 2 and OSError for Python 3.
    except (IOError, OSError):
        return sys.executable


def GetStandardLibraryIndexInSysPath(sys_path):
    for index, path in enumerate(sys_path):
        if p.isfile(p.join(path, 'os.py')):
            return index
    raise RuntimeError('Could not find standard library path in Python path.')


def PythonSysPath(**kwargs):
    sys_path = kwargs['sys_path']

    home = 'HOME' if os.name != 'nt' else 'USERPROFILE'
    home = NormalizePath(os.environ[home])

    # interpreter_path = kwargs['interpreter_path']
    # major_version = subprocess.check_output([
    #     interpreter_path, '-c', 'import sys; print(sys.version_info[0])']
    # ).rstrip().decode('utf8')

    return sys_path


def Settings(**kwargs):
    language = kwargs['language']
    client_data = None if 'client_data' not in kwargs else kwargs['client_data']

    if language == 'cfamily':
        # If the file is a header, try to find the corresponding source file and
        # retrieve its flags from the compilation database if using one. This is
        # necessary since compilation databases don't have entries for header files.
        # In addition, use this source file as the translation unit. This makes it
        # possible to jump from a declaration in the header file to its definition
        # in the corresponding source file.
        logging.info('Looking for {0}'.format(kwargs['filename']))
        filename = FindCorrespondingSourceFile(kwargs['filename'])
        logging.info('Got {0}'.format(filename))

        if not database:
            logging.info('Database is empty, usging defualt flags')
            return {
                'flags': BASE_FLAGS,
                'include_paths_relative_to_dir': DIR_OF_THIS_SCRIPT,
                'override_filename': filename,
                'do_cache': True,
            }

        compilation_info = database.GetCompilationInfoForFile(filename)
        if not compilation_info.compiler_flags_:
            logging.info('No flags for {0}'.format(filename))
            return {}

        # Bear in mind that compilation_info.compiler_flags_ does NOT return a
        # python list, but a "list-like" StringVec object.
        final_flags = list(compilation_info.compiler_flags_)

        return {
            'flags': final_flags,
            'include_paths_relative_to_dir': compilation_info.compiler_working_dir_,
            'override_filename': filename,
            'do_cache': True,
        }

    if language == 'python':
        if client_data is not None and 'g:ycm_python_interpreter_path' in client_data:
            pypath = client_data['g:ycm_python_interpreter_path']
        else:
            pypath = PathToPythonUsedDuringBuild()

        logging.info('Using {0} as python interpeter'.format(pypath))

        return {
            'interpreter_path': pypath
        }

    return {}


def FlagsForFile(filename, **kwargs):
    """ DEPRECATED in favor of 'Settings' function

        Resolve compilation flags for every C/C++ files
    """
    settings = kwargs
    settings['filename'] = filename

    if 'language' not in settings:
        settings['language'] = ''

        extension = p.splitext(settings['filename'])[1]

        if extension in SOURCE_EXTENSIONS or extension in HEADER_EXTENSIONS:
            settings['language'] = 'cfamily'
        elif extension == 'py':
            settings['language'] = 'python'

    return Settings(**settings)


database = None
compilation_database_folder = GetCompilationDatabase()
if p.exists(compilation_database_folder):
    database = ycm_core.CompilationDatabase(compilation_database_folder)
