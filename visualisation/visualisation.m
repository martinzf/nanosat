clear; clc;

% Connection information
ARDUINO_ADDRESS = 'B69A456D9D19';
SERVICE_UUID    = '180C';
ROLL_UUID       = '2A56';
PITCH_UUID      = '2A57';
YAW_UUID        = '2A58';

% Establish connection with BLE device & characteristics
disp(['Connecting to BLE periferal ', ARDUINO_ADDRESS, '...']);
ble_device = ble(ARDUINO_ADDRESS);
disp('Accessing BLE characteristics...');
ble_roll   = characteristic(ble_device, SERVICE_UUID, ROLL_UUID);
ble_pitch  = characteristic(ble_device, SERVICE_UUID, PITCH_UUID);
ble_yaw    = characteristic(ble_device, SERVICE_UUID, YAW_UUID);

% Subscribe to BLE notifications
disp('Subscribing to BLE notifications...');
subscribe(ble_roll);
subscribe(ble_pitch);
subscribe(ble_yaw);

% Create figure
fig = figure('CloseRequestFcn', @myclosereq);
global running
running = true;

% Set up plot
roll  = mydecode(read(ble_roll));
pitch = mydecode(read(ble_pitch));
yaw   = mydecode(read(ble_yaw));
q = quaternion([- yaw, pitch, roll], 'eulerd', 'ZYX', 'frame');
patch = poseplot(q);

% Animation loop
while running
    roll  = mydecode(read(ble_roll));
    pitch = mydecode(read(ble_pitch));
    yaw   = mydecode(read(ble_yaw));
    q = quaternion([- yaw, pitch, roll], 'eulerd', 'ZYX', 'frame');
    set(patch, Orientation=q); 
    drawnow
    pause(.05)
end

% Unsubscribe from BLE notifications
disp('Unsubscribing from BLE notifications...');
subscribe(ble_roll);
subscribe(ble_pitch);
subscribe(ble_yaw);

% Terminate BLE connection
disp('Ending BLE connection...');
clear ble_device
disp(['Disconnected from ', ARDUINO_ADDRESS]);

%% Helper functions

% Figure close request 
function myclosereq(src, event)
    global running
    running = false; % Exit animation loop
    delete(gcf)
end

function f = mydecode(b)
    b_strings = dec2bin(b, 8); % Convert decimal values to binary strings
    b_concat = reshape(b_strings.', 1, []); % Concatenate binary strings
    % Convert concatenated binary string to float
    f = typecast(uint8(bin2dec(reshape(b_concat, 8, []).')), 'single');
end