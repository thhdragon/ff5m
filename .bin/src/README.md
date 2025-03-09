## MacOS

### Environment setup

```shell
# Install Xcode command-line tools
xcode-select --install

# Install brew https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages
brew install crosstool-ng

# Create case-sensitive volume
hdiutil create ~/crosstool.dmg -volname "x-tools" -size 15g -fs "Case-sensitive APFS"

# Mount and link
hdiutil mount ~/crosstool.dmg
ln -s /Volumes/x-tools ~/x-tools

# Configure and build cross-tools 
ct-ng arm-unknown-linux-gnueabi

# Generic configuration (should already be set, but may be useful for other toolchains)
# - Target architecture: ARM
# - Use EABI
# - Floating point: Software (no FPU)
# 
# Libraries:
# - Set glibc version to 2.25.
# - Use Linux Kernel version 5.3.18.
#   (Note: The printer actually uses version 5.4, but do not use versions newer than 5.4.289 as they may be incompatible.)
# - [Optional] You can set GCC version to 7.5.0. 
#   (However, keep in mind that GCC 7.5.0 is pretty old.)

# Launching configuration tool:
ct-ng menuconfig

# Build
ct-ng build -j$(nproc)

# OR rebuild changes only:
# ct-ng build.2 -j$(nproc)
```

## Building

```shell
cd .bin/src/<project>
make

# Upload
scp -O "./bin/<project_bin>" root@<printer_ip>:/opt/
```

## Setup new project

```shell
PROJECT=<project>

cd .bin/src/
mkdir $PROJECT
cd $PROJECT

# Create and configure CMakeLists.txt
touch CMakeLists.txt
# Fill CMakeLists.txt with actual project configuration

# Setup toolchain
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain.cmake .

# Build
make
```