## Dual Boot

The mod implements a failsafe mechanism to boot the stock firmware before executing any mod-related boot code. This ensures that if the mod encounters any issues, you can safely skip the mod's boot process and load into the stock firmware.

> [!CAUTION]
> *Skipping the mod doesn't revert the printer's configuration; it only prevents the mod's services from running.*

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
