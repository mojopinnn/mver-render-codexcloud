cmake_minimum_required(VERSION 3.24)

project(mver VERSION 0.1.0 LANGUAGES CXX)

include(GNUInstallDirs)
include(CTest)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Network)

# The application targets are normally created by the source tree.  Keeping the
# packaging entry point here makes `cmake --install` the only supported source
# of release artifacts (rather than copying files from a developer build).
add_subdirectory(src)

install(TARGETS mver mver-cli
  RUNTIME_DEPENDENCY_SET mver_runtime_dependencies
  BUNDLE DESTINATION .
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

# Installed ELF binaries must find only libraries shipped beside them.  Do not
# retain link directories (in particular Conan cache paths) in install RPATH.
if(UNIX AND NOT APPLE)
  set_target_properties(mver mver-cli PROPERTIES
    INSTALL_RPATH "$ORIGIN/../${CMAKE_INSTALL_LIBDIR}:$ORIGIN"
    INSTALL_RPATH_USE_LINK_PATH FALSE
    BUILD_WITH_INSTALL_RPATH FALSE)
endif()

include(cmake/PackageMver.cmake)
mver_configure_packaging(
  GUI_TARGET mver
  CLI_TARGET mver-cli
  OCIO_SOURCE "${CMAKE_SOURCE_DIR}/resources/ocio")
