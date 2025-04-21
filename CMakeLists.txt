cmake_minimum_required(VERSION 3.10)
project(cppunittests)

cmake_policy(SET CMP0167 NEW)

# Optional: nur setzen, wenn nicht explizit gesetzt wurde
if(NOT CMAKE_EXPORT_COMPILE_COMMANDS)
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endif()

# Nur einen Symlink erstellen, wenn ein Out-of-Source-Build vorliegt
if(NOT "${CMAKE_BINARY_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
  set(_COMPILE_COMMANDS_SRC "${CMAKE_BINARY_DIR}/compile_commands.json")
  set(_COMPILE_COMMANDS_DST "${CMAKE_SOURCE_DIR}/compile_commands.json")

  # Prüfe, ob der Quell-Symlink/Datei existiert und entferne sie, falls ja
  if(EXISTS "${_COMPILE_COMMANDS_DST}")
    message(STATUS "Symlink oder Datei ${_COMPILE_COMMANDS_DST} existiert bereits, entferne sie.")
    file(REMOVE "${_COMPILE_COMMANDS_DST}")
  endif()

  # Erstelle den Symlink nur, wenn die Quelldatei existiert
  if(EXISTS "${_COMPILE_COMMANDS_SRC}")
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E create_symlink "${_COMPILE_COMMANDS_SRC}" "${_COMPILE_COMMANDS_DST}"
      RESULT_VARIABLE _symlink_result
    )
    if(NOT _symlink_result EQUAL 0)
      message(WARNING "⚠️ Failed to create symlink to compile_commands.json")
    else()
      message(STATUS "Symlink zu compile_commands.json wurde erfolgreich erstellt.")
    endif()
  else()
    message(WARNING "⚠️ Quelldatei ${_COMPILE_COMMANDS_SRC} existiert nicht; Symlink wird nicht erstellt.")
  endif()
endif()

include(FetchContent)
FetchContent_Declare(
  catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG v3.5.4 # oder aktuelle Version
)
FetchContent_MakeAvailable(catch2)

add_executable(tests tests/tests.cpp)
target_link_libraries(tests PRIVATE Catch2::Catch2WithMain)
set(CMAKE_CXX_STANDARD 23)

include_directories(/usr/include)

find_package(Boost REQUIRED COMPONENTS filesystem)

add_executable(main src/main.cpp)
target_link_libraries(main PRIVATE Boost::filesystem)


# Unit tests enable_testing() add_executable(tests tests/tests.cpp)
# add_test(NAME Tests COMMAND tests)
