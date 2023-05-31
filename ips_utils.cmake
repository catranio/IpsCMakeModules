function(_ips_add_prefix_to_list _PREFIX _LIST_VAR _LIST)
    foreach(_LIST_ITEM ${_LIST})
        list(APPEND _VAL "${_PREFIX}${_LIST_ITEM}")
    endforeach()
    set(${_LIST_VAR} ${_VAL} PARENT_SCOPE)
endfunction(_ips_add_prefix_to_list)

function(_ips_collect_source _IPS_COLLECTED_SOURCES _IPS_SOURCES _IPS_EXTENSIONS)
    if (NOT _IPS_EXTENSIONS)
        set(_IPS_EXTENSIONS *.cpp *.cxx *.cc *.c *.h *.hpp *.hh *.hxx)
    endif()

    foreach(_SOURCE ${_IPS_SOURCES})
        get_filename_component(_ABSOLUTE_SOURCE ${_SOURCE} ABSOLUTE)
        if(EXISTS ${_ABSOLUTE_SOURCE})
            if (IS_DIRECTORY ${_ABSOLUTE_SOURCE})
                _ips_add_prefix_to_list("${_ABSOLUTE_SOURCE}/" _SOURCE_WITH_EXT ${_IPS_EXTENSIONS})
                file(GLOB_RECURSE _SRC_DIR_CONTENTS ${_SOURCE_WITH_EXT})
                list(APPEND _SOURCE_LIST ${_SRC_DIR_CONTENTS})
            else()
                list(APPEND _SOURCE_LIST ${_ABSOLUTE_SOURCE})
            endif()
        else()
            file(GLOB_RECURSE _GLOB_CONTENTS ${_ABSOLUTE_SOURCE})
            if (_GLOB_CONTENTS)
                list(APPEND _SOURCE_LIST ${_GLOB_CONTENTS})
            endif()
        endif()
    endforeach()

    if(_SOURCE_LIST)
        list(REMOVE_DUPLICATES _SOURCE_LIST)
    endif()

    set(${_IPS_COLLECTED_SOURCES} ${_SOURCE_LIST} PARENT_SCOPE)
endfunction(_ips_collect_source)

function (ips_add_sanitizer TARGET SANITIZER)
    cmake_parse_arguments(
            SANITIZER
            ""
            "CONDITION"
            ""
            ${ARGN}
    )
    if (SANITIZER_CONDITION)
        message(STATUS "Using sanitizer: ${SANITIZER}")
        target_compile_options(${TARGET} PRIVATE -fsanitize=${SANITIZER})
        target_link_options(${TARGET} PRIVATE -fsanitize=${SANITIZER})
    endif ()
endfunction ()