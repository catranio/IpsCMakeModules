#   Initial all cmake projects
function(ips_init)
    include(CMakeParseArguments)
    cmake_parse_arguments(_IPS_GLOBAL "" "CXX" "" ${ARGN})

    if(_IPS_GLOBAL_CXX)
        string(REGEX REPLACE "([^0-9]*)([0-9]+)" "\\1;\\2" _STD_ARGS "${_IPS_GLOBAL_CXX}")
        list(LENGTH _STD_ARGS _STD_ARGS_LENGTH)
        if(_STD_ARGS_LENGTH LESS 2)
            message(FATAL_ERROR "Invalid CXX_STANDARD \"${_IPS_GLOBAL_CXX}\"")
        endif()
        list(GET _STD_ARGS 1 _STD_VERSION)

        set(CMAKE_CXX_STANDARD ${_STD_VERSION} PARENT_SCOPE)
        set(CMAKE_CXX_STANDARD_REQUIRED TRUE PARENT_SCOPE)
    endif()

    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Project build type" FORCE)
    endif()
    message(STATUS "Project: ${PROJECT_NAME} CXX c++${_STD_VERSION}")
endfunction()