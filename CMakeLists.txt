cmake_minimum_required(VERSION 3.2)
project(IpsCMakeModules VERSION 1.0.0)

add_custom_target(ips-cmake-modules)

set(IPS_CMAKEMODULES_INSTALL_DESTINATION "lib/${PROJECT_NAME}/cmake")
set(IPS_CMAKEMODULES_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake")

file(GLOB _IPS_CMAKE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.cmake)
install(
        FILES ${_PROTEI_CMAKE_FILES}
        DESTINATION ${IPS_CMAKEMODULES_INSTALL_DESTINATION})

include(CMakePackageConfigHelpers)
configure_package_config_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}Config.in
        ${IPS_CMAKEMODULES_CONFIG_FILE}
        INSTALL_DESTINATION ${IPS_CMAKEMODULES_INSTALL_DESTINATION})

install(
        FILES ${IPS_CMAKEMODULES_CONFIG_FILE}
        DESTINATION ${IPS_CMAKEMODULES_INSTALL_DESTINATION})

## Provide some pkg-config integration
set(PKGCONFIG_INSTALL_DIR
        "${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig"
        CACHE PATH "Path where ${PROJECT_NAME}.pc is installed")
configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc
        @ONLY)
install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc
        DESTINATION ${PKGCONFIG_INSTALL_DIR})
