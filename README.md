# nanosat

### About

WIP: Academic nanosatellite prototype developed in MATLAB R2023a, Arduino 
2.3.2 and Freecad 0.21.2. The Arduino board being used is an Arduino Nano 
33 BLE Sense Rev2.

### Contents 

The project is currently structured as follows, with folders containing 
Arduino code to upload to the board and corresponding MATLAB scripts and
notebooks to read and write data to it over Bluetooth Low Energy (BLE).

```
nanosat
.
|-- 3dmodels
|-- attitude
|   |-- attitude.ino
|   |-- visualisation.m
|-- calibration
|   |-- calibration.ino
|   |-- calibration.m
|   |-- local_magfield_info.txt
|-- testbench
|   |-- testbench.ino
|   |-- tests.mlx
```