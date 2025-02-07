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

# Configure
# - glibc version to 2.25
# - Linux Kernel version 5.4.289
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