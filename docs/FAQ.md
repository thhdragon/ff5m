# Frequently Asked Questions

### Do I need to uninstall the earlier Klipper mod before installing the new mod?

It is recommended to uninstall the earlier Klipper mod before installing the new mod. However, the two mods can work together in a dual-boot setup.

By default, the printer boots into the Klipper mod. If you want to boot into the Forge-X mod, simply insert a USB drive containing the file `klipper_mod_skip`, as described in the Klipper mod documentation under [Dual Boot](https://github.com/xblax/flashforge_ad5m_klipper_mod/blob/master/docs/INSTALL.md#dual-boot).

---

### Can I install the Klipper Mod over the Forge-X mod?

Yes, you can. The Klipper Mod does not interfere with the Forge-X mod, and you can use it alongside the Dual Boot feature.  

To boot into the Forge-X mod, simply insert a USB drive containing the file `klipper_mod_skip`, as described in the Klipper Mod documentation under [Dual Boot](https://github.com/xblax/flashforge_ad5m_klipper_mod/blob/master/docs/INSTALL.md#dual-boot).

---

### Why am I not seeing a confirmation of the ZMod installation?

The ZMod installation process no longer waits for a confirmation screen. After installation, the system will reboot automatically after 10 seconds and delete the firmware image file from the USB drive.

---

### Why can't I SSH into the printer after installing the mod?

Accessing the printer via SSH can be tricky after installing the Klipper mod because both mods use different SSH private keys. Your system may also block the connection due to a certificate mismatch.  

To resolve this issue, you need to remove the printer’s IP entry from the `known_hosts` file.  

**On Windows:**  
Remove the entry using Regedit (for PuTTY):  
`HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\SshHostKeys`.

**On Linux/macOS:**  
Edit the file located at `~/.ssh/known_hosts` and delete the line corresponding to your printer's IP.

Once removed, you should be able to reconnect via SSH. Forge-X (and ZMod) use the default credentials: `root/root`.

---

### How do I adjust the camera settings?

To adjust camera parameters like brightness or contrast, edit the `camera.conf` file.  
Alternatively, you can use the web control panel at:  
`http://printer_IP:8080/control.htm`

**Note:** Changes made in the web control panel will not be saved automatically. You must manually transfer adjustments into the corresponding `E_<parameter>` properties in `camera.conf`.

---

### I adjusted the camera settings, but they are not applied after a reboot.

Some camera settings are not applied during boot-up. Instead, they are applied later—typically when a print starts.  

To apply the changes manually at any time, use the macro:  
`CAMERA_RELOAD`

---

### What changes are needed to the G-code start and end commands when migrating from the old Klipper mod?

If you plan to use the stock screen, update the G-code start commands as outlined in the documentation (`/docs/SLICING.md`):

```gcode
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single]
M190 S[bed_temperature_initial_layer_single]
M104 S[nozzle_temperature_initial_layer]
```

**If you are using the Feather screen, no changes are required.**

---

### Why am I getting a "weight exceeded" error?

This safety feature prevents damage to the printer’s bed due to nozzle impact. By default, the weight limit is set to **1.2 kg**, but this can be adjusted using the `weight_check_max` parameter.

For more details, refer to the [Printing page](https://github.com/DrA1ex/ff5m/blob/main/docs/PRINTING.md) and the [Configuration page](https://github.com/DrA1ex/ff5m/blob/main/docs/CONFIGURATION.md).

**Possible causes of this error include:**  
- **Weight cell calibration issues**: If you manually leveled the bed, it might require recalibration.  
- **Hardware problems**: Printer-related hardware issues may also cause this error.  

**To resolve the issue temporarily:**  
You can either increase the threshold or disable the weight check feature using these commands:

```bash
# Increase threshold
SET_MOD_PARAM PARAM="weight_check_max" VALUE=1800

# Disable the feature
SET_MOD_PARAM PARAM="weight_check" VALUE=0
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

### My printer is stuck on the Stock initialization screen. How can I fix it?

This issue is likely caused by a bug in the newer Flashforge firmware (version `3.1.*`), where the firmware freezes if it fails to connect to a network during initialization.  

For now, reboot the printer by powering it off and back on. This problem is flickering — most of the time the firmware works fine, but occasionally it gets stuck.  

To avoid this issue, you can downgrade the stock firmware to version `2.7.*`, as this bug seems to occur only in version `3.1.*`. Alternatively, switching to the Feather screen eliminates this issue entirely because the Feather screen operates independently and does not rely on the problematic firmware.

---

### My printer is stuck on the screen with a black-and-white Flashforge logo. How can I fix it?

If you encounter this issue, something may be preventing your printer from booting at all.  
This is not a mod-related issue, as the mod only loads after the printer begins booting and displays its own splash screen.

The problem could be hardware- or software-related. Contact FlashForge support, but do not mention any mods you may have installed, as doing so will likely void your warranty.

You can try flashing the factory firmware image to resolve this. Refer to this [instruction guide](https://github.com/DrA1ex/ff5m/blob/main/docs/UNINSTALL.md#flashing-factory-firmware).

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

