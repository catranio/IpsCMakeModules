function(ips_pedantic_error target)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang"
            OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang"
            OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        message(STATUS "Enable pedantic: ${target}")
        target_compile_options(${target} PRIVATE
                -Werror
                -Wall
                -Wextra
                -pedantic
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
                -fdiagnostics-show-option)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            target_compile_options(${target} PRIVATE
                    -Wstrict-null-sentinel
                    -Wnoexcept
                    -Wlogical-op)
        endif ()
    endif ()
endfunction()