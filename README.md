# Flashforge Adventurer 5M Firmware Mod

This is FF AD5m mod, based on zmod, which based on klipper-mod.

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
