# Flashforge Adventurer 5M Firmware Mod

This is an _unofficial_ mod to run Moonraker, Klipper (with essential patches), Mainsail, and Fluidd on the Flashforge AD5M (Pro) 3D printers.
The mod is based on ZMod, which itself is derived from Klipper-mod.

> [!CAUTION]
> *If you want to install this mod to your AD5M (Pro) then be aware, that you risk to loose your warranty or damage the printer. Proceed at your own risk if you want to try this mod!*

## Features
- **Stock** Screen with option to disable it completely to reduce resource consumption
- **Klipper** with many patches/fixes/plugins specially adapted for AD5M
- **Moonraker**
- **Fluidd** & **Mainsail**
- **Root** access (with zsh/.oh-my-zsh)
- **Buzzer** with ability to play monotonic melodies (midi / notes)
- Patched **mjpg-streamer** with dramatically reduced memory usage
- **Timelapse** support via [Moonraker Telegram bot](https://github.com/nlef/moonraker-telegram-bot) installed on external host
- Adaptive bed meshing with **KAMP**.
- Built-in **MD5** checks for gcode files.
- **Backup** and **Restore** mechanizm for printer's configuration
- Fix for the **E00017** error.
- **Failsafe** mechanism to prevent nozzle collisions.
- Enhanced **Shaper Calibration** with automatic plot generation.
- Easy **Bed Level Screw Tuning**.
- Customized dedicated Linux environment based on **Buildroot**
- **Entware** package manager for additional software installation
- **Dual boot** with stock Flashforge software


## Why This Mod Was Developed
This mod was created to address several critical limitations and challenges faced by users of the Flashforge AD5M (Pro) 3D printer. Here are the key reasons behind its development:

**Instability and Resource Issues in Existing Klipper Mods:**
The previous Klipper mod for the AD5M has stopped development and is no really stable. It consumes excessive RAM, leading to issues such as "Timer too close" errors and other performance problems. And some of typical AD5M issues not fixed at all. This mod aims to resolve these issues by optimizing resource usage and ensuring a stable, reliable experience.

**Closed and Inflexible Development in ZMOD:**
While ZMOD introduced significant improvements, it is not user-friendly for further enhancements or fixes. Its closed nature and unique development approach make it difficult to modify without deep knowledge of the entire system. This mod focuses on rewriting the foundation to provide advanced users with more control, making it easier to apply patches, additions, and customizations.

**Lack of Essential Functionality in Stock Firmware:**
The stock firmware lacks many essential features that modern 3D printing enthusiasts expect. For example:
The camera functionality is poorly optimized, consuming excessive RAM and delivering subpar performance.
Users are unable to perform standard tasks that Klipper users typically rely on, such as advanced calibration, macros, and real-time monitoring.
This mod addresses these shortcomings by integrating modern tools and features.

**Outdated Klipper with Unresolved Bugs:**
The existing Klipper implementation for the AD5M is outdated and plagued with bugs. This mod focuses on fixing these long-standing issues, modifying Klipper plugins, and enhancing core functionality to better suit the specific requirements of the AD5M (Pro) printer. The goal is to provide a stable, feature-rich platform tailored to this printer's unique hardware and user needs.

### The Vision Behind This Mod

This mod is designed to empower users by providing a stable, customizable, and feature-rich alternative to the stock firmware and existing mods. It aims to:
Offer a reliable foundation for advanced users to build upon.
- Fix long-standing bugs and optimize performance for the AD5M (Pro).
- Introduce modern features and tools that enhance the 3D printing experience.
- Ensure flexibility and openness for future improvements and community contributions.

By addressing these challenges, this mod strives to unlock the full potential of the Flashforge AD5M (Pro) and provide users with a seamless, powerful, and customizable 3D printing platform.

## Installation

This mod is designed to be uninstalled at any time, completely and effortlessly.
If the mod encounters issues or you simply prefer to use the stock firmware, you can easily switch back without any complex procedures.
Additionally, the mod includes a **dual-boot** feature as a failsafe measure. This ensures that you can restore full functionality even if any part of the mod does not work as intended.


### Prerequisites
- A USB flash drive formatted to FAT32.
- A computer with SSH and SCP capabilities (e.g., Terminal on macOS/Linux or PuTTY/WinSCP on Windows).
- Basic familiarity with command-line tools.


### Install ZMOD 1.0.5

The mod uses the same installation mechanism as the stock firmware:
1) Download ZMOD [1.0.5](https://github.com/ghzserg/zmod/blob/main/%D0%A1%D1%82%D0%B0%D1%80%D1%8B%D0%B5_%D0%B2%D0%B5%D1%80%D1%81%D0%B8%D0%B8/Adventurer5MPro-zmod-1.0.5.tgz) update file onto a USB flash drive.
2) Plug in the drive before starting the printer.
3) Successful installation will be indicated on the display when finished.

