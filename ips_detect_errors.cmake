function(ips_pedantic_error target)
    ips_split_name_and_namespace(target_namespace target ${target})
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang"
            OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang"
            OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        if(target_namespace)
            set(target_prefix "${target_namespace}::")
        endif ()
        message(STATUS "${target_prefix}${target}: Using strict error checking mode")
        target_compile_options(${target} PRIVATE
                -Werror
                -Wall
                -Wextra
                -Wpedantic
                -Wcast-align
                -Wcast-qual
                -Wctor-dtor-privacy
                -Wdisabled-optimization
                -Wformat=2
                -Winit-self
                -Wmissing-include-dirs
                -Wold-style-cast
                -Woverloaded-virtual
                -Wredundant-decls
                -Wshadow
                -Wsign-promo
                -Wundef
                -Wno-unused
                -Wno-variadic-macros
                -Wno-parentheses
                -Wconversion
                -Wmissing-noreturn
                -Wstack-protector
                -Wunreachable-code
                -Wfloat-equal
                -Wunused
                -Wswitch
                -Wuninitialized
                -Wformat-nonliteral
                -Wformat-security
                -Wformat-y2k
                -Winline
                -fdiagnostics-show-option
                )
        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            target_compile_options(${target} PRIVATE
                    -Wstrict-null-sentinel
                    -Wnoexcept
                    -Wlogical-op)
        endif ()
    endif ()
endfunction()