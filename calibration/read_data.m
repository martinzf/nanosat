clear; clc;

% Connection information
ARDUINO_ADDRESS = 'B69A456D9D19';
SERVICE_UUID = "180C";
A_UUID = ["2A56", "2A57", "2A58"];
G_UUID = ["2A59", "2A60", "2A61"];
M_UUID = ["2A62", "2A63", "2A64"];

% Establish connection with BLE device & characteristics
disp(['Connecting to BLE periferal ', ARDUINO_ADDRESS, '...'])
ble_device = ble(ARDUINO_ADDRESS);
disp('Accessing BLE characteristics...')
addchar = @(x) characteristic(ble_device, SERVICE_UUID, x);
ble_a = arrayfun(addchar, A_UUID);
ble_g = arrayfun(addchar, G_UUID);
ble_m = arrayfun(addchar, M_UUID);

% Subscribe to BLE notifications
disp('Subscribing to BLE notifications...')
arrayfun(@subscribe, ble_a)
arrayfun(@subscribe, ble_g)
arrayfun(@subscribe, ble_m)

%% Gyroscope calibration
disp('Lay sensor still on a flat surface')
input('Press enter to calibrate the gyroscope for 10s ', 's');
tic
g = [];
while toc < 10
    gi = arrayfun(@(x) mydecode(read(x)), ble_g);
    g = [g; gi];
    disp(gi)
end
g_offset = mean(g, 1);
disp('Gyroscope calibrated')

%% Magnetometer calibration
FIELD = 45.0521; % uT
disp('To calibrate magnetometer rotate IMU in every orientation possible')
input('Press enter to begin calibrating, close figure to stop', 's');
% Create figure
figure('CloseRequestFcn', @myclosereq)
global running
running = true;
plot = scatter3([], [], []);
xlim(2 * [- FIELD, FIELD])
ylim(2 * [- FIELD, FIELD])
zlim(2 * [- FIELD, FIELD])

m = [];
while running
    m = [m; arrayfun(@(x) mydecode(read(x)), ble_m)];
    plot.XData = m(:, 1);
    plot.YData = m(:, 2);
    plot.ZData = m(:, 3);
    drawnow
    pause(.05)
end

[Am, bm, magnorm]  = magcal(m);
[Am, bm] = [Am, bm] * FIELD / magnorm;
disp('Magnetometer calibrated')

%% Accelerometer calibration
AVERAGING = 30;
disp('To calibrate accelerometer, hold still in various rotated positions')

answer = input('Take a measurement? [Y/n]: ', 's');
while not(strcmpi(answer, 'y') || strcmpi(answer, 'n'))
     answer = input('Take a measurement? [Y/n]: ', 's');
end
while strcmpi(answer, 'y')
    ai = [0, 0, 0];
    for i = 1:AVERAGING
        ai = ai + arrayfun(@(x) mydecode(read(x)), ble_m);
    end
    ai = ai / AVERAGING;
    a = [a; ai];
    disp(ai)
    answer = input('Take a measurement? [Y/n]: ', 's');
    while not(strcmpi(answer, 'y') || strcmpi(answer, 'n'))
        answer = input('Take a measurement? [Y/n]: ', 's');
    end
end

[Aa, ba, accnorm]  = magcal(a);
[Aa, ba] = [Aa, ba] / accnorm;
disp('Accelerometer calibrated')

%% Showing results


%% Cleanup
% Unsubscribe from BLE notifications
disp('Unsubscribing from BLE notifications...')
arrayfun(@unsubscribe, ble_a)
arrayfun(@unsubscribe, ble_g)
arrayfun(@unsubscribe, ble_m)

% Terminate BLE connection
disp('Ending BLE connection...')
clear ble_device
disp(['Disconnected from ', ARDUINO_ADDRESS])

%% Helper functions
% Received binary to single precision float
function f = mydecode(b)
    b_strings = dec2bin(b, 8); % Convert decimal values to binary strings
    b_concat = reshape(b_strings.', 1, []); % Concatenate binary strings
    % Convert concatenated binary string to float
    f = typecast(uint8(bin2dec(reshape(b_concat, 8, []).')), 'single');
end

% Figure close request 
function myclosereq(src, event)
    global running
    running = false; % Exit animation loop
    delete(gcf)
end