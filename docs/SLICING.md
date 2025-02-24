## Slicing

To use the mod, you need to replace your slicer's default start and end G-code with the following configurations. These snippets are for _OrcaSlicer_. If you use a different slicer, adjust the placeholders accordingly.

#### For Stock Screen

Start Gcode
```
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single]
M190 S[bed_temperature_initial_layer_single]
M104 S[nozzle_temperature_initial_layer]
```

End Gcode
```
END_PRINT
```

#### For Alternative Screen (Feather Screen)

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



### START_PRINT
The `START_PRINT` macro is used to initialize the printing process with customizable parameters. It allows you to configure the extruder temperature, bed temperature, and various leveling options to suit your specific needs.

#### Parameters

- `EXTRUDER_TEMP`: Sets the extruder temperature for the print. This is typically configured by the slicer.  
  **Default**: 245  
  **Example**: `EXTRUDER_TEMP=230`  

- `BED_TEMP`: Sets the bed temperature for the print. This is also typically configured by the slicer.  
  **Default**: 80  
  **Example**: `BED_TEMP=60`  

- `FORCE_KAMP`: Forces the KAMP (Klipper Adaptive Meshing and Purging) bed leveling process if set to 1.  
  **Default**: 0  
  **Example**: `FORCE_KAMP=1`  

- `FORCE_LEVELING`: Forces the bed leveling process if set to 1.  
  **Default**: 0  
  **Example**: `FORCE_LEVELING=1`  

- `SKIP_LEVELING`: Skips the bed leveling process if set to 1.  
  **Default**: 0  
  **Example**: `SKIP_LEVELING=1`  

- `SKIP_ZOFFSET`: Skips setting the Z offset if set to 1. This is useful when printing from the stock screen, which loads Z-Offset automatically.  
  **Default**: 1  
  **Example**: `SKIP_ZOFFSET=0`  

- `Z_OFFSET`: Manually sets the Z offset.  
  **Default**: 0.0  
  **Example**: `Z_OFFSET=0.2`  
