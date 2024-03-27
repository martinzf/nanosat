# nanosat

### About

WIP: Academic cubesat (10x10x10 cm nanosatellite) prototype developed in 
MATLAB R2023a, Arduino 2.3.2 and Freecad 0.21.2. 

### Contents 

The project is currently segmented into folders containing Arduino code 
to upload to the controller, with corresponding MATLAB scripts and
notebooks to read and write data over Bluetooth Low Energy (BLE). 
Each code folder serves a different purpose, indicated by its name: 
attitude calculation, sensor calibration, and tests, respectively.
The `3dmodels` folder holds various part designs for the build &mdash; it 
contains the 3 different 3D file types used for this project. The file
`local_magfield_info.txt` shows the expected magnetic field at UCM,
calculated via the most recent World Magnetic Model on the NOAA's website.

```
nanosat
.
|-- 3dmodels
|   |-- 3mf
|   |-- FCStd
|   |-- step
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

### Hardware

The build currently uses the following components:

- [Arduino Nano 33 BLE Sense Rev2](https://store.arduino.cc/products/nano-33-ble-sense-rev2)

- 4 [Reaction wheels](https://es.aliexpress.com/item/1005005682355638.html?gatewayAdapt=glo2esp&spm=a2g0o.detail.1000023.14.f15aYEvVYEvV8o)

- [4 Relay module](https://es.aliexpress.com/item/1005006443560787.html?src=google&src=google&albch=shopping&acnt=439-079-4345&slnk=&plac=&mtctp=&albbt=Google_7_shopping&albagn=888888&isSmbAutoCall=false&needSmbHouyi=false&albcp=20330803848&albag=&trgt=&crea=es1005006443560787&netw=x&device=c&albpg=&albpd=es1005006443560787&gad_source=1&gclid=Cj0KCQjw-_mvBhDwARIsAA-Q0Q4jt1mqDZ-ns49du_rpRCJMhZ6nOClKpy0BLpKndKt_u7CcyzLZHzQaAkXVEALw_wcB&gclsrc=aw.ds&aff_fcid=966278ec26a04f0ba5fd8a4bbe7d0c42-1711192004105-07945-UneMJZVf&aff_fsk=UneMJZVf&aff_platform=aaf&sk=UneMJZVf&aff_trace_key=966278ec26a04f0ba5fd8a4bbe7d0c42-1711192004105-07945-UneMJZVf&terminal_id=f6a8778fa8284d399845e3fafceaea2d&afSmartRedirect=y)

### Angular momentum

Regardless of the reaction wheel configuration in the various alternative
3D designs, angular momentum about the origin of the cubesat $\mathbf{L}_O$
wrt angular momentum about the center of mass of a wheel $\mathbf{L}_{CM}$ 
is given by

$$
\mathbf{L}_O = M\mathbf{R}\times\mathbf{V} + \mathbf{L}_{CM}
$$

with $\mathbf{V}$ the velocity of the center of mass of the wheel wrt the 
origin, i.e. zero. Therefore, angular momentum (and torque) frame 
translations simply involve a rotation.