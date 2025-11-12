%% Field II Simulation: Single Point Scatterer
% This script simulates ultrasound imaging of one point scatterer using Field II
% Make sure Field II is installed and added to MATLAB path

clear all;
close all;
clc;

%% Initialize Field II
field_init(-1);  % -1 suppresses output messages

%% Transducer Parameters
f0 = 5e6;              % Center frequency [Hz]
fs = 100e6;            % Sampling frequency [Hz]
c = 1540;              % Speed of sound [m/s]
lambda = c/f0;         % Wavelength [m]

% Transducer geometry
width = lambda/2;      % Element width
element_height = 5e-3; % Element height [m]
kerf = 0.05e-3;        % Gap between elements [m]
N_elements = 128;      % Number of elements
pitch = width + kerf;  % Element pitch

%% Define Excitation Pulse
excitation = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = excitation;

%% Create Transmit Aperture
Tx = xdc_linear_array(N_elements, width, element_height, kerf, 1, 1, [0 0 Inf]);
xdc_impulse(Tx, impulse_response);
xdc_excitation(Tx, excitation);

%% Create Receive Aperture
Rx = xdc_linear_array(N_elements, width, element_height, kerf, 1, 1, [0 0 Inf]);
xdc_impulse(Rx, impulse_response);

%% Define Single Point Scatterer
% Point position [x, y, z] in meters
point_x = 0;           % Lateral position [m] (0 = center)
point_y = 0;           % Elevation position [m]
point_z = 40e-3;       % Depth [m] (40 mm)

phantom_positions = [point_x, point_y, point_z];
phantom_amplitudes = 1;  % Reflectivity amplitude

fprintf('Point scatterer at: x=%.1fmm, y=%.1fmm, z=%.1fmm\n', ...
    point_x*1000, point_y*1000, point_z*1000);

%% Imaging Parameters
scan_lines = 128;      % Number of scan lines
z_start = 20e-3;       % Start depth [m]
z_end = 60e-3;         % End depth [m]

% Define lateral positions for each scan line
x_positions = linspace(-N_elements/2*pitch, N_elements/2*pitch, scan_lines);
focus_depth = 40e-3;   % Focal depth [m]

%% Perform Beamforming and Acquire RF Data
rf_data = zeros(4000, scan_lines);  % Preallocate RF data matrix

fprintf('Simulating %d scan lines...\n', scan_lines);

for i = 1:scan_lines
    % Set focus for transmit
    xdc_center_focus(Tx, [x_positions(i) 0 0]);
    xdc_focus(Tx, 0, [x_positions(i) 0 focus_depth]);
    
    % Set focus for receive (dynamic)
    xdc_center_focus(Rx, [x_positions(i) 0 0]);
    xdc_focus(Rx, 0, [x_positions(i) 0 focus_depth]);
    
    % Calculate response from single point
    [rf_line, t_start] = calc_scat(Tx, Rx, phantom_positions, phantom_amplitudes);
    
    % Store RF data
    rf_data(1:length(rf_line), i) = rf_line;
    
    if mod(i, 20) == 0
        fprintf('Completed %d/%d lines\n', i, scan_lines);
    end
end

%% Envelope Detection
env_data = abs(hilbert(rf_data));

%% Log Compression
dynamic_range = 60;  % dB
env_log = 20*log10(env_data + eps);
env_log = env_log - max(env_log(:));
env_log(env_log < -dynamic_range) = -dynamic_range;

%% Create Image Axes
time_vector = (0:size(rf_data,1)-1)/fs;
depth_vector = time_vector * c / 2 * 1000;  % Convert to mm
lateral_vector = x_positions * 1000;        % Convert to mm

%% Display Results
figure('Position', [100, 100, 1400, 500]);

% Raw RF data
subplot(1,4,1);
imagesc(lateral_vector, depth_vector, rf_data);
colormap(gray);
xlabel('Lateral Position [mm]');
ylabel('Depth [mm]');
title('RF Data');
axis image;
ylim([z_start*1000, z_end*1000]);
hold on;
plot(point_x*1000, point_z*1000, 'r+', 'MarkerSize', 15, 'LineWidth', 2);
legend('Point Target');

% Envelope detected
subplot(1,4,2);
imagesc(lateral_vector, depth_vector, env_data);
colormap(gray);
xlabel('Lateral Position [mm]');
ylabel('Depth [mm]');
title('Envelope Detected');
axis image;
ylim([z_start*1000, z_end*1000]);
hold on;
plot(point_x*1000, point_z*1000, 'r+', 'MarkerSize', 15, 'LineWidth', 2);

% Log compressed B-mode image
subplot(1,4,3);
imagesc(lateral_vector, depth_vector, env_log);
colormap(gray);
xlabel('Lateral Position [mm]');
ylabel('Depth [mm]');
title(sprintf('B-mode Image (%d dB)', dynamic_range));
colorbar;
caxis([-dynamic_range 0]);
axis image;
ylim([z_start*1000, z_end*1000]);
hold on;
plot(point_x*1000, point_z*1000, 'r+', 'MarkerSize', 15, 'LineWidth', 2);

% Point Spread Function (PSF) - Cross-sections
subplot(1,4,4);
% Find the point in the image
[~, depth_idx] = min(abs(depth_vector - point_z*1000));
[~, lateral_idx] = min(abs(lateral_vector - point_x*1000));

% Lateral profile
lateral_profile = env_log(depth_idx, :);
plot(lateral_vector, lateral_profile, 'b-', 'LineWidth', 2);
hold on;

% Axial profile (scaled for visualization)
axial_profile = env_log(:, lateral_idx);
plot(axial_profile*0.5, depth_vector, 'r-', 'LineWidth', 2);

xlabel('Lateral Position [mm] / Amplitude');
ylabel('Depth [mm]');
title('Point Spread Function');
legend('Lateral Profile', 'Axial Profile');
grid on;

%% Display Point Spread Function Width
% Calculate FWHM (Full Width at Half Maximum)
max_val = max(lateral_profile);
half_max = max_val - 3;  % -3dB point
indices = find(lateral_profile >= half_max);
if ~isempty(indices)
    fwhm_lateral = lateral_vector(indices(end)) - lateral_vector(indices(1));
    fprintf('\nLateral FWHM: %.2f mm\n', fwhm_lateral);
end

%% Close Field II
xdc_free(Tx);
xdc_free(Rx);
field_end;

fprintf('\nSimulation completed successfully!\n');
