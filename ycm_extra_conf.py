#!/usr/bin/env python3

import logging
import os
import sys
from typing import List

import ycm_core

# Logger for additional logging.
# To enable debug logging, add `let g:ycm_server_log_level = 'debug'` to
# your .vimrc file.
logger = logging.getLogger("ycm_extra_conf")

# This is the list of all directories to search for header files.
# Dirs in this list can be paths relative to this file, absolute
# paths, or paths relative to the user (using ~/path/to/file).
libDirs = [
    "lib",
    "include",
    # Include paths where project libraries live, like Qt paths or where libraries
    # are download
]

flags = [
    # "-std=c++20",
    "-O2",
    "-Wall",
    "-Wextra",
    "-Wno-c++98-compat",
    "-Wshadow",
    "-Wnon-virtual-dtor",
    "-Wold-style-cast",
    "-Wcast-align",
    "-Wunused",
    "-Woverloaded-virtual",
    "-Wpedantic",
    "-Wconversion",
    "-Wsign-conversion",
    "-Wnull-dereference",
    "-Wdouble-promotion",
    "-Wmisleading-indentation",
    "-Wduplicated-cond",
    "-Wduplicated-branches",
    "-Wlogical-op",
    "-Wuseless-cast",
    "-Wformat=2",
]

# Make this more dynamic
LINUX_INCLUDES = ["-I/usr/lib/", "-I/usr/include/"]

WINDOWS_INCLUDES: List[str] = [
    # TODO
]

SOURCE_EXTENSIONS = [
    ".cpp",
    ".cxx",
    ".cc",
    ".c",
    ".s",
    ".ino",
    ".m",
    ".mm",
]

SOURCE_DIRECTORIES = [
    "src",
]

HEADER_EXTENSIONS = [
    ".h",
    ".hxx",
    ".hpp",
    ".hh",
]

flags += WINDOWS_INCLUDES if os.name == "nt" else LINUX_INCLUDES

database = None
compilation_database_folder = ""

# Check the directory where 'compile_commands.json' live
if os.path.exists(compilation_database_folder):
    database = ycm_core.CompilationDatabase(compilation_database_folder)
else:
    database = None


def DirectoryOfThisScript():
    return os.path.dirname(os.path.abspath(__file__))


def MakeRelativePathsInFlagsAbsolute(working_directory):
    if not working_directory:
        return list(flags)

    new_flags = []
    make_next_absolute = False
    path_flags = ["-isystem", "-I", "-iquote", "--sysroot="]

    for libDir in libDirs:
        # dir is relative to $HOME
        if libDir.startswith("~"):
            libDir = os.path.expanduser(libDir)

        # dir is relative to `working_directory`
        if not libDir.startswith("/"):
            libDir = os.path.join(working_directory, libDir)

        # Else, assume dir is absolute

        for path, _, files in os.walk(libDir):
            # Add to flags if dir contains a header file and is not
            # one of the metadata dirs (examples and extras).
            if any(IsHeaderFile(x) for x in files) and path.find("examples") == -1 and path.find("extras") == -1:
                logger.info(f"Directory contains header files - {path}")
                flags.append("-I" + path)

    for flag in flags:
        new_flag = flag

        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith("/"):
                new_flag = os.path.join(working_directory, flag)

        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break

            if flag.startswith(path_flag):
                path = flag[len(path_flag) : :]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

        if new_flag:
            new_flags.append(new_flag)
    return new_flags


def NormalizePath(path):
    return path if os.name != "nt" else path.replace("\\", "/")


def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS


def GetCompilationInfoForFile(filename):
    # The compilation_commands.json file generated by CMake does not have entries
    # for header files. So we do our best by asking the db for flags for a
    # corresponding source file, if any. If one exists, the flags for that file
    # should be good enough.
    if IsHeaderFile(filename):
        basename = os.path.splitext(filename)[0]
        for extension in SOURCE_EXTENSIONS:
            replacement_file = basename + extension
            if os.path.exists(replacement_file):
                compilation_info = database.GetCompilationInfoForFile(replacement_file)
                if compilation_info.compiler_flags_:
                    return compilation_info
        return None
    return database.GetCompilationInfoForFile(filename)


def PathToPythonUsedDuringBuild():
    filepath = os.path.join(DirectoryOfThisScript(), "python_version.txt")
    if os.path.isfile(filepath):
        with open(filepath) as f:
            return f.read().strip()
    return sys.executable


def Settings(**kwargs):
    language = kwargs["language"]
    filename = kwargs["filename"]
    client_data = kwargs.get("client_data", None)

    if language == "cfamily":
        # If the file is a header, try to find the corresponding source file and
        # retrieve its flags from the compilation database if using one. This is
        # necessary since compilation databases don't have entries for header files.
        # In addition, use this source file as the translation unit. This makes it
        # possible to jump from a declaration in the header file to its definition
        # in the corresponding source file.
        if database:
            # Bear in mind that compilation_info.compiler_flags_ does NOT return a
            # python list, but a "list-like" StringVec object
            compilation_info = GetCompilationInfoForFile(filename)

            if not compilation_info:
                return None

            final_flags = compilation_info.compiler_flags_
            relative_to = compilation_info.compiler_working_dir_

            # NOTE: This is just for YouCompleteMe. it's highly likely that your project
            # does NOT need to remove the stdlib flag. DO NOT USE THIS IN YOUR
            # ycm_extra_conf IF YOU'RE NOT 100% SURE YOU NEED IT.
            # try:
            #     final_flags.remove( '-stdlib=libc++' )
            # except ValueError:
            #     pass
        else:
            relative_to = DirectoryOfThisScript()
            final_flags = flags
            # final_flags = MakeRelativePathsInFlagsAbsolute(relative_to)

        # logger.info(final_flags)
        # return {'flags': final_flags, 'do_cache': True}

        return {
            "flags": final_flags,
            "include_paths_relative_to_dir": relative_to,
            "override_filename": filename,
            "do_cache": True,
        }

    elif language == "python":
        if client_data is not None and "g:ycm_python_interpreter_path" in client_data:
            pypath = client_data["g:ycm_python_interpreter_path"]
        else:
            pypath = PathToPythonUsedDuringBuild()

        logger.info(f"Using {pypath} as python interpreter")

        return {"interpreter_path": pypath}

    elif language == "java":
        return {"ls": {"java.format.onType.enabled": True}}

    return {}


def FlagsForFile(filename, **kwargs):
    """DEPRECATED in favor of 'Settings' function

    Resolve compilation flags for every C/C++ files
    """
    settings = kwargs
    settings["filename"] = filename

    if "language" not in settings:
        settings["language"] = ""

        extension = os.path.splitext(settings["filename"])[1]

        if extension in SOURCE_EXTENSIONS or extension in HEADER_EXTENSIONS:
            settings["language"] = "cfamily"
        elif extension == "py":
            settings["language"] = "python"

    return Settings(**settings)
