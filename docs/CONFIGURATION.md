## Mod Configuration

The mod uses its own global configuration management system. The configuration file is located in Fluidd under Configuration -> mod_data -> variables.cfg.

However, manually editing this file is not recommended. Parameters alone don't directly control behavior; special scripts handle parameter changes and perform the necessary actions. Instead, use the provided macros to modify settings.

### Configuration Macros
- `LIST_MOD_PARAMS`: Lists all available mod parameters and their current values. Use this to explore the full range of configurable settings.
- `GET_MOD_PARAM PARAM=<name>`: Retrieves the current value of a specific parameter.
- `SET_MOD_PARAM PARAM=<name> VALUE=<value>`: Sets a new value for a specific parameter.

### Parameters Overview
The mod supports a wide range of parameters to customize printer behavior. Below is a summary of key parameters. For a complete and up-to-date list, always use the `LIST_MOD_PARAMS` macro.

#### Key Parameters
- `auto_reboot`: Configures automatic restart behavior.
  - `OFF`: Disabled
  - `SIMPLE_90`: Restarts after 1.5 minutes
  - `FIRMWARE_90`: Firmware restarts after 1.5 minutes

- `close_dialogs`: Controls dialog timeout behavior.  
  - `OFF`: Dialogs remain open
  - `SLOW`: Closes after 20 seconds (slow fade)
  - `FAST`: Closes after 20 seconds (quick fade)

- `disable_priming`: Disables nozzle cleaning by line if set to 1.

- `disable_screen_led`: Allows the mod to control the screen LED if set to 1.

- `disable_skew`: Disables skew correction if set to 1.

- `fix_e0017`: Enables a fix for the E0017 error if set to 1.

- `check_md5`: Enables MD5 checksum verification for G-code files.  
**Note:** Requires a post-processing script in your slicer. Scripts are available in Configuration -> mod (addMD5.sh or addMD5.bat).

- `use_kamp`: Enables KAMP (Klipper Adaptive Meshing and Purging) if set to 1.

- `camera`: Enables the alternative camera implementation if set to 1.

- `weight_check`: Enables bed Mesh validation protection if set to 1.

- `bed_mesh_validation`: Enables bed collision protection if set to 1.

- `tune_config`: Allows firmware parameter tuning for recommended settings: optimized motors/extruder rotation distance, better probbing, z-parking and more.  
**Warning:** After changing this value, recreate the bed mesh, adjust Z-Offset, and optionally recalibrate flow and Pressure Advance.  
You can find changed parameters here: [tuning.cfg](/tuning.cfg)


## Backup Management

The mod includes a backup and restore system for the printer's configuration (`printer.base.cfg`). This is essential because stock firmware updates can alter critical parameters, such as `rotation_distance` for steppers, which may lead event to printer damage if not corrected.
To prevent this, the mod provides a backup management system.

### Configuring Backup Parameters

You can define which parameters or sections to include in the backup by editing the file located in Fluidd under **Configuration -> mod_data -> backup.params.cfg**.  
The syntax is straightforward:

```cfg
[include /path/to/conf.cfg]        # Add an include if it's missing
[include /path/to/conf.cfg] defer  # Add an include at the end of the file if it's missing
[section name]                     # Backup the entire section with all its parameters
[section name] parameter_name      # Backup only this specific parameter within the section

-[include /path/to/conf.cfg]       # Remove an include if it's present
-[section name]                    # Remove the entire section from the config
-[section name] parameter_name     # Remove a specific parameter from the section
```

### Backup & Restore

- **Automatic Restore**: The last created backup is automatically restored during the printer's boot process.
- **Manual Backup**: Backups are not created automatically. You must manually run the `CONFIG_BACKUP` macro to create a backup.

###  Available Macros

- `CONFIG_BACKUP`: Creates a backup of the current configuration.
- `CONFIG_RESTORE`: Restores the configuration using the most recent backup.
- `CONFIG_VERIFY`: Checks if the configuration has changed since the last backup.
- `BACKUP_TAR`: Creates a .tar archive containing all configuration files for easy storage or transfer.

## User-Defined Parameters

The mod allows you to customize and extend functionality by defining your own macros or overriding existing printer parameters. This override any printer configuration, including `tuning.cfg`. Additionally, you can adjust Moonraker-specific parameters.

**Note**: Changes to `user.cfg` and `user.moonraker.conf` are applied after a restart or configuration reload.

### Customizing Printer Parameters

To add or override printer parameters, edit the file located in Fluidd under **Configuration -> mod_data -> user.cfg**.  
This file allows you to:

- Define new macros.
- Override existing parameters (e.g., from tuning.cfg).
- Add custom configurations.

**Example:**

```cfg
[gcode_macro MY_CUSTOM_MACRO]
description: My custom macro
gcode:
  M117 Hello, World!

[stepper_x]
rotation_distance: 40  # Override the rotation_distance for the X stepper
```

### Customizing Moonraker Parameters
To modify Moonraker-specific settings, edit the file located in Fluidd under **Configuration -> mod_data -> user.moonraker.conf**.  
This file allows you to adjust Moonraker behavior, such as API settings, notifications, or plugins.

**Example:**

```cfg
[authorization]
force_logins: true  # Require login for all users

[notifier]
url: http://example.com/notify  # Custom notification endpoint
```
