## Uninstall

To remove the mod, you have several options:

**Warning**: Uninstalling the mod will remove all custom configurations and settings. If you plan to reinstall the mod later, consider using the `REMOVE_MOD_SOFT` option to preserve root access and configurations.

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
