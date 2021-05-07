# MS-Wasm LLVM fork

This is a fork of LLVM---or actually, a fork of the CHERI fork of
LLVM---intended for producing MS-Wasm code.  Most of the changes
are to the Wasm backend, located at `llvm/lib/Target/WebAssembly`.

In general, no effort has been made to preserve ordinary WebAssembly
functionality, or to avoid breaking other backends (e.g., X86); other
backends probably do not even build currently.

## Building

To build, use the following:

```
cd llvm
cmake -G Ninja -B build -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="WebAssembly" .
cd build
ninja
```

Once you've built the first time, if you've made changes and want to rebuild,
you don't have to run `cmake` again---just use `ninja`.

## Generating MS-Wasm

You must have the [WASI SDK](https://github.com/WebAssembly/wasi-sdk)
installed. We assume it's installed in `/opt/wasi-sdk`.

```
./llvm/build/bin/clang -O1 --target=wasm32-wasi --sysroot=/opt/wasi-sdk/share/wasi-sysroot foo.c -o foo.wasm
```

You can get loads of debug logging from LLVM by adding the following to the `clang` command:
```
-mllvm -print-before-all -mllvm -debug
```

Original (CHERI) readme follows.

# The CHERI LLVM Compiler Infrastructure

This directory and its sub-directories contain source code for LLVM,
a toolkit for the construction of highly optimized compilers,
optimizers, and run-time environments, extended to support
[CHERI](http://cheri-cpu.org).

The README briefly describes how to get started with building LLVM.
Please file issues and submit pull requests against the
[GitHub project](https://github.com/CTSRD-CHERI/llvm-project).

## Getting Started with the LLVM System (Recommended)

The recommended way to get started with LLVM is by using
[cheribuild](https://github.com/CTSRD-CHERI/cheribuild), which will
build a working toolchain with a single ``cheribuild.py llvm``.

## Getting Started with the LLVM System (Manual)

Taken from https://llvm.org/docs/GettingStarted.html.

### Overview

Welcome to the LLVM project!

The LLVM project has multiple components. The core of the project is
itself called "LLVM". This contains all of the tools, libraries, and header
files needed to process intermediate representations and converts it into
object files.  Tools include an assembler, disassembler, bitcode analyzer, and
bitcode optimizer.  It also contains basic regression tests.

C-like languages use the [Clang](http://clang.llvm.org/) front end.  This
component compiles C, C++, Objective-C, and Objective-C++ code into LLVM bitcode
-- and from there into object files, using LLVM.

Other components include:
the [libc++ C++ standard library](https://libcxx.llvm.org),
the [LLD linker](https://lld.llvm.org), and more.

### Getting the Source Code and Building LLVM

The LLVM Getting Started documentation may be out of date.  The [Clang
Getting Started](http://clang.llvm.org/get_started.html) page might have more
accurate information.

This is an example work-flow and configuration to get and build the LLVM source:

1. Checkout LLVM (including related sub-projects like Clang):

     * ``git clone https://github.com/llvm/llvm-project.git``

     * Or, on windows, ``git clone --config core.autocrlf=false
    https://github.com/llvm/llvm-project.git``

2. Configure and build LLVM and Clang:

     * ``cd llvm-project``

     * ``mkdir build``

     * ``cd build``

     * ``cmake -G <generator> [options] ../llvm``

        Some common build system generators are:

        * ``Ninja`` --- for generating [Ninja](https://ninja-build.org)
          build files. Most llvm developers use Ninja.
        * ``Unix Makefiles`` --- for generating make-compatible parallel makefiles.
        * ``Visual Studio`` --- for generating Visual Studio projects and
          solutions.
        * ``Xcode`` --- for generating Xcode projects.

        Some Common options:

        * ``-DLLVM_ENABLE_PROJECTS='...'`` --- semicolon-separated list of the LLVM
          sub-projects you'd like to additionally build. Can include any of: clang,
          clang-tools-extra, libcxx, libcxxabi, libunwind, lldb, compiler-rt, lld,
          polly, or debuginfo-tests.

          For example, to build LLVM, Clang, libcxx, and libcxxabi, use
          ``-DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi"``.

        * ``-DCMAKE_INSTALL_PREFIX=directory`` --- Specify for *directory* the full
          path name of where you want the LLVM tools and libraries to be installed
          (default ``/usr/local``).

        * ``-DCMAKE_BUILD_TYPE=type`` --- Valid options for *type* are Debug,
          Release, RelWithDebInfo, and MinSizeRel. Default is Debug.

        * ``-DLLVM_ENABLE_ASSERTIONS=On`` --- Compile with assertion checks enabled
          (default is Yes for Debug builds, No for all other build types).

      * ``cmake --build . [-- [options] <target>]`` or your build system specified above
        directly.

        * The default target (i.e. ``ninja`` or ``make``) will build all of LLVM.

        * The ``check-all`` target (i.e. ``ninja check-all``) will run the
          regression tests to ensure everything is in working order.

        * CMake will generate targets for each tool and library, and most
          LLVM sub-projects generate their own ``check-<project>`` target.

        * Running a serial build will be **slow**.  To improve speed, try running a
          parallel build.  That's done by default in Ninja; for ``make``, use the option
          ``-j NNN``, where ``NNN`` is the number of parallel jobs, e.g. the number of
          CPUs you have.

      * For more information see [CMake](https://llvm.org/docs/CMake.html)

Consult the
[Getting Started with LLVM](https://llvm.org/docs/GettingStarted.html#getting-started-with-llvm)
page for detailed information on configuring and compiling LLVM. You can visit
[Directory Layout](https://llvm.org/docs/GettingStarted.html#directory-layout)
to learn about the layout of the source code tree.
