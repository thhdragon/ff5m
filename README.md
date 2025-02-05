# Flashforge Adventurer 5M Firmware Mod

This is an *unofficial* mod to run Moonraker, Klipper with essential patches, Mainsail & Fluidd on the Flashforge AD5M (Pro) 3D printers.

The mod is based on ZMod, which itself is based on Klipper-mod.

 [!CAUTION]
> *If you want to install this mod to your AD5M (Pro) then be aware, that you risk to loose your warranty or damage the printer. Proceed at your own risk if you want to try this mod!*

## Features
- **Stock** Screen with option to disable it completely to reduce resource consumption
- **Klipper** with many patches/fixes/plugins specially adapted for AD5M
- **Moonraker**
- **Fluidd** & **Mainsail**
- **Buzzer** with ability to play monotonic melodies (midi / notes)
- Patched **mjpg-streamer** with dramatically reduced memory usage
- **Timelapse** support via (Moonraker Telegram bod)[https://github.com/nlef/moonraker-telegram-bot] installed on external host
- Adaptive bed meshing - **KAMP**
- Built-in gcode **MD5** checking
- Fix for **E00017** error
- **Failsafe** against nozzle hitting
- Ecnhanced **Shaper calibration** with automatic plot generation
- Easy Bed level **screw tunning**
- Customized dedicated Linux environment based on **Buildroot**
- **Entware** package manager
- **Dual boot** with stock Flashforge software

## Installation

### Install ZMOD 1.0.5
The mod uses the same installation mechanism as the stock software:
1) Download ZMOD [1.0.5](https://github.com/ghzserg/zmod/blob/main/%D0%A1%D1%82%D0%B0%D1%80%D1%8B%D0%B5_%D0%B2%D0%B5%D1%80%D1%81%D0%B8%D0%B8/Adventurer5MPro-zmod-1.0.5.tgz) update file onto a USB flash drive.
2) Plug in the drive before starting the printer.
3) Successful installation will be indicated on the display when finished.

The mod installer currently requires that printers were updated to at least version 2.4.5 of the stock Flashforge firmware. Please check the release page for versions that are known to work.
After installation the printer will by default start the Modified stock system.

### Run the Switching Script

The mod itself comes with a pre-installed **root** accesss, allowing you to connect via SSH using the _root/root_ credentials.  
You will need to download the [switch.sh](https://github.com/DrA1ex/ff5m/blob/main/switch.sh) script, upload it to the printer, and execute it.

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

After running the script, the mod will either download the update automatically, or you may need to update the firmware manually under Fluidd's **Configuration -> Software Update -> zmod (Update)**.  

Finally, reboot your printer. The mod should now be installed.
From now on, you will receive OTA updates from this repository.

You can reach services using these addresses:
- **Moonraker**: http://<printer_ip>:7125/
- **Fluidd**: http://<printer_ip>/fluidd/
- **Mainsail**: http://<printer_ip>/mainsail/


## Slicing

You need to completely replace original start/end gcode with folowing:

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
