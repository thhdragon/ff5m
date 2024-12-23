#!/bin/sh

echo "Подготовка изображения оси X. Ждите"
python3 /opt/config/mod/.shell/root/zshaper/calibrate_shaper.py /opt/config/mod_data/calibration_data_x*.csv -o /opt/config/mod_data/calibration_data_x.png
echo "Подготовка изображения оси Y. Ждите"
python3 /opt/config/mod/.shell/root/zshaper/calibrate_shaper.py /opt/config/mod_data/calibration_data_y*.csv -o /opt/config/mod_data/calibration_data_y.png
