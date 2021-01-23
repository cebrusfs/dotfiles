# This file is NOT licensed under the GPLv3, which is the license for the rest
# of YouCompleteMe.
#
# Here's the license text for this file:
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

import os
import glob
import platform
import ycm_core

# These are the compilation flags that will be used in case there's no
# compilation database set (by default, one is not set).
# CHANGE THIS LIST OF FLAGS. YES, THIS IS THE DROID YOU HAVE BEEN LOOKING FOR.
flags = [
    '-Wall',
    '-Wextra',
    '-Wno-long-long',
    '-Wno-variadic-macros',
    '-fexceptions',
    '-mno-sse',
    '-DNDEBUG',
    # THIS IS IMPORTANT! Without a "-std=<something>" flag, clang won't know which
    # language to use when compiling headers. So it will guess. Badly. So C++
    # headers will be compiled as C headers. You don't want that so ALWAYS specify
    # a "-std=<something>".
    # For a C project, you would set this to something like 'c99' instead of
    # 'c++11'.
    '-std=c++1z',
    # use GNU standard libarary
    '-stdlib=libstdc++',
    # ...and the same thing goes for the magic -x option which specifies the
    # language that the files to be compiled are written in. This is mostly
    # relevant for c++ headers.
    # For a C project, you would set this to 'c' instead of 'c++'.
    '-x',
    'c++',
    '-I',
    '.',
]

def get_homebrew_gcc_globs():
    homebrew_prefixes = [
        '/usr/local',
        os.path.expanduser('~/homebrew')
    ]

    prefixs = [
        os.path.join(prefix, 'opt/gcc')
        for prefix in homebrew_prefixes
    ]
    prefixs = list(filter(lambda xs: os.path.exists(xs), prefixs))

    # only <= 1 valid homebrew gcc path
    assert len(prefixs) <= 1

    if not prefixs:
        return []
    else:
        gcc_prefix = prefixs[0]

    globs = [
        '{gcc_prefix}/include/c++/*',
        '{gcc_prefix}/include/c++/*/x86_64-apple-darwin*',
        '{gcc_prefix}/include/c++/*/backward',
        '{gcc_prefix}/lib/gcc/*/gcc/x86_64-apple-darwin*/*/include',

        '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/local/include',
        '/usr/local/include',

        '{gcc_prefix}/include',
        '{gcc_prefix}/lib/gcc/*/gcc/x86_64-apple-darwin*/*/include-fixed',

        '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include',
        '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks',
        '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/Library/Frameworks',
        '/usr/include',
        '/System/Library/Frameworks',
        '/Library/Frameworks',
    ]
    globs = [
        p.format(gcc_prefix=gcc_prefix)
        for p in globs
    ]
    return globs

def get_osx_gcc_globs():
    globs = [
        # Xcode clang
        '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1',

        '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/local/include',
        '/usr/local/include',

        '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/*/include',
        '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include',

        '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include',
        '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks',
        '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/Library/Frameworks',
        '/usr/include',
        '/System/Library/Frameworks',
        '/Library/Frameworks',
    ]
    return globs

def get_linux_gcc_globs():
    globs = [
        '/usr/include/c++/*',
        '/usr/include/x86_64-linux-gnu/c++/*',
        '/usr/include/c++/*/backward',
        '/usr/lib/gcc/x86_64-linux-gnu/*/include',
        '/usr/local/include',
        '/usr/lib/gcc/x86_64-linux-gnu/*/include-fixed',
        '/usr/include',
    ]
    return globs


def globs_to_paths(globs, unique=True):
    paths = []
    for p in globs:

        ps = glob.glob(p)

        # path not found
        if not ps:
            continue

        print(p, ps)
        if unique:
            assert len(ps) <= 1

        # If not unique, choose the latest
        ps.sort()
        paths.append(ps[-1])
    return paths

def prepend_flag(flag, paths):
    ps = []
    for p in paths:
        ps += [flag, p]
    return ps


if platform.system() == 'Darwin':
    # TODO: merge homebrew gcc flags and osx gcc flags
    flags += prepend_flag('-isystem', globs_to_paths(get_homebrew_gcc_globs()))
    flags += prepend_flag('-isystem', globs_to_paths(get_osx_gcc_globs()))

    # System python
    flags += [
        '-isystem',
        '/System/Library/Frameworks/Python.framework/Headers'
    ]
elif platform.system() == 'Linux':
    flags += prepend_flag('-isystem', globs_to_paths(get_linux_gcc_globs(), unique=False))
else:
    assert False


# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags. Notice that YCM itself uses that approach.
compilation_database_folder = ''

if os.path.exists( compilation_database_folder ):
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )


def MakeRelativePathsInFlagsAbsolute( flags, working_directory ):
  if not working_directory:
    return list( flags )
  new_flags = []
  make_next_absolute = False
  path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
  for flag in flags:
    new_flag = flag

    if make_next_absolute:
      make_next_absolute = False
      if not flag.startswith( '/' ):
        new_flag = os.path.join( working_directory, flag )

    for path_flag in path_flags:
      if flag == path_flag:
        make_next_absolute = True
        break

      if flag.startswith( path_flag ):
        path = flag[ len( path_flag ): ]
        new_flag = path_flag + os.path.join( working_directory, path )
        break

    if new_flag:
      new_flags.append( new_flag )
  return new_flags


def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]


def GetCompilationInfoForFile( filename ):
  # The compilation_commands.json file generated by CMake does not have entries
  # for header files. So we do our best by asking the db for flags for a
  # corresponding source file, if any. If one exists, the flags for that file
  # should be good enough.
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        compilation_info = database.GetCompilationInfoForFile(
          replacement_file )
        if compilation_info.compiler_flags_:
          return compilation_info
    return None
  return database.GetCompilationInfoForFile( filename )


def FlagsForFile( filename, **kwargs ):
  if database:
    # Bear in mind that compilation_info.compiler_flags_ does NOT return a
    # python list, but a "list-like" StringVec object
    compilation_info = GetCompilationInfoForFile( filename )
    if not compilation_info:
      return None

    final_flags = MakeRelativePathsInFlagsAbsolute(
      compilation_info.compiler_flags_,
      compilation_info.compiler_working_dir_ )

    # NOTE: This is just for YouCompleteMe; it's highly likely that your project
    # does NOT need to remove the stdlib flag. DO NOT USE THIS IN YOUR
    # ycm_extra_conf IF YOU'RE NOT 100% SURE YOU NEED IT.
    try:
      #final_flags.remove( '-stdlib=libc++' )
      pass
    except ValueError:
      pass
  else:
    relative_to = DirectoryOfThisScript()
    final_flags = MakeRelativePathsInFlagsAbsolute( flags, relative_to )

  return {
    'flags': final_flags,
    'do_cache': True
  }
