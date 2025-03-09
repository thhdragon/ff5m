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


### (Temporary) Install ZMOD 1.0.4

The mod uses the same installation mechanism as the stock firmware:  
1) Download the ZMOD [1.0.4](https://github.com/DrA1ex/zmod_docs/raw/refs/heads/main/Adventurer5MPro-zmod-1.0.4.tgz) update file onto a USB flash drive.  
2) Rename the file to match your printer version. For non-Pro, rename the file to `Adventurer5M-zmod-1.0.4.tgz`. For Pro, it should remain named `Adventurer5MPro-zmod-1.0.4.tgz`.  
3) Insert the USB flash drive into the printer before powering it on.
4) The printer will automatically install the update and reboot upon successful installation.  
5) Once the installation is complete, you can verify it by accessing `Fluidd` at `http://PRINTER_IP`.

If you encounter any issues, you can see this [thread](https://github.com/DrA1ex/ff5m/issues/4#issuecomment-2708739454)

**Note**: The mod installer currently requires the printer to be updated to at least version **2.6.5** of the stock Flashforge firmware.
After installation, the printer will boot into the modified stock system by default.

### (Temporary) Install dependencies

The mod comes with pre-installed **root** access, allowing you to connect via SSH using the credentials _root/root_.

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
opkg update
opkg install mjpg-streamer_1.0.1-1_armv7-3.2.ipk mjpg-streamer-input-uvc_1.0.1-1_armv7-3.2.ipk mjpg-streamer-output-http_1.0.1-1_armv7-3.2.ipk

# Install additional packages
opkg install busybox htop nano zsh
```

### Run the Switching Script

Download the [switch.sh](https://github.com/DrA1ex/ff5m/blob/main/switch.sh) script, upload it to the printer, and execute it.

```bash
PRINTER_IP="<your_printer_IP>"

# Upload the script to the printer
scp -O ./switch.sh "root@$PRINTER_IP:/opt"

# Log in to the printer
ssh "root@$PRINTER_IP"

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

