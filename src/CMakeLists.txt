set(CMAKE_AUTOMOC ON)

add_library(mver-core STATIC
  mediareport.cpp
  mediareport.h)
target_link_libraries(mver-core PUBLIC Qt6::Core Qt6::Gui)
target_include_directories(mver-core PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

add_executable(mver
  main.cpp
  mainwindow.cpp
  mainwindow.h)
target_link_libraries(mver PRIVATE mver-core Qt6::Widgets)

add_executable(mver-cli cli.cpp)
target_link_libraries(mver-cli PRIVATE mver-core)

if(BUILD_TESTING)
  add_executable(mediareport-test ../tests/mediareport_test.cpp)
  target_link_libraries(mediareport-test PRIVATE mver-core)
  add_test(NAME mediareport COMMAND mediareport-test)
endif()

