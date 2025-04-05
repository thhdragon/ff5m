# Printing

Printing starts and ends with `START_PRINT` and `END_PRINT` macros.  
You can pause and resume printing using the `PAUSE` and `RESUME` macros.  
To cancel a print, use the `CANCEL_PRINT` macro.    

If there is a pending temperature change operation (initiated by the mod only, Klipper's M109 and M190 won't work), you can cancel the wait using the `M108` macro.   
This cancels any active wait and execute `CANCEL_PRINT` if printing is active.

For detailed instructions on configuring your slicer, refer to the [Slicing](../docs/SLICING.md) section.

> [!WARNING]
> After installing the mod, some printer parameters may revert to stock or change. This can affect settings like Z-Offset and Mesh Bed Leveling. It is **strongly recommended** to review and recalibrate these settings to avoid potential damage.

## Calibration

To calibrate the printer, use only these macros (or the Stock screen).  
All of these macros are available in the Fluidd/Mainsail main screen in the section **Calibration**:

- `AUTO_FULL_BED_LEVEL`: Bed meshing.  
  - `EXTRUDER_TEMP` temperature of the nozzle (default `240`)  
  - `BED_TEMP` temperature of the bed (default `80`)  
  - `PROFILE` profile to save (default `auto`)  

- `PID_TUNE_BED`: Bed PID calibration.  
  - `TEMPERATURE` temperature of the bed (default `80`)  

- `PID_TUNE_EXTRUDER`: Extruder PID calibration.  
  - `TEMPERATURE` temperature of the nozzle (default `245`)  

- `ZSHAPER`: Shaper calibration  

You can read more about Klipper calibration in the Klipper documentation: [https://www.klipper3d.org/](https://www.klipper3d.org/)

> [!NOTE]  
> You can't use the standard Klipper macro for calibration, since AD5M uses non-standard features, which need special preparation steps, and the default macro will not work as expected.  
> For example: the standard Klipper macro `BED_MESH_CALIBRATE` doesn’t perform the weight sensor reset, as it’s a non-standard step specific to AD5M, which may lead to weight exceed warnings or incorrect bed meshing altogether.

## Bed Mesh

The printer uses different bed meshes depending on the scenario:

- When using the Stock UI, the firmware will load the `MESH_DATA` profile.
- When using the Feather Screen, the mod will load the `auto` profile.
- When using the option to [force leveling](https://github.com/DrA1ex/ff5m/blob/main/docs/SLICING.md#parameters), the mod will save the mesh to the `default` profile. After the print is completed, the profile will be deleted.

> [!NOTE]  
> If no profile with the required name exists, the printer will perform leveling before the print begins.    
> Make sure to use the `SAVE_CONFIG` command after leveling to save the mesh properly.

# KAMP

Follow these steps to set up KAMP (Klipper Adaptive Meshing and Purging):

1. **Enable the Mod Parameter**  
   ```
   SET_MOD_PARAM PARAM=use_kamp VALUE=1
   ```   
   Optionally, temporarily enable it via `START_PRINT`:  
   ```
   START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single] FORCE_KAMP=1
   ```

2. **Enable "Exclude Objects" in Slicer**  
   - **Orca Slicer**: *Process Profile → Other → Exclude objects*  
   - **Prusa Slicer**: Go to *Print Settings → Output options → Label objects*, check the "Label objects"

3. **Modify START_GCODE for KAMP**  
   Add this before the `START_PRINT` macro to handle supports, skirts, and other non-model objects:  
   - **For Orca**:  
     ```
     KAMP_DEFINE_AREA MIN={first_layer_print_min[0]},{first_layer_print_min[1]} MAX={first_layer_print_max[0]},{first_layer_print_max[1]}
     ```   
   - **For Prusa**: 
     ```
     KAMP_DEFINE_AREA MIN={min_x},{min_y} MAX={max_x},{max_y}
     ```

4. **Purging Notes**  
   *KAMP* defaults to `LINE_PURGE` instead of other cleaning algorithms. Avoid adding alternative algorithms (e.g., directly in starting G-code), as KAMP meshes a limited bed region, and default cleaning methods may damage the bed.  
   To disable priming entirely *(optional)*:  
   ```
   SET_MOD_PARAM PARAM=disable_priming VALUE=1
   ```   

## Bed Collision Protection

To avoid bed scratching caused by the nozzle hitting the bed, the mod includes a collision detection feature.  
It is controlled by the following mod's [parameters](/docs/CONFIGURATION.md):
- `weight_check`: Enables or disables collision detection.
- `weight_check_max`: Sets the maximum tolerable weight (in grams).

> [!WARNING]
> Don’t set `weight_check_max` too low. Legitimate situations, such as the nozzle scratching an overextruded model or the weight of the model itself, can trigger false stops.  
> Over time, the bed's weight may also increase during long prints (weight of the model itself).

## Bed Mesh Validation

To prevent printing issues caused by an invalid bed mesh, the mod includes a **Bed Mesh Validation** feature. This feature checks the bed mesh before starting a print and ensures it matches the current printer configuration.   
Common scenarios where this is useful include:
- Using a bed mesh created for a different bed plate.
- Printing without a bed plate installed.
- Accidentally changing essential kinematics parameters that affect Z movement.

It is controlled by the following mod's [parameters](/docs/CONFIGURATION.md):
- `bed_mesh_validation`: Enable or disable bed mesh validation. Set to 1 to enable.
- `bed_mesh_validation_clear`: Enable or disable nozzle cleaning before bed mesh validation. Set to 1 to enable.
- `bed_mesh_validation_tolerance`: Set the maximum allowed Z-offset tolerance (in mm). The default value is 0.2.

> [!NOTE]
> Ensure the `bed_mesh_validation_tolerance` is set appropriately for your setup. A value too low may trigger false negatives, while a value too high may miss critical issues.

### How it works:
- Before starting a print, the mod compares the current bed mesh with the printer's expected Z movement.
- If the Z-offset exceeds the configured tolerance (`bed_mesh_validation_tolerance`), the print is canceled to prevent potential damage.
- A warning is logged, and the user is notified to recalibrate the bed mesh or check the printer configuration.

> [!NOTE]
> Bed Mesh Validation may produce false negatives if your nozzle is very dirty, as this can affect the accuracy of probing and the correct Z-offset position. Always ensure your nozzle is clean before starting a print.

## Sound
You can customize sound indications or completely disable them. Additionally, you can configure MIDI playback for specific events. Available MIDI files are located in **Configuration -> mod_data -> midi**. You can also add your own MIDI files by uploading them to the **midi** folder.
It is controlled by the following mod's [parameters](/docs/CONFIGURATION.md):
- `sound`: Disable all sound indication by setting this parameter to 0.
- `midi_on`: Play MIDI when the printer boots.
- `midi_start`: Play MIDI when a print starts.
- `midi_end`: Play MIDI when a print finishes.

## LED light Control

Use the `LED S=<PERCENT>` macro to set LED brightness (e.g., LED S=75).
Use `LED_ON` and `LED_OFF` to toggle the LED.

The mod also includes a LED klipper's plugin, which allows inverting LED controls in cases where the LED is connected using a non-standard scheme.   
To enable this feature, you need to add a parameter in the `user.cfg` file (see [Configuration](/docs/CONFIGURATION.md)).  

```ini
[led chamber_light]  
invert: False       ; Use inverted control when set to True (Default: False).
initial_WHITE: 0.2  ; Optional: Set the initial brightness value.
```  

> [!NOTE]
> The stock firmware controls the LED by default. You can disable this behavior by configuring the mod (as described in [Configuration](/docs/CONFIGURATION.md)).  
> - If left enabled, you won’t be able to manage the initial brightness using user.cfg.  
> - If disabled, LED control from the stock screen will no longer work.  


```bash
SET_MOD_PARAM PARAM="disable_screen_led" VALUE=1
```

## Automation

It is controlled by the following mod's [parameters](/docs/CONFIGURATION.md):
- `stop_motor`: Automatically disables motors after inactivity.
- `auto_reboot`: Reboots the printer after a print finishes. Options: OFF, SIMPLE_90, or FIRMWARE_90.
- `close_dialogs`: Automatically closes stock firmware dialogs after 20 seconds. Options: OFF, SLOW, or FAST.

## Z-Offset 

In the stock firmware, Z-Offset is controlled directly through the firmware's screen.
For the alternative screen (or headless mode), use the following mod [parameters](/docs/CONFIGURATION.md):
- `load_zoffset`: Load the saved Z-Offset value.
- `z_offset`: Manually set the Z-Offset value.

Macros:
- `LOAD_GCODE_OFFSET`: Load and apply Z-Offset from mod's parameter
- `SET_GCODE_OFFSET`: It's standard Klipper macro to apply Z-Offset, but it's also save value to the mod's parameter

Example:
```bash
# Enable global Z-offset management
SET_MOD_PARAM PARAM="load_zoffset" VALUE=1

# Set custom Z-offset (loaded in START_PRINT only if `load_zoffset` enabled)
SET_MOD_PARAM PARAM="z_offset" VALUE=0.25
```

## Nozzle Cleaning

The mod provides several options for priming line and nozzle cleaning before a print.   
These are controlled by the following [parameters](/docs/CONFIGURATION.md):
- `zclear`: Configure the purge line algorithm (e.g., `ORCA` - like Orca Slicer do).
- `disable_priming`: Disable nozzle priming by setting this parameter to 1.

## Fixing E0017 Error
In stock firmware, some internal Klipper parameters controlling the **Move Queue** are not optimally configured, which can cause the **E0017** error (**Move Queue Overflow**).  
To fix this, enable the mod [parameter](/docs/CONFIGURATION.md):
```bash
SET_MOD_PARAM PARAM="fix_e0017" VALUE=1
```

## Using stock Firmware with mod

Some mod features, like fast dialog closing, may not work unless the stock firmware parameter "Use only local networks" is enabled. It is recommended to set this parameter for all users.
