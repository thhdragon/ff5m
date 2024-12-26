#!/bin/sh

echo "Подготовка изображения оси X. Ждите"
sed 's/psd_x/psd_Y/' /opt/config/mod_data/calibration_data_x_*.csv | sed 's/psd_y/psd_x/' | sed 's/psd_Y/psd_y/' | awk -F ',' '{print $1","$3","$2","$4","$5","$6","$7","$8","$9","$10}' >/opt/config/mod_data/calibration_data_xfix.csv
python3 /opt/config/mod/.shell/root/zshaper/calibrate_shaper.py /opt/config/mod_data/calibration_data_xfix.csv -o /opt/config/mod_data/calibration_data_x.png
echo "Подготовка изображения оси Y. Ждите"
sed 's/psd_x/psd_Y/' /opt/config/mod_data/calibration_data_y_*.csv | sed 's/psd_y/psd_x/' | sed 's/psd_Y/psd_y/' | awk -F ',' '{print $1","$3","$2","$4","$5","$6","$7","$8","$9","$10}' >/opt/config/mod_data/calibration_data_yfix.csv
python3 /opt/config/mod/.shell/root/zshaper/calibrate_shaper.py /opt/config/mod_data/calibration_data_yfix.csv -o /opt/config/mod_data/calibration_data_y.png
