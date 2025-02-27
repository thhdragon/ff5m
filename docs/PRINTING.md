# Printing

Printing starts and ends with `START_PRINT` and `END_PRINT` macros.  
You can pause and resume printing using the `PAUSE` and `RESUME` macros.  
To cancel a print, use the `CANCEL_PRINT` macro.    

If there is a pending temperature change operation (initiated by the mod only, Klipper's M109 and M190 won't work), you can cancel the wait using the `M108` macro.   
This cancels any active wait and execute `CANCEL_PRINT` if printing is active.

> [!WARNING]
> After uninstalling the mod, some printer parameters may revert to stock defaults. This can affect settings like Z-Offset and Mesh Bed Leveling. It is **strongly recommended** to review and recalibrate these settings to avoid potential damage.


## Bed Collision Protection

To avoid bed scratching caused by the nozzle hitting the bed, the mod includes a collision detection feature.  
It is controlled by the following mod's [parameters](docs/CONFIGURATION.md):
- `weight_check`: Enables or disables collision detection.
- `weight_check_max`: Sets the maximum tolerable weight (in grams).

> [!WARNING]
> Don’t set `weight_check_max` too low. Legitimate situations, such as the nozzle scratching an overextruded model or the weight of the model itself, can trigger false stops.  
> Over time, the bed's weight may also increase during long prints (weight of the model itself).

## Sound
You can customize sound indications or completely disable them. Additionally, you can configure MIDI playback for specific events. Available MIDI files are located in **Configuration -> mod_data -> midi**. You can also add your own MIDI files by uploading them to the **midi** folder.
It is controlled by the following mod's [parameters](docs/CONFIGURATION.md):
- `sound`: Disable all sound indication by setting this parameter to 0.
- `midi_on`: Play MIDI when the printer boots.
- `midi_start`: Play MIDI when a print starts.
- `midi_end`: Play MIDI when a print finishes.

## LED light Control

Use the `LED S=<PERCENT>` macro to set LED brightness (e.g., LED S=75).
Use `LED_ON` and `LED_OFF` to toggle the LED.

Set the default LED brightness by modifying the [led chamber_light] section in user.cfg (see [Configuration](docs/CONFIGURATION.md)).
> [!NOTE]
> The stock firmware controls the LED by default. Disable this by setting the mod [parameter](docs/CONFIGURATION.md):

```bash
SET_MOD_PARAM PARAM="disable_screen_led" VALUE=1
```

## Automation

It is controlled by the following mod's [parameters](docs/CONFIGURATION.md):
- `stop_motor`: Automatically disables motors after inactivity.
- `auto_reboot`: Reboots the printer after a print finishes. Options: OFF, SIMPLE_90, or FIRMWARE_90.
- `close_dialogs`: Automatically closes stock firmware dialogs after 20 seconds. Options: OFF, SLOW, or FAST.

## Z-Offset 

In the stock firmware, Z-Offset is controlled directly through the firmware's screen.
For the alternative screen (or headless mode), use the following mod [parameters](docs/CONFIGURATION.md):
- `load_zoffset`: Load the saved Z-Offset value.
- `z_offset`: Manually set the Z-Offset value.

## Nozzle Cleaning

The mod provides several options for priming line and nozzle cleaning before a print.   
These are controlled by the following [parameters](docs/CONFIGURATION.md):
- `zclear`: Configure the purge line algorithm (e.g., `ORCA` - like Orca Slicer do).
- `disable_priming`: Disable nozzle priming by setting this parameter to 1.

## Fixing E0017 Error
In stock firmware, some internal Klipper parameters controlling the **Move Queue** are not optimally configured, which can cause the **E0017** error (**Move Queue Overflow**).  
To fix this, enable the mod [parameter](docs/CONFIGURATION.md):
```bash
SET_MOD_PARAM PARAM="fix_e0017" VALUE=1
```

## Using stock Firmware with mod

Some mod features, like fast dialog closing, may not work unless the stock firmware parameter "Use only local networks" is enabled. It is recommended to set this parameter for all users.
