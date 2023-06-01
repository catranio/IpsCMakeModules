#   Create target

function(_ips_new_target _IPS_TARGET_NAME
        _IPS_STATIC_LIBRARY
        _IPS_SHARED_LIBRARY
        _IPS_EXECUTABLE
        _IPS_SOURCES)
    if((_IPS_STATIC_LIBRARY OR _IPS_SHARED_LIBRARY) AND _IPS_EXECUTABLE)
        message(FATAL_ERROR "Please select library or executable for ${_IPS_TARGET_NAME}")
    endif()

    if (_IPS_SOURCES)
        _ips_collect_source(_IPS_COLLECTED_SOURCES "${_IPS_SOURCES}" "*.cpp *.cxx *.cc *.c")
    endif()

    if(_IPS_LIBRARY OR _IPS_STATIC_LIBRARY OR _IPS_SHARED_LIBRARY)
        unset(_IPS_TARGET_TYPE)
        if(_IPS_STATIC_LIBRARY OR _IPS_LIBRARY)
            set(_IPS_TARGET_TYPE STATIC)
        elseif(_IPS_SHARED_LIBRARY)
            set(_IPS_TARGET_TYPE SHARED)
        endif()
        if(NOT _IPS_SOURCES)
            add_library(${_IPS_TARGET_NAME} INTERFACE)
        else()
            add_library(${_IPS_TARGET_NAME} ${_IPS_TARGET_TYPE} ${_IPS_COLLECTED_SOURCES})
        endif()
    else()
        add_executable(${_IPS_TARGET_NAME} ${_IPS_COLLECTED_SOURCES})
    endif()
endfunction()

function(_ips_install_target _IPS_TARGET_NAME)
    get_target_property(_IPS_TARGET_TYPE ${_IPS_TARGET_NAME} TYPE)
    if("${_IPS_TARGET_TYPE}" MATCHES ".*_LIBRARY")
        set(_IPS_TARGET_IS_LIBRARY TRUE)
    endif()

    if (_IPS_TARGET_IS_LIBRARY)
        set(_IPS_TARGET_DESTINATION lib)
    else()
        set(_IPS_TARGET_DESTINATION bin)
    endif()

    install(TARGETS ${_IPS_TARGET_NAME}
            DESTINATION ${_IPS_TARGET_DESTINATION})
endfunction()

function(_ips_depends _IPS_TARGET_NAME _IPS_DEPENDS)
    foreach(_IPS_DEPEND ${_IPS_DEPENDS})
        if(TARGET ${_IPS_DEPEND})
            ips_split_name_and_namespace(_IPS_DEPEND_NAMESPACE _IPS_DEPEND_NAME ${_IPS_DEPEND} )  
            add_dependencies(${_IPS_TARGET_NAME} ${_IPS_DEPEND})
            target_link_libraries(${_IPS_TARGET_NAME} PRIVATE ${_IPS_DEPEND})
            set_target_properties(${_IPS_DEPEND_NAME} PROPERTIES INTERFACE_SYSTEM_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${_IPS_DEPEND_NAME},INTERFACE_INCLUDE_DIRECTORIES>)
        else()
            string(FIND ${_IPS_DEPEND} "-l" _COMMON_LIBRARY_PREFIX_POS)
            if(_COMMON_LIBRARY_PREFIX_POS EQUAL 0)
                string(SUBSTRING ${_IPS_DEPEND} 2 -1 _REAL_LIBRARY_NAME)
                target_link_libraries(${_IPS_TARGET_NAME} PRIVATE ${_REAL_LIBRARY_NAME})
                continue()
            endif()

            string(FIND ${_IPS_DEPEND} "-Wl," _COMMON_LIBRARY_PREFIX_POS)
            if(_COMMON_LIBRARY_PREFIX_POS EQUAL 0)
                string(SUBSTRING ${_IPS_DEPEND} 2 -1 _REAL_LIBRARY_NAME)
                message(STATUS "_REAL_LIBRARY_NAME: ${_REAL_LIBRARY_NAME}")
                target_link_libraries(${_IPS_TARGET_NAME} PRIVATE ${_REAL_LIBRARY_NAME})
                continue()
            endif()

            find_library(_DEPENDENT_LIBRARY ${_IPS_DEPEND})
            get_filename_component(_DEPENDENT_LIBRARY_INCLUDE ${_DEPENDENT_LIBRARY} DIRECTORY)
            get_filename_component(_DEPENDENT_LIBRARY_INCLUDE ${_DEPENDENT_LIBRARY_INCLUDE} DIRECTORY)
            if(NOT _DEPENDENT_LIBRARY)
                message(FATAL_ERROR "Invalid dependency: ${_IPS_DEPEND}")
            else()
                target_include_directories(${_IPS_TARGET_NAME} PRIVATE ${_DEPENDENT_LIBRARY_INCLUDE}/include)
                target_link_libraries(${_IPS_TARGET_NAME} PRIVATE ${_DEPENDENT_LIBRARY})
            endif()
        endif()
    endforeach()
endfunction()

