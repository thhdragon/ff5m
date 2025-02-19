cmake_minimum_required(VERSION 3.10)

project(typer VERSION 0.1)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../../exec)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath,/opt/lib/14.2.0")

file(GLOB font_headers ../common/fonts/*.h)

add_executable(typer main.cpp
        ../common/text.cpp
        ${font_headers})

target_link_libraries(typer m)
