# Calibration Guide for Flashforge Adventurer 5M (Pro) with Forge-X Firmware

This concise guide provides instructions for calibrating the axes, extruder, bed mesh, input shaper, and PID settings of your Flashforge Adventurer 5M or 5M Pro running the Forge-X firmware mod. For advanced calibration, use the Calilantern model.

## Disclaimer
This AI-generated guide is based on Forge-X documentation and general 3D printing practices. Verify settings with official Forge-X resources for your setup.

## Prerequisites
- **Firmware**: Forge-X v2.7.5+ (FF5M/FF5MPro) or v1.0.2/v1.0.8 (AD5X).
- **Belt Tension**: Ensure belts are tensioned (check YouTube/Flashforge guides).
- **Klipper Tuning**: Enable with `SET_MOD PARAM=tune_klipper VALUE=1`.
- **Config Tuning**: Enable with `SET_MOD PARAM=tune_config VALUE=1`.
- **Tools**: Caliper, Fluidd/Mainsail access.

## Configuration Overrides
Edit `user.cfg` via Fluidd/Mainsail (port 80) or manually. Backup config using Forge-X Backup and Restore before changes.

**Notice**: For STOCK screen users, use `NEW_SAVE_CONFIG` instead of `SAVE_CONFIG` or `RESTART` to save changes.

**Note**: Axis/extruder changes invalidate bed mesh. Run `AUTO_FULL_BED_LEVEL` after adjustments.

---

## Axis Calibration Models (Slicer)
1. **X/Y Calibration**:
   - In slicer (e.g., PrusaSlicer/OrcaSlicer), create a 200x200x0.2 mm flat square (1-2 layers).
   - Export G-code, print via Fluidd/Mainsail.
2. **Z Calibration**:
   - In Slicer, cylinder a 20x20x200 mm hollow rectangle (no infill, no top layers, 1 wall).
   - Export G-code and print via Fluidd/Mainsail.

### Axis Calibration Steps
1. **Measure**:
   - X/Y: Measure printed square (e.g., 201x201 mm).
   - Z: Measure height (e.g., 199 mm).
2. **Calculate Rotation Distance**:
   - Get current `rotation_distance` from `printer.cfg`/`user.cfg`.
   - Formula: `new_distance = current_distance * (expected_size / actual_size)`
     - E.g., X/Y: `40 * (200 / 201) ≈ 39.801`, Z: `8 * (200 / 199) ≈ 8.040`
3. **Update**:
   - Add to `user.cfg`:
     ```
     [stepper_x]
     rotation_distance: 39.801
     [stepper_y]
     rotation_distance: 39.801
     [stepper_z]
     rotation_distance: 8.040
     ```
   - Run `NEW_SAVE_CONFIG` (or `SAVE_CONFIG` for non-STOCK screens).

### Skew Distortion
- Use Calilantern model for skew. Print via Fluidd/Mainsail, follow instructions.
- Apply `SKEW_PROFILE` in `user.cfg`, run `NEW_SAVE_CONFIG`.

---

## Extruder Calibration
1. **Extrude Filament**:
   - Heat nozzle:
     ```
     M104 S220; Set nozzle to 220°C (adjust for filament)
     ```
   - Extrude 100 mm:
     ```
     G1 E100 F100
     ```
   - Mark 100 mm filament, measure actual extrusion (e.g., 98 mm).
2. **Calculate**:
   - Get current `rotation_distance` (e.g., `7.5`).
   - Formula: `new_distance = current_distance * (expected / actual)`
     - E.g., `7.5 * (100 / 98) ≈ 7.65`
3. **Update**:
   - Add to `user.cfg`:
     ```
     [extruder]
     rotation_distance: 7.65
     ```
   - Run `NEW_SAVE_CONFIG`.
4. **Note**: `tuning.cfg` has a near-accurate baseline.

---

## Bed Mesh Calibration
1. **Run**:
   ```
   AUTO_FULL_BED_LEVEL EXTRUDER_TEMP=220 BED_TEMP=60 PROFILE=auto
   ```
   - Adjust `EXTRUDER_TEMP` (e.g., 220°C for PLA), `BED_TEMP` (e.g., 60°C).
2. **Save**:
   ```
   NEW_SAVE_CONFIG
   ```
3. **Verify**: Print a 100x100 mm single-layer square.

---

## Bed Leveling Screws
1. **Run**:
   ```
   BED_LEVEL_SCREWS_TUNE EXTRUDER_TEMP=130 BED_TEMP=60
   ```
   - Adjust screws per instructions.
2. **Recalibrate Mesh**: Run `AUTO_FULL_BED_LEVEL`.
3. **Save**: `NEW_SAVE_CONFIG`.

---

## Input Shaper Calibration
1. **Run**:
   ```
   ZSHAPER
   ```
   - Plots generated in Fluidd/Mainsail.
2. **Save**:
   ```
   NEW_SAVE_CONFIG
   ```
3. **Verify**: Print Calilantern/ringing test model.

---

## PID Calibration
1. **Hotend**:
   ```
   PID_TUNE_EXTRUDER TEMPERATURE=220
   ```
   - Adjust `TEMPERATURE` (e.g., 220°C for PLA).
2. **Bed**:
   ```
   PID_TUNE_BED TEMPERATURE=60
   ```
   - Adjust `TEMPERATURE` (e.g., 60°C for PLA).
3. **Save**: `NEW_SAVE_CONFIG`.
4. **Verify**: Check temperature stability in Fluidd/Mainsail.

---

## Post-Calibration
1. **Verify**: Print Calilantern/50x50x50 mm cube.
2. **Recalibrate Mesh**: Run `AUTO_FULL_BED_LEVEL` after changes.
3. **Backup**: Use Forge-X Backup and Restore.
4. **Maintenance**: Recheck belt tension periodically.
