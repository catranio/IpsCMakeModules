# IpsCmakeModules
## Provide cmake functions
### ips_init
Sets the general build parameters and the c++ standard.

**Example:**
```cmake
ips_init(custom.project.name CXX c++17)
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
# Fetching ips-cmake-modules
FetchContent_Declare(ips-cmake-modules
        GIT_REPOSITORY https://github.com/catranio/IpsCMakeModules.git
        SOURCE_DIR ${LIBS_SOURCE_DIR}/common/IpsCMakeModules)
FetchContent_Populate(ips-cmake-modules)
include(CMakePackageConfigHelpers)
configure_package_config_file(
        ${LIBS_SOURCE_DIR}/Common/IpsCMakeModules/IpsCMakeModulesConfig.in
        ${LIBS_SOURCE_DIR}/Common/IpsCMakeModules/IpsCMakeModulesConfig.cmake
        INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/lib/IpsCMakeModules/cmake)
set(IpsCMakeModules_DIR ${LIBS_SOURCE_DIR}/Common/IpsCMakeModules/)
find_package(IpsCMakeModules)
```

`IpsCMakeModules` will installed by path `libs/common/IpsCMakeModules` and remember to add this path to `.gitignore`

---
Author: *Petr Iaskevich, MIT license*\
Email: *iaskdeveloper@gmail.com*