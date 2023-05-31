# IpsCmakeModules
## Provide cmake functions
### ips_init
Sets the general build parameters and the c++ standard.

**Example:**
```cmake
ips_init(custom.project.name CXX c++17)
```
### ips_fetch
Extract and build cmake remote project or libs.

**Properties:**\
`GIT_REPOSITORY` - Url from remote git repository.\
`GIT_TAG` - Branch or tag use for build.\
`LOCAL_DIR` - Set path to local project for build.\
`${ARGN}` - Provide other FetchContent arguments.\
***Global: Use for all ips_fetch.***\
`IPS_PREFER_GIT_TAG` - Check tag and use if exist.

**Example:**
```cmake
ips_fetch_git(some.lib
        GIT_REPOSITORY https://github.com/some/lib.git
        GIT_TAG v0.1.0
        LOCAL_DIR install/path/local/some.lib)
```
### ips_add_target
Adds a target for the build (default is `EXECUTABLE`).

**Properties:**\
`STATIC` - Target is static library.\
`SHARED` - Target is shared library.\
`EXECUTABLE` - Target is execute binary file.\
`HEADERS` - Sets the list of headers.\
`SOURCES` - Sets the list of sources.\
`DESTINATION` - Prefix path headers after install.\
`DEPENDS` - Sets the list of library. If "-l" is specified, the prefix will be truncated and the library will be passed directly. It is possible to pass linker options by specifying them after "-Wl,". The full path to the library can be specified.

For `HEADERS` and `SOURCES` You can specify directories with end `/` or `/*` and then they will be bypassed recursively.

**Example:**
```cmake
ips_add_target(custom.project.target EXECUTABLE
        HEADERS path/to/headers/* DESTINATION prefix/path/
        SOURCES path/to/sources/*
        DEPENDS
            custom.libs.name
            -lpthread
            -Wl, -custom-linker-property)
```

### Add to new CMake project

```cmake
set(LIBS_SOURCE_DIR ${CMAKE_SOURCE_DIR}/libs)

include(FetchContent)
FetchContent_Declare(IpsCMakeModules
        GIT_REPOSITORY https://github.com/catranio/IpsCMakeModules.git
        SOURCE_DIR ${LIBS_SOURCE_DIR}/common/IpsCMakeModules)
FetchContent_MakeAvailable(IpsCMakeModules)
find_package(IpsCMakeModules PATHS ${IpsCMakeModules_CONFIG_DIR})
```

`IpsCMakeModules` will installed by path `libs/common/IpsCMakeModules` and remember to add this path to `.gitignore`

---
Author: *Petr Iaskevich, MIT license*\
Email: *iaskdeveloper@gmail.com*