set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Specify the cross-compiler paths
set(TOOLCHAIN "/Volumes/x-tools/arm-unknown-linux-gnueabi/bin")
set(CMAKE_C_COMPILER "${TOOLCHAIN}/arm-unknown-linux-gnueabi-gcc")
set(CMAKE_CXX_COMPILER "${TOOLCHAIN}/arm-unknown-linux-gnueabi-g++")
set(CMAKE_AR "${TOOLCHAIN}/arm-unknown-linux-gnueabi-ar")
set(CMAKE_AS "${TOOLCHAIN}/arm-unknown-linux-gnueabi-as")
set(CMAKE_LD "${TOOLCHAIN}/arm-unknown-linux-gnueabi-ld")
set(CMAKE_STRIP "${TOOLCHAIN}/arm-unknown-linux-gnueabi-strip")
set(CMAKE_RANLIB "${TOOLCHAIN}/arm-unknown-linux-gnueabi-ranlib")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
