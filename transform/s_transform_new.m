clc;
clear;
close all;

% Parameters
fs = 1e6; % Sampling frequency (1 MHz)
file_path = 'E:\Pipeline Dataset\2022 test data\dataset1\188seconds\channel1.dat'; % Path to your .dat file
main_path = 'D:\GeneratedImages'; % Folder to save the generated image

% Load the .dat file
fileID = fopen(file_path, 'r');
data = fread(fileID, 'double'); % Read the data (adjust 'double' if needed)
fclose(fileID);

% Verify the raw signal
figure;
plot(data);
%title('Signal');
xlabel('Time');
ylabel('Amplitude');
grid on;

% Preprocess the signal: Apply low-pass filtering (optional)
filtered_signal = lowpass(data, 4600, fs); % Remove noise above 4.6 kHz

% Downsample the signal to reduce memory usage
downsample_factor = 10; % Reduce data size by a factor of 10
fs_downsampled = fs / downsample_factor;
filtered_signal_downsampled = downsample(filtered_signal, downsample_factor);

% Update time vector
time = linspace(0, length(filtered_signal_downsampled) / fs_downsampled, length(filtered_signal_downsampled));

% Parameters for Stockwell Transform
freq_bins = 500; % Number of frequency bins
freq = linspace(0, fs_downsampled / 2, freq_bins); % Frequency bins
ST = zeros(freq_bins, length(filtered_signal_downsampled)); % Preallocate for the scalogram

% FFT of the full signal
signal_fft = fft(filtered_signal_downsampled);

% Process each frequency bin
for k = 1:freq_bins
    % Define the Gaussian window for the current frequency
    f_center = freq(k);
    N = length(filtered_signal_downsampled); % Signal length
    t = 1:N; % Time indices for the signal
    gauss_win = exp(-((t - N / 2).^2) / (2 * (f_center / 10)^2)); % Gaussian window
    gauss_win = gauss_win(:); % Ensure it's a column vector

    % Apply the Gaussian window element-wise and compute the inverse FFT
    transformed_freq = ifft(signal_fft .* gauss_win, 'symmetric');

    % Store the absolute value in the scalogram
    ST(k, :) = abs(transformed_freq);
end

% Plot the Stockwell Transform scalogram
figure;
imagesc(time, freq, abs(ST));
axis xy;
%title('');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colormap('jet');
colorbar;

% Save the scalogram
if ~exist(main_path, 'dir')
    mkdir(main_path);
end
saveas(gcf, fullfile(main_path, 'Fixed_Stockwell_Scalogram.png'));
disp('Stockwell Transform image saved successfully.');