**Note**: The mod installer currently requires the printer to be updated to at least version **2.4.5** of the stock Flashforge firmware. Please check the release page for compatible versions.
After installation, the printer will boot into the modified stock system by default.

### (Temporary) Install dependencies

As the mod is still in development, it does not have a firmware image yet.
Therefore, you need to install the necessary dependencies on the printer:

1. Download the patched `mjpeg-streamer` ***.ipk** files: [link](https://github.com/DrA1ex/mjpg-streamer/releases)
2. Upload the files to the printer and install the dependencies as follows:

```bash
PRINTER_IP=<your printer IP>

# Transfer the streamer files
scp -O ./mjpg-streamer-* root@$PRINTER_IP:/opt/packages/

# Log in via SSH
ssh root@$PRINTER_IP

# Install the streamer packages
cd /opt/packages/
opkg install mjpg-streamer_1.0.1-1_armv7-3.2.ipk mjpg-streamer-input-uvc_1.0.1-1_armv7-3.2.ipk mjpg-streamer-output-http_1.0.1-1_armv7-3.2.ipk

# Install additional packages
opkg install busybox htop nano zsh
```

### Run the Switching Script

The mod comes with pre-installed **root** access, allowing you to connect via SSH using the credentials _root/root_.
To proceed, download the [switch.sh](https://github.com/DrA1ex/ff5m/blob/main/switch.sh) script, upload it to the printer, and execute it.

```bash
IP="<your_printer_IP>"

# Upload the script to the printer
scp ./switch.sh "root@$IP:/opt"

# Log in to the printer
ssh "root@$IP"

# Run the script
cd /opt
chmod +x ./switch.sh && ./switch.sh
```

After running the script, the mod will either download the update automatically, or you may need to update the firmware manually via Fluidd's **Configuration -> Software Update -> zmod (Update)**.

Finally, reboot your printer. The mod should now be installed. 
From this point onward, you will receive OTA updates from this repository.

You can reach services using these addresses:
- **Moonraker**: http://<printer_ip>:7125/
- **Fluidd**: http://<printer_ip>/fluidd/
- **Mainsail**: http://<printer_ip>/mainsail/


## Slicing

You need to replace the original start/end gcode with the following:

**For OrcaSlicer:**

Start Gcode
```
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single]
```

End Gcode
```
END_PRINT
```

### Configuring Moonraker / Klipper connection

To connect to the printer, use the following physical printer settings:
* Host type: `moonraker`, `klipper` or `klipper (via moonraker)`
* Hostname, IP or URL: `<printer_ip>:7125`


## Dual Boot

The mod implements a failsafe mechanism to boot the stock firmware before executing any mod-related boot code. This ensures that if the mod encounters any issues, you can safely skip the mod's boot process and load into the stock firmware.

To use this feature, you have several options:

### Using USB Drive

Format a USB drive to FAT32 and place an empty file in the root directory:  
- Name the file `SKIP_ZMOD` to completely skip the mod loading..
- Name the file `SKIP_ZMOD_SOFT` to skip additional service loading while preserving root access.

Insert the USB drive before turning on the printer. The mod will automatically recognize the USB drive and load in the selected mode.

### Run Macro via Fluidd/Mainsail

Run the macro in Klipper's console:  

- `SKIP_ZMOD` to completely skip the mod loading.
- `SKIP_ZMOD_SOFT` to skip additional service loading while preserving root access.

The mod will automatically reboot and load in the selected mode.

## Uninstall

To remove the mod, you have several options:

**Warning**: Uninstalling the mod will remove all custom configurations and settings. If you plan to reinstall the mod later, consider using the SOFT_REMOVE option to preserve root access and configurations.

### Run Macro via Fluidd/Mainsail

Run the macro in Klipper's console:  
- `REMOVE_ZMOD` to completely remove the mod.  
- `SOFT_REMOVE` to remove the mod but preserve the root, audio, and internal mod's configuration (in case you want to install it again).  

The mod will automatically reboot and uninstall itself.

### Using USB Drive

Format a USB drive to FAT32 and place an empty file in the root directory:  
- Named `REMOVE_ZMOD` to completely remove the mod.  
- Named `SOFT_REMOVE_ZMOD` to remove the mod but preserve the root, audio, and internal mod's configuration (in case you want to install it again).  

Insert USB drive and reboot the printer. The mod will uninstall itself during boot.

### Using SSH

Log in via SSH and create an empty file in the **/opt/config/mod** directory using the following command:  
- `touch /opt/config/mod/REMOVE_ZMOD` to completely remove the mod.  
- `touch /opt/config/mod/SOFT_REMOVE_ZMOD` to remove the mod but preserve the root, audio, and internal mod's configuration (in case you want to install it again).  
 
After that, reboot. The mod will uninstall itself.



## Credits

This mod is based on ZMod by [ghzserg](https://github.com/ghzserg).
Special thanks to the Klipper and Moonraker communities for their ongoing support and development.
