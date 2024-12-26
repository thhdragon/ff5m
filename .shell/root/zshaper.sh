#!/bin/sh

echo "Подготовка изображения оси X. Ждите"
sed -i 's/psd_x/psd_Y/' /opt/config/mod_data/calibration_data_x*.csv
sed -i 's/psd_y/psd_x/' /opt/config/mod_data/calibration_data_x*.csv
sed -i 's/psd_Y/psd_y/' /opt/config/mod_data/calibration_data_x*.csv
python3 /opt/config/mod/.shell/root/zshaper/calibrate_shaper.py /opt/config/mod_data/calibration_data_x*.csv -o /opt/config/mod_data/calibration_data_x.png
echo "Подготовка изображения оси Y. Ждите"
sed -i 's/psd_x/psd_Y/' /opt/config/mod_data/calibration_data_y*.csv
sed -i 's/psd_y/psd_x/' /opt/config/mod_data/calibration_data_y*.csv
sed -i 's/psd_Y/psd_y/' /opt/config/mod_data/calibration_data_y*.csv
python3 /opt/config/mod/.shell/root/zshaper/calibrate_shaper.py /opt/config/mod_data/calibration_data_y*.csv -o /opt/config/mod_data/calibration_data_y.png
