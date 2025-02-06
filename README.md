# Flashforge Adventurer 5M Firmware Mod

This is an _unofficial_ mod to run Moonraker, Klipper (with essential patches), Mainsail, and Fluidd on the Flashforge AD5M (Pro) 3D printers.
The mod is based on ZMod, which itself is derived from Klipper-mod.

> [!CAUTION]
> *If you choose to install this mod on your AD5M (Pro), be aware that you risk voiding your warranty or damaging your printer.*
> *Before installation and after uninstallation, ensure that you check all printer parameters and perform a full recalibration. Failing to do so may result in damage to your printer.*
> *Proceed at your own risk!*

## Features
- **Stock** Screen with option to disable it completely to reduce resource consumption
- **Klipper** with many patches/fixes/plugins specially adapted for AD5M
- **Moonraker**
- **Fluidd** & **Mainsail**
- **OTA** updates
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
- Offer a reliable foundation for advanced users to build upon.
- Fix long-standing bugs and optimize performance for the AD5M (Pro).
- Introduce modern features and tools that enhance the 3D printing experience.
- Ensure flexibility and openness for future improvements and community contributions.

By addressing these challenges, this mod strives to unlock the full potential of the Flashforge AD5M (Pro) and provide users with a seamless, powerful, and customizable 3D printing platform.

## Installation

This mod is designed to be uninstalled at any time, completely and effortlessly.
If the mod encounters issues or you simply prefer to use the stock firmware, you can easily switch back without any complex procedures.
Additionally, the mod includes a **dual-boot** feature as a failsafe measure. This ensures that you can restore full functionality even if any part of the mod does not work as intended.

> [!CAUTION]
> *After mod installation or uninstallation, always run all calibrations, as the mod can affect certain parameters, invalidating previous calibration settings.*
> *Printing without recalibration may damage the printer, the bed surface, or negatively impact print quality.*
> *Proceed at your own risk!*


### Prerequisites
- A USB flash drive formatted to FAT32.
- A computer with SSH and SCP capabilities (e.g., Terminal on macOS/Linux or PuTTY/WinSCP on Windows).
- Basic familiarity with command-line tools.


### Install ZMOD 1.0.5

The mod uses the same installation mechanism as the stock firmware:
1) Download ZMOD [1.0.5](https://github.com/ghzserg/zmod/blob/main/%D0%A1%D1%82%D0%B0%D1%80%D1%8B%D0%B5_%D0%B2%D0%B5%D1%80%D1%81%D0%B8%D0%B8/Adventurer5MPro-zmod-1.0.5.tgz) update file onto a USB flash drive.
2) Plug in the drive before starting the printer.
3) Successful installation will be indicated on the display when finished.

**Note**: The mod installer currently requires the printer to be updated to at least version **2.4.5** of the stock Flashforge firmware.
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


## Firmware Recovery Guide

If you’ve modified internal system files and something went wrong—your printer no longer responds to a USB drive (you can’t flash the Factory firmware), and it doesn’t progress past the boot screen—don’t worry. This is fixable, and it doesn’t require advanced skills. Let’s start by diagnosing the issue.

### Diagnostics

To understand the problem, you’ll need a **UART-USB** adapter that supports **3.3V** logic levels. Using a 5V adapter can **damage** the motherboard, so be careful. Alternatively, you can use an ESP8266/ESP32 (do not use an Arduino, as it operates at 5V and could **fry the CPU**). Flash the ESP with the MultiSerial example from the Arduino IDE `(Examples -> Communications -> MultiSerial)`.

Next, connect the UART adapter to the motherboard near the processor (next to USB0). Connect the wires as follows:
- **RX** on the adapter to **TX** on the motherboard.
- **TX** on the adapter to **RX** on the motherboard.
- **GND** to **GND**.
- Do **not** connect the power line.

Connect the adapter to your PC and open a terminal program (e.g., PuTTY, Arduino IDE, or PlatformIO). Power on the printer and observe the logs. 
These logs will help you determine how far the boot process goes. If the Linux kernel loads, the situation isn’t too bad, and you might be able to fix it without advanced procedures.

For a detailed guide on UART connections, refer to this resource: [link](https://t.me/FF_5M_5M_Pro/441456/487025).

### The Easy Way

If the Linux kernel loads but the system fails to boot due to your modifications, you can try rolling back those changes. Here’s how:
1. Connect to the printer via UART as described above.
2. Wait for the following line to appear in the logs:
```
Hit any key to stop autoboot
```

3. Quickly press Enter.

4. You’ll now be in **U-Boot**. From here, you can redefine the kernel startup command to get a shell. Enter the following commands:

```
setenv init /bin/sh
boot
```

5. If done correctly, you’ll get a shell after the Linux kernel loads. The filesystem will be mounted as read-only, so remount it as read-write:

```
mount -t proc proc /proc
mount -o remount,rw /
```

6 Now, fix whatever changes caused the issue. Note that the system isn’t fully booted, so some features may not work. Search online for solutions or ask for help in the community.

7. Once you’re done, reboot the system:

```
sync
reboot -f
```

The system should now boot normally. You can leave the UART connected if needed. If SSH isn’t working, you can log in via UART using the credentials root/root.

If this method doesn’t work, don’t lose hope. If the system partially boots, you might still be able to recover files via UART.

### The Hard Way

If the easy method doesn’t work and the system is completely unbootable, you’ll need to restore the firmware using FEL mode. This requires a firmware dump and some additional steps.

1. Enter FEL Mode:

- You don’t need to solder a button to a resistor. Instead, interrupt the boot process via UART (press Enter when prompted) to enter U-Boot.
- From U-Boot, run the following command to enter FEL mode:

```
efex
```

2. Prepare for Recovery:

- You’ll need to desolder USB0. This is relatively simple, even for beginners.

- Use the firmware dump and tools provided here: [link](https://disk.yandex.ru/d/oie2Chx1rexkgw).

3. Follow the Detailed Guide:

For step-by-step instructions, refer to this resource: [link](https://t.me/FF_5M_5M_Pro/441456/487025).

### Important Notes

Always double-check your connections when using UART to avoid damaging the hardware.
If you’re unsure about any step, ask for help in the community before proceeding.

Backup your system files before making any modifications to avoid recovery scenarios.


## Credits

This mod is based on ZMod by [ghzserg](https://github.com/ghzserg).

Thanks to the Klipper and Moonraker communities for their ongoing development.

Special thanks to the Russian FlashForge Adventurer 5M Telegram Community: [@FF_5M_5M_Pro](https://t.me/FF_5M_5M_Pro)
