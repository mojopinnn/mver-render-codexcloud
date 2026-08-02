include_guard(GLOBAL)

# Install a relocatable application and expose the package targets used by CI.
# Qt's deployment API deliberately owns Qt library/plugin discovery; generic
# runtime dependency collection is reserved for FFmpeg/OIIO/OCIO and their
# transitive dependencies.
function(mver_configure_packaging)
  cmake_parse_arguments(PARSE_ARGV 0 ARG "" "GUI_TARGET;CLI_TARGET;OCIO_SOURCE" "")
  foreach(required GUI_TARGET CLI_TARGET OCIO_SOURCE)
    if(NOT ARG_${required})
      message(FATAL_ERROR "mver_configure_packaging: ${required} is required")
    endif()
  endforeach()

  find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Network)

  # QImage readers and network backends are loaded dynamically and therefore
  # cannot be inferred from the executable's link graph.
  if(Qt6_VERSION VERSION_LESS 6.5)
    # Qt 6.4 used the technical-preview spelling and did not yet expose
    # dependency filters. On Linux, linuxdeploy performs the Qt deployment.
    qt_generate_deploy_app_script(
      TARGET ${ARG_GUI_TARGET}
      FILENAME_VARIABLE qt_deploy_script
      NO_UNSUPPORTED_PLATFORM_ERROR)
  else()
    qt_generate_deploy_app_script(
      TARGET ${ARG_GUI_TARGET}
      OUTPUT_SCRIPT qt_deploy_script
      NO_TRANSLATIONS
      PRE_INCLUDE_REGEXES
        "qwindows" "qxcb" "qwayland" "qoffscreen" "qjpeg" "qsvg" "qwebp"
        "qopensslbackend" "qschannelbackend"
      POST_EXCLUDE_REGEXES
        "api-ms-win-.*" "ext-ms-.*"
        "libc\\.so.*" "libm\\.so.*" "libpthread\\.so.*" "libdl\\.so.*"
        "librt\\.so.*" "ld-linux.*" "linux-vdso.*")
  endif()
  install(SCRIPT "${qt_deploy_script}")

  install(DIRECTORY "${ARG_OCIO_SOURCE}/"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/mver/ocio"
    COMPONENT Runtime)

  set(_exclude_system
    "api-ms-win-.*" "ext-ms-.*" "kernel32\\.dll" "user32\\.dll"
    "libc\\.so.*" "libm\\.so.*" "libpthread\\.so.*" "libdl\\.so.*"
    "librt\\.so.*" "ld-linux.*" "linux-vdso.*")
  install(RUNTIME_DEPENDENCY_SET mver_runtime_dependencies
    PRE_EXCLUDE_REGEXES ${_exclude_system}
    POST_EXCLUDE_REGEXES ${_exclude_system}
    POST_INCLUDE_REGEXES
      ".*[Oo]pen[Ii]mage[Ii][Oo].*" ".*[Oo]pen[Cc]olor[Ii][Oo].*"
      ".*(avcodec|avformat|avutil|swscale|swresample).*"
      ".*(ssl|crypto|zlib|png|jpeg|tiff|webp).*"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    COMPONENT Runtime)

  if(WIN32)
    # Installs the matching release MSVC runtime without relying on the runner.
    set(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION "${CMAKE_INSTALL_BINDIR}")
    set(CMAKE_INSTALL_UCRT_LIBRARIES TRUE)
    include(InstallRequiredSystemLibraries)
  endif()

  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/VerifyRelocatable.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/VerifyRelocatable.cmake" @ONLY)
  install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/VerifyRelocatable.cmake")

  if(UNIX AND NOT APPLE)
    find_program(LINUXDEPLOY_EXECUTABLE linuxdeploy)
    if(LINUXDEPLOY_EXECUTABLE)
      add_custom_target(appdir
      COMMAND "${CMAKE_COMMAND}" --install "${CMAKE_BINARY_DIR}"
              --prefix "${CMAKE_BINARY_DIR}/AppDir/usr"
      COMMAND "${CMAKE_COMMAND}" -E env
              "QMAKE=${Qt6_DIR}/../../../bin/qmake"
              "NO_STRIP=1"
              "${LINUXDEPLOY_EXECUTABLE}"
              --appdir "${CMAKE_BINARY_DIR}/AppDir"
              --executable "${CMAKE_BINARY_DIR}/AppDir/usr/${CMAKE_INSTALL_BINDIR}/mver"
              --executable "${CMAKE_BINARY_DIR}/AppDir/usr/${CMAKE_INSTALL_BINDIR}/mver-cli"
              --plugin qt
      DEPENDS ${ARG_GUI_TARGET} ${ARG_CLI_TARGET}
        USES_TERMINAL)
      add_custom_target(appimage
      COMMAND "${CMAKE_COMMAND}" -E env OUTPUT=mver-${PROJECT_VERSION}-${CMAKE_SYSTEM_PROCESSOR}.AppImage
              "${LINUXDEPLOY_EXECUTABLE}" --appdir "${CMAKE_BINARY_DIR}/AppDir" --output appimage
        DEPENDS appdir USES_TERMINAL)
    else()
      message(STATUS "linuxdeploy not found; AppDir/AppImage targets are disabled")
    endif()
  endif()
endfunction()
