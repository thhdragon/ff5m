## Camera Configuration Documentation
### Purpose of Alternative Camera Configuration

The stock camera implementation on the Flashforge AD5M (Pro) consumes significant system resources, particularly RAM. Given the printer's limited 128MiB of RAM, this can lead to performance degradation during operation. To address this, the mod provides an optimized camera implementation with reduced RAM usage, achieved through specific patches to `mjpg_streamer`.

While the stock camera remains available, the mod's camera is optimized for minimal resource consumption, making it the preferred choice for stable printing.
**Note:** If you choose to use the alternative display implementation (e.g., Feather Screen), the stock camera will not be available, as the stock firmware is completely disabled in this mode. In such cases, the mod's camera is the only option.

If you still want to use stock camera functionality, skip steps up to Step 4.

### Configuring the Mod's Camera

#### Step 1: Modify Camera Configuration
The camera settings are defined in the `camera.conf file`, located in Fluidd under _Configuration -> mod_data -> camera.conf_. Below is the default configuration:

```cfg
# Resolution width
WIDTH=640

# Resolution height
HEIGHT=480

# Frame per second
FPS=15

# Video device: 'auto' or video<N> (like video0)
VIDEO=auto

# Image post-processing settings.
# You can play with settings and choice the best for you in page:
# http://printer_ip:8080/control.htm

E_SHARPNESS=255
E_BRIGHTNESS=0
E_CONTRAST=255
E_GAMMA=10
E_GAIN=1
```

You can adjust these parameters to suit your needs. For example, you might want set better resolution or FPS.
But be carefull since, check actual camera ram usage after that, using `MEM` macros in Fluidd's console.

#### Step 2: Disable Stock Camera
To ensure the mod's camera is used, you need to disable the stock camera functionality. Here’s how:

1. Go to the printer's on-screen settings.
2. Disable both camera photo and camera video.

This step is crucial to avoid conflicts between the stock and mod camera implementations.

#### Step 3: Enable Mod's Camera
Once the stock camera is disabled, enable the mod's camera by running the following command in the console:

```
SET_MOD_PARAM PARAM="camera" VALUE=1
```

This command activates the mod's camera implementation.

#### Step 4: Configure Fluidd Camera Settings
Next, configure the camera settings in Fluidd. Here’s how:

Go to **Settings -> Camera** in Fluidd.

Use the **Example** configuration as a template. This will help you set up the correct settings.

You need to set the following URLs:

- Snapshot URL: http://printer_ip:8080/?action=snapshot
- Stream URL: http://printer_ip:8080/?action=stream

Replace printer_ip with the actual IP address of your printer. If you’re unsure about the IP, you can find it in the printer’s network settings.

#### Step 5: Reload Fluidd
After completing the configuration, reload the Fluidd page. The camera should now be operational, and you should be able to view the stream and take snapshots.

#### Notes for Mainsail Users
If you’re using Mainsail, the configuration process is nearly identical to Fluidd. Simply follow the steps above, and you’ll be good to go. If you run into any issues, double-check the URLs and ensure the stock camera is disabled.

### Using the Stock Camera

If you prefer to use the stock camera functionality, you can skip Steps 1–3 and start directly with Step 4. Configure the camera settings in Fluidd or Mainsail as described, and ensure the stock camera is enabled in the printer's on-screen settings. However, be aware that the stock camera consumes significantly more resources, which may impact overall printer performance and could lead to print failures, such as unexpected print stoppages. You have been warned. Proceed at your own risk.
