#!/bin/sh

cd /opt/config/mod_data/

data_path_x=$(ls -1 calibration_data_x_*.csv | sort | tail -n 1)
data_path_y=$(ls -1 calibration_data_y_*.csv | sort | tail -n 1)

sed 's/psd_x/psd_Y/' "$data_path_x" | sed 's/psd_y/psd_x/' | sed 's/psd_Y/psd_y/' | awk -F ',' '{print $1","$3","$2","$4","$5","$6","$7","$8","$9","$10}' >X
sed 's/psd_x/psd_Y/' "$data_path_y" | sed 's/psd_y/psd_x/' | sed 's/psd_Y/psd_y/' | awk -F ',' '{print $1","$3","$2","$4","$5","$6","$7","$8","$9","$10}' >Y

ID=$(date +"%Y%m%d_%H%M%S")

echo "Подготовка изображения оси X. Ждите"
python3 /opt/config/mod/.shell/root/zshaper/calibrate_shaper.py X -s 1.0 -o "calibration_data_${ID}_X.png"

echo "Подготовка изображения оси Y. Ждите"
python3 /opt/config/mod/.shell/root/zshaper/calibrate_shaper.py Y -s 1.0 -o "calibration_data_${ID}_Y.png"

rm -f X Y
