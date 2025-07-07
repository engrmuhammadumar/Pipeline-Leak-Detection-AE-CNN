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
    f_center = freq(k);
    N = length(filtered_signal_downsampled); % Signal length
    t = 1:N; % Time indices for the signal
    gauss_win = exp(-((t - N / 2).^2) / (2 * (f_center / 10)^2)); % Gaussian window
    gauss_win = gauss_win(:); % Ensure it's a column vector

    % Apply the Gaussian window element-wise and compute the inverse FFT
    transformed_freq = ifft(signal_fft .* gauss_win, 'symmetric');
    ST(k, :) = abs(transformed_freq); % Store the absolute value
end

% Normalize the scalogram
ST_normalized = ST / max(ST(:)); % Scale to [0, 1]

% Enhance contrast using adaptive histogram equalization
ST_enhanced = adapthisteq(mat2gray(ST_normalized));

% Plot the enhanced Stockwell Transform scalogram
figure;
imagesc(time, freq, ST_enhanced);
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colormap('jet');
colorbar;
title('Enhanced Stockwell Transform Scalogram');
saveas(gcf, fullfile(main_path, 'Enhanced_Stockwell_Scalogram.png'));

% Apply Sobel edge detection
edges = edge(ST_enhanced, 'sobel');

% Plot the edges
figure;
imshow(edges);
title('Sobel Edge Detection on Enhanced Stockwell Scalogram');

% Save the edge-detected image
sobel_image_path = fullfile(main_path, 'Enhanced_Stockwell_Sobel_Edges.png');
imwrite(edges, sobel_image_path);

disp('Enhanced Sobel edge detection image saved successfully.');
