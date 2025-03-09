## Uninstall

> [!CAUTION]
> After uninstalling the mod, some printer parameters will revert to stock defaults. This can affect settings like Z-Offset, Mesh Bed Leveling, and others.
> It is **strongly recommended** to review all settings and recalibrate the printer to avoid potential damage.

> [!WARNING]
> Uninstalling the mod will remove all custom configurations and settings. If you plan to reinstall the mod later, consider using the `REMOVE_MOD_SOFT` option to preserve root access and configurations.


To remove the mod, you have several options:

### Run Macro via Fluidd/Mainsail

Run the macro in Klipper's console:  
- `REMOVE_MOD` to completely remove the mod.  
- `REMOVE_MOD_SOFT` to remove the mod but preserve the root, audio, and internal mod's configuration (in case you want to install it again).  

The mod will automatically reboot and uninstall itself.

### Using USB Drive

Format a USB drive to FAT32 and place an empty file in the root directory:  
- Named `REMOVE_MOD` to completely remove the mod.  
- Named `REMOVE_MOD_SOFT` to remove the mod but preserve the root, audio, and internal mod's configuration (in case you want to install it again).  

Insert USB drive and reboot the printer. The mod will uninstall itself during boot.

### Using SSH

Log in via SSH and create an empty file in the **/opt/config/mod** directory using the following command:  
- `touch /opt/config/mod/REMOVE_MOD` to completely remove the mod.  
- `touch /opt/config/mod/REMOVE_MOD_SOFT` to remove the mod but preserve the root, audio, and internal mod's configuration (in case you want to install it again).  
 
After that, reboot. The mod will uninstall itself.

## Flashing Factory Firmware  
If you encounter uninstallation issues or firmware not working correctly, you **can** try to restore it by flashing the factory firmware.  

1. Download the factory image from [here](https://github.com/DrA1ex/zmod_docs/tree/main/%D0%A0%D0%BE%D0%B4%D0%BD%D0%B0%D1%8F_%D0%BF%D1%80%D0%BE%D1%88%D0%B8%D0%B2%D0%BA%D0%B0) or [here](https://github.com/ghzserg/zmod/tree/main/%D0%A0%D0%BE%D0%B4%D0%BD%D0%B0%D1%8F_%D0%BF%D1%80%D0%BE%D1%88%D0%B8%D0%B2%D0%BA%D0%B0)
2. Copy it to a USB drive.  
3. Insert the USB drive **before powering up** the printer.  
4. Wait **until** the firmware is installed. Don't reboot the printer **until the installation process is finished**.  
5. Your printer's firmware should be restored to the stock version.  
6. Don't forget to review the settings (or reset them in the settings) and recalibrate the printer if you are planning to use the stock firmware.  

In **hard** cases, join the [Telegram group](https://t.me/+ihE2Ry8kBNkwYzhi) to get help or refer to the [Recovery Guide](/docs/RECOVERY.md).  
