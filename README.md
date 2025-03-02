<p align="center">
<img width="400" src="https://github.com/user-attachments/assets/c7ff5d09-3786-4b69-b8d5-1f254c809de7" />
<img width="400" src="https://github.com/user-attachments/assets/6f3b9343-d3d1-4f0e-b4cf-9ac1041502b2" />
</p>

# Flashforge Adventurer 5M (Pro) Firmware Mod

This is an _unofficial_ mod to run Moonraker, Klipper (with essential patches), Mainsail, and Fluidd on the Flashforge AD5M (Pro) 3D printers.
The mod is based on ZMod, which itself is derived from Klipper-mod.

> [!CAUTION]
> *If you choose to install this mod on your AD5M (Pro), be aware that you risk voiding your warranty or damaging your printer.*
> *After installation or uninstallation, ensure that you check all printer parameters and perform a full recalibration. Failing to do so may result in damage to your printer.*
> *Proceed at your own risk!*

## Features
- **Stock** Screen with option to disable it completely and switch to feather screen version to reduce resource consumption
- **Klipper** with many patches/fixes/plugins specially adapted for AD5M
- **Moonraker**
- **Fluidd** & **Mainsail**
- **OTA** updates
- **Root** access (with zsh/.oh-my-zsh)
- **Buzzer** with ability to play monotonic melodies (midi / notes)
- Patched **mjpg-streamer** with dramatically reduced memory usage
- **Timelapse** support via [Moonraker Telegram bot](https://github.com/nlef/moonraker-telegram-bot) installed on external host
- Adaptive bed meshing with **KAMP**.
- Built-in **MD5** checks for gcode files.
- **Backup** and **Restore** mechanizm for printer's configuration
- Fix for the **E00017** error.
- **Failsafe** mechanism to prevent nozzle collisions.
- Better **Clear Nozzle** algorithm.
- Enhanced **Shaper Calibration** with automatic plot generation.
- Easy **Bed Level Screw Tuning**.
- Customized dedicated Linux environment based on **Buildroot**
- **Entware** package manager for additional software installation
- **Dual boot** with stock Flashforge software


## Why This Mod Was Developed
This mod was created to address several critical limitations and challenges faced by users of the Flashforge AD5M (Pro) 3D printer. Here are the key reasons behind its development:

**Instability and Resource Issues in Existing Klipper Mods:**
The previous Klipper mod for the AD5M has stopped development and is no really stable. It consumes excessive RAM, leading to issues such as "Timer too close" errors and other performance problems. And some of typical AD5M issues not fixed at all. This mod aims to resolve these issues by optimizing resource usage and ensuring a stable, reliable experience.

**Closed and Inflexible Development in ZMOD:**
While ZMOD introduced significant improvements, it is not user-friendly for further enhancements or fixes. Its closed nature and unique development approach make it difficult to modify without deep knowledge of the entire system. This mod focuses on rewriting the foundation to provide advanced users with more control, making it easier to apply patches, additions, and customizations.

**Lack of Essential Functionality in Stock Firmware:**
The stock firmware lacks many essential features that modern 3D printing enthusiasts expect. For example:
The camera functionality is poorly optimized, consuming excessive RAM and delivering subpar performance.
Users are unable to perform standard tasks that Klipper users typically rely on, such as advanced calibration, macros, and real-time monitoring.
This mod addresses these shortcomings by integrating modern tools and features.

**Outdated Klipper with Unresolved Bugs:**
The existing Klipper implementation for the AD5M is outdated and plagued with bugs. This mod focuses on fixing these long-standing issues, modifying Klipper plugins, and enhancing core functionality to better suit the specific requirements of the AD5M (Pro) printer. The goal is to provide a stable, feature-rich platform tailored to this printer's unique hardware and user needs.

### The Vision Behind This Mod

This mod is designed to empower users by providing a stable, customizable, and feature-rich alternative to the stock firmware and existing mods. It aims to:
- Offer a reliable foundation for advanced users to build upon.
- Fix long-standing bugs and optimize performance for the AD5M (Pro).
- Introduce modern features and tools that enhance the 3D printing experience.
- Ensure flexibility and openness for future improvements and community contributions.

By addressing these challenges, this mod strives to unlock the full potential of the Flashforge AD5M (Pro) and provide users with a seamless, powerful, and customizable 3D printing platform.

## Documentation
- [Installation](docs/INSTALL.md)
- [Configuration](docs/CONFIGURATION.md)
- [Slicing](docs/SLICING.md)
- [Printing](docs/PRINTING.md)
- [Alternative Screen](docs/SCREEN.md)
- [Camera](docs/CAMERA.md)
- [Telegram Bot and Timelapse](docs/TELEGRAM.md)
- [Dual boot](docs/DUAL_BOOT.md)
- [Uninstall](docs/UNINSTALL.md)
- [Recovery guide](docs/RECOVERY.md)

## Credits

Thanks [Klipper Mod](https://github.com/xblax/flashforge_ad5m_klipper_mod) developers for their great work.

Thanks to the Klipper and Moonraker communities for their ongoing development.

Special thanks to the Russian FlashForge Adventurer 5M Telegram Community: [@FF_5M_5M_Pro](https://t.me/FF_5M_5M_Pro)

This mod is based on ZMod by [ghzserg](https://github.com/ghzserg).

Thanks for the great open-source fonts:
- [Roboto Font](https://fonts.google.com/specimen/Roboto)
- [JetBrains Mono Font](https://www.jetbrains.com/lp/mono)
- [Typicons Icons Font](https://www.s-ings.com/typicons/)
