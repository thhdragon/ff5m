# Frequently Asked Questions

To quickly find answers, use the GitHub navigation button at the top-right corner (as shown in the image below).

<p align="center"> <img width="250" src="https://github.com/user-attachments/assets/b9d8e8bd-fcb2-4d9c-afaf-c75306573c55"> </p>

---

### Do I need to uninstall the earlier Klipper mod before installing the new mod?

It is recommended to uninstall the earlier Klipper mod before installing the new mod. However, the two mods can work together in a dual-boot setup.

By default, the printer boots into the Klipper mod. If you want to boot into the Forge-X mod, simply insert a USB drive containing the file `klipper_mod_skip`, as described in the Klipper mod documentation under [Dual Boot](https://github.com/xblax/flashforge_ad5m_klipper_mod/blob/master/docs/INSTALL.md#dual-boot).

---

### Can I install the Klipper Mod over the Forge-X mod?

Yes, you can. The Klipper Mod does not interfere with the Forge-X mod, and you can use it alongside the Dual Boot feature.  

To boot into the Forge-X mod, simply insert a USB drive containing the file `klipper_mod_skip`, as described in the Klipper Mod documentation under [Dual Boot](https://github.com/xblax/flashforge_ad5m_klipper_mod/blob/master/docs/INSTALL.md#dual-boot).

---


### Why can't I SSH into the printer after installing the mod?

Accessing the printer via SSH can be tricky after installing the Klipper mod because both mods use different SSH private keys. Your system may also block the connection due to a certificate mismatch.  

To resolve this issue, you need to remove the printer’s IP entry from the `known_hosts` file.  

**On Windows:**  
Remove the entry using Regedit (for PuTTY):  
`HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\SshHostKeys`.

**On Linux/macOS:**  
Edit the file located at `~/.ssh/known_hosts` and delete the line corresponding to your printer's IP.

Once removed, you should be able to reconnect via SSH. Forge-X use the default credentials: `root/root`.

---

### How do I adjust the camera settings?

To adjust camera parameters like brightness or contrast, edit the `camera.conf` file.  
Alternatively, you can use the web control panel at:  
`http://printer_IP:8080/control.htm`

**Note:** Changes made in the web control panel will not be saved automatically. You must manually transfer adjustments into the corresponding `E_<parameter>` properties in `camera.conf`.

---

### I adjusted the camera settings, but they are not applied after a reboot.

Some camera settings are not applied during boot-up. Instead, they are applied later—typically when a print starts.  

To apply the changes manually at any time, use the macro:  `CAMERA_RELOAD`

---

### What changes are needed to the G-code start and end commands when migrating from the old Klipper mod?

If you plan to use the stock screen, update the G-code start commands as outlined in the documentation (`/docs/SLICING.md`):

```gcode
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single]
M190 S[bed_temperature_initial_layer_single]
M104 S[nozzle_temperature_initial_layer]
```


If you are using the **Feather screen**, no changes are required.

---

### Why am I Getting MCU Shutdown with "Unable to obtain 'endstop_state' response" / "Timer too close" during START_PRINT?

This occurs when the printer’s weight sensor fails to respond within the requested time.  
It may happen due to insufficient system resources or loose wiring.

Try checking and reattaching all connections, as this may resolve the issue.  
If the problem persists, consider disabling the `weight_check` feature, as it requires taring the load cell right before the print starts, which can trigger this error.

---

### Why am I Getting "Shutdown due to sensor value exceeding the limit"?

This indicates that Bed Collision Protection was triggered due to excessive pressure on the bed.  
It’s normal if the nozzle hits the bed forcefully, but it could also be a false trigger.

For details on false triggers, see the next article.

---

### Why am I Getting a "Bed pressure detected" Error?

This safety feature is designed to prevent damage to the printer’s bed caused by the nozzle impacting it. By default, the weight limit is set to **1.2 kg**, but this can be adjusted using the `weight_check_max` parameter.

The system has two stages:  
1. **Warning**: Triggered if the weight exceeds `700g`. This serves as a precautionary notice.  
2. **Error**: Triggered if the weight exceeds a more critical threshold (e.g., `1.2 kg`). At this stage, printing will stop to protect the printer.

To customize the warning limit, you can modify the `user.cfg` file by adding the following:

```cfg
[temperature_sensor weight_value]
trigger_value: 700
```

Be careful: setting values greater than weight_check_max will increase the actual weight value when the error is triggered.

For more information, refer to the [Printing Page](https://github.com/DrA1ex/ff5m/blob/main/docs/PRINTING.md) and the [Configuration Page](https://github.com/DrA1ex/ff5m/blob/main/docs/CONFIGURATION.md).  


#### Possible causes of this error include:  
- **Weight cell calibration issues**: If you manually leveled the bed, it might require recalibration.  
- **Hardware problems**: Printer-related hardware issues may also cause this error.  


#### Resolving the Issue by Calibrating the Load Cell  

To resolve the issue, recalibrate the load cell by following Flashforge's support instructions. You can access the detailed guide via the following [link](https://docs.google.com/document/d/1Oou4A56g5HTrxBAMoH-bTnTZZ3IZyGr_3jL9tUYYiow/edit?usp=drivesdk).

You may need to calibrate the weight cell at the typical temperature you are using during printing (e.g., 70ºC).

#### Temporarily Disabling the Check  

You can either increase the threshold or disable the weight check feature using these commands:

```bash
# Increase threshold
SET_MOD PARAM="weight_check_max" VALUE=1800

# Disable the feature
SET_MOD PARAM="weight_check" VALUE=0
```

*Note:* It is strongly advised to investigate and fix any underlying hardware or kinematic issues after implementing these changes.

--- 

### What should I do about the warning after an SSH connection: `wtmp_write: problem writing /dev/null/wtmp: Not a directory`?

You can safely ignore this warning. It indicates that a core system configuration in the firmware is incomplete, but it does not affect your printer’s functionality.

---

### How do I upload files to the printer?

You can upload files using `scp` with the `-O` flag (legacy mode).  

**Example commands:**  
```bash
# Upload files
scp -O path/to/files/file root@<printer-ip>:/path/to/directory

# Download files
scp -O root@<printer-ip>:/path/to/file /path/to/directory
```

If your version of `scp` does not support the `-O` flag, you can upload files directly via the Fluidd web interface. Files uploaded to Fluidd are stored in `/data`.  

To download files, move them to `/data` and then download them via Fluidd.

---

### Stock Screen Freezes: I Can't Print Anything

This happens because the stock screen does not support Moonraker external control over the printer.

You cannot run `SAVE_CONFIG`, `RESTART`, or `FIRMWARE_RESTART` without causing the stock screen to freeze.

If this happens, you won't be able to print, as printing requires the stock screen to function. Simply reboot the printer if this occurs.

Consider switching to Feather Screen. Refer to [this guide](/docs/SCREEN.md) for details.

For `SAVE_CONFIG`, there is an alternative macro that attempts to reload the screen gracefully.   

```
NEW_SAVE_CONFIG
```

Note: It uses a debugger to interface with the firmware and save configurations programmatically, so compatibility varies across firmware versions.

---

### Feather Screen stuck on the "Finishing boot..."

This happens if Klipper is not becoming ready.  
Usually, the reason is a broken configuration or the MCU not becoming ready.

If you reboot the printer using the `reboot` command and do not power it off and on, the MCU won't reset, which may also cause this issue.

In that case, you need to perform a `FIRMWARE_RESET`.

At this point, you should have network, Fluidd, and SSH access, so you can connect to the printer and figure out what happened.

---

### My printer is stuck on the Stock initialization screen. How can I fix it?

This issue is likely caused by a bug in the newer Flashforge firmware (version `3.1.*`), where the firmware freezes if it fails to connect to a network during initialization.  

For now, reboot the printer by powering it off and back on. This problem is flickering — most of the time the firmware works fine, but occasionally it gets stuck.  

To avoid this issue, you can downgrade the stock firmware to version `2.7.*`, as this bug seems to occur only in version `3.1.*`. Alternatively, switching to the Feather screen eliminates this issue entirely because the Feather screen operates independently and does not rely on the problematic firmware.

---

### My printer is stuck on the screen with a black-and-white Flashforge logo. How can I fix it?

If you encounter this issue, something may be preventing your printer from booting properly.  
This is not a mod-related issue, as the mod only loads after the printer begins booting and displays its own splash screen.

The problem could be hardware- or software-related.

You can try flashing the [Factory image](https://github.com/DrA1ex/ff5m/blob/main/docs/UNINSTALL.md#flashing-factory-firmware) to resolve this.  
If it doesn't work, try flashing the [Recovery image](/docs/RECOVERY.md#recovery-using-flashing-image), [Uninstall image](/docs/UNINSTALL.md#using-uninstall-image), and then the [Factory image](/docs/UNINSTALL.md#flashing-factory-firmware).  
Also, refer to the [Recovery Guide](/docs/RECOVERY.md) — there are plenty of ways to restore your printer's functionality.

If nothing works or if this happens periodically, it is more likely a hardware issue. Contact FlashForge support if the steps fail, but do not mention any mods or recovery images you may have flashed (as they are not relevant to them anyway), since doing so will likely void your warranty.

---

### My printer is stuck on the screen with the Forge-X logo. How can I fix it?

In this case, the printer will display loading information. If it's a Wi-Fi issue, refer to the next section.  
If it’s not a network issue, the resolution will depend on what actually caused the problem. Create an issue report if the problem persists.

You can skip the mod during boot by following [this instruction](/docs/DUAL_BOOT.md).  
Alternatively, you can uninstall the mod by following [this instruction](/docs/UNINSTALL.md).

**Note:** It’s not recommended to flash over a different firmware version without first removing the mod, as this could brick your printer. If that happens, you may still be able to restore it. Refer to the [recovery guide](/docs/RECOVERY.md) for more information.

---

### The mod isn’t loading and is stuck at the network connection step.

This can happen when you are using the Feather screen, and the mod cannot connect to the network.  
Since the mod requires a network connection to function, it will keep attempting to connect until successful.

Printers are often metal-shielded, meaning Wi-Fi signals may struggle to reach the antenna.  
Consider switching to a 2.4 GHz Wi-Fi network. You can do this from the stock screen or by manually editing the `/etc/wpa_supplicant.conf` configuration file.

If the mod still cannot connect within 5 minutes, the stock screen will load instead.

If the mod doesn’t load at all, refer to [this instruction](https://github.com/DrA1ex/ff5m/blob/main/docs/SCREEN.md#switching-to-feather-screen) to switch back to the original stock screen.

---

### My printer won’t boot. I can’t skip the mod, flash firmware, or do anything.

If this happens, something has gone seriously wrong. Don’t worry—there’s still a way to unbrick your printer.  
Refer to the [recovery guide](/docs/RECOVERY.md) for detailed instructions on how to restore your printer.


### Print/Shaper Calibration Stops with "MCU 'mcu' Shutdown: Timer Too Close"

This error may occur due to memory limitations, MCU issues, or overheating. Below are troubleshooting steps to resolve it:

#### Memory Issues
- Check memory usage by running the `MEM` macro in your printer firmware.  
- High memory consumption is often caused by the camera.  
  - Switch to the mod’s [Camera Implementation](/docs/CAMERA.md) for lower resource usage.  
- Follow the [Resource Usage Reduction Guide](/docs/PRINTING.md#reducing-resource-usage).   

#### Internal MCU Issues
- These are not tied to specific causes and may result from sensor read/write processes.  
  - **No Specific Fixes**: As these are internal MCU errors, the mod cannot address them directly.  
  - Try disabling `weight_check`, `filament_switch_sensor`, or similar parameters to reduce MCU interactions during printing.  
  - Avoid changing fan, LED, or similar settings during printing.

#### Overheating Issues
- Inspect the driver fan on the motherboard to ensure it’s functioning:  
  - Remove the printer’s back plate by unscrewing it.  
  - Verify that the fan is operational and not obstructed.

---


### Can I calibrate the printer using the stock screen (Fluidd)? Will it work?

Yes, it will work. The stock screen interacts with Klipper directly, so anything you do with Klipper will also be reflected in both the stock firmware and the mod.

The key difference is that the mod allows you to set the temperature for calibration, a feature not available on the stock screen.

---

### Unable to Access Stock Debug Console for Load Cell Calibration

If you're having trouble, try pressing the console button using a stylus or a thin object. This may resolve the issue.

---

### Why Does the Printer Boot in Failsafe Mode but Still Show Feather?

Failsafe mode is designed to completely skip all mod code execution during boot.  
Its sole purpose is to prevent you from being left with a bricked printer in case of a mod failure.

If you only want to skip the mod, use [Dual Boot](/docs/DUAL_BOOT.md) instead.  
It will gracefully skip the mod, leaving you with a fully functional stock system.

---