function(_ips_headers _IPS_TARGET_NAME _IPS_TARGET_STATIC _IPS_TARGET_SHARED _IPS_DESTINATION _IPS_HEADERS)
    set(_IPS_HEADER_PATTERNS "*.hpp;*.hxx;*.hh;*.ipp;*.h")
    foreach(_HEADER_PATTERN ${_IPS_HEADER_PATTERNS})
        set(_IPS_HEADERS_FILE_MATCHING ${_IPS_HEADERS_FILE_MATCHING} PATTERN ${_HEADER_PATTERN})
    endforeach()

    foreach(_HEADERS_DIR ${_IPS_HEADERS})
        get_filename_component(_ABSOLUTE_BASE_HEADERS_DIR "${_HEADERS_DIR}" DIRECTORY)
        if(NOT EXISTS "${_ABSOLUTE_BASE_HEADERS_DIR}")
            message(FATAL_ERROR "Headers base dir \"${_ABSOLUTE_BASE_HEADERS_DIR}\" doesn't exist.")
        endif()
        _ips_collect_source(_IPS_COLLECTED_HEADERS "${_HEADERS_DIR}" ${_IPS_HEADER_PATTERNS})
        set(_DESTINATION include/)
        get_target_property(_IPS_TARGET_TYPE ${_IPS_TARGET_NAME} TYPE)
        if("${_IPS_TARGET_TYPE}" MATCHES ".*_LIBRARY")
            set(_IPS_TARGET_IS_LIBRARY TRUE)
        endif()

        if("${_IPS_TARGET_TYPE}" STREQUAL "INTERFACE_LIBRARY")
            set(_IPS_INCLUDE_FOLDER_TYPE "INTERFACE")
        else()
            set(_IPS_INCLUDE_FOLDER_TYPE "PUBLIC")
        endif()

        if (_IPS_DESTINATION)
            set(_DESTINATION ${_DESTINATION}${_IPS_DESTINATION})
        endif()

        foreach(_HEADERS_DIR ${_IPS_COLLECTED_HEADERS})
            get_filename_component(_ABSOLUTE_HEADER_FILE "${_HEADERS_DIR}" ABSOLUTE)
            if(NOT EXISTS "${_ABSOLUTE_HEADER_FILE}")
                message(FATAL_ERROR "Headers file \"${_ABSOLUTE_HEADER_FILE}\" doesn't exist.")
            endif()
            get_filename_component(_ABSOLUTE_HEADER_DIR "${_HEADERS_DIR}" DIRECTORY)
            if(NOT EXISTS "${_ABSOLUTE_HEADER_DIR}")
                message(FATAL_ERROR "Headers dir \"${_ABSOLUTE_HEADER_DIR}\" doesn't exist.")
            endif()

            set(_BUILD_INTERFACE_DIR "${_ABSOLUTE_BASE_HEADERS_DIR}")
            target_include_directories(${_IPS_TARGET_NAME} ${_IPS_INCLUDE_FOLDER_TYPE}
                    $<BUILD_INTERFACE:${_BUILD_INTERFACE_DIR}>
                    $<INSTALL_INTERFACE:${_DESTINATION}>)
        endforeach()

        if(_IPS_TARGET_IS_LIBRARY)
            install(DIRECTORY ${_ABSOLUTE_BASE_HEADERS_DIR}/
                    DESTINATION ${_DESTINATION}
                    FILES_MATCHING ${_IPS_HEADERS_FILE_MATCHING})
        endif()
    endforeach()
endfunction()

function(_ips_target_compile_options _IPS_TARGET_NAME)
    if(UNIX)
        set(IPS_STD_COMPILER_OPTIONS -Wall -Werror -Wpedantic -Wextra -Wconversion
                -Wold-style-cast -Wuninitialized -Wunreachable-code -Wshadow)
        set(IPS_STD_RELEASE_COMPILER_OPTIONS -O2)
        set(IPS_STD_DEBUG_COMPILER_OPTIONS -O0 -DNDEBUG)
    endif()

    target_compile_options(${_IPS_TARGET_NAME} PRIVATE ${IPS_STD_COMPILER_OPTIONS})
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        target_compile_options(${_IPS_TARGET_NAME} PRIVATE ${IPS_STD_DEBUG_COMPILER_OPTIONS})
    else()
        target_compile_options(${_IPS_TARGET_NAME} PRIVATE ${IPS_STD_RELEASE_COMPILER_OPTIONS})
    endif()
endfunction()

function(ips_add_target _IPS_TARGET_NAME)
    include(CMakeParseArguments)
    cmake_parse_arguments(_IPS_GLOBAL
            "STATIC;SHARED;EXECUTABLE"
            ""
            "HEADERS;SOURCES;DESTINATION;DEPENDS"
            ${ARGN})

    message(STATUS "Add target: ${_IPS_TARGET_NAME}")

    _ips_new_target(${_IPS_TARGET_NAME} ${_IPS_GLOBAL_STATIC} ${_IPS_GLOBAL_STATIC} ${_IPS_GLOBAL_EXECUTABLE} "${_IPS_GLOBAL_SOURCES}")
    _ips_headers(${_IPS_TARGET_NAME} ${_IPS_GLOBAL_STATIC} ${_IPS_GLOBAL_STATIC} "${_IPS_GLOBAL_DESTINATION}" "${_IPS_GLOBAL_HEADERS}")
    _ips_depends(${_IPS_TARGET_NAME} "${_IPS_GLOBAL_DEPENDS}")
    _ips_target_compile_options(${_IPS_TARGET_NAME})
    _ips_install_target(${_IPS_TARGET_NAME})
endfunction()
