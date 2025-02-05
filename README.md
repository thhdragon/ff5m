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


## Installation

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
