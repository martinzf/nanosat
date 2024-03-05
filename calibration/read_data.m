clear; clc;

PORT = 'COM5';
BAUDRATE = 9600;

device = serialport(PORT, BAUDRATE);
%[ax, ay, az, gx, gy, gz, mx, my, mz] = readline(device);