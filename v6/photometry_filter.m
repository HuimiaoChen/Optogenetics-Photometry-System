% Design a 6th-order lowpass Butterworth filter with a cutoff frequency of
% 300 Hz, which, for data sampled at 1000 Hz, corresponds to  rad/sample.
% Plot its magnitude and phase responses. Use it to filter a 1000-sample
% random signal.
% fc = 300;
% fs = 1000;

od = 6; % filter order
fc = 60; % cutoff freq
fs = 1000; % sample freq

[b,a] = butter(6, fc/(fs/2), "low");

photo = scanData_matrix(:,1)-scanData_matrix(:,2);
smoothed = filter(b, a, photo);

% Plot the original and smoothed curves
figure;
plot(photo(end-200*1000:end-190*1000), 'b-', 'LineWidth', 1.5, 'DisplayName', 'Original');
hold on;
plot(smoothed(end-200*1000:end-190*1000), 'r-', 'LineWidth', 1.5, 'DisplayName', 'Smoothed');
legend('Location', 'best');
title('Spiky Curve Low-Pass Filtering');
xlabel('Data Point');
ylabel('Value');
grid on;

%% moving average method

% % Define the window size for the moving average filter
% windowSize = 5; % Adjust this based on your data and desired smoothing level
% 
% % Apply the moving average filter
% smoothedCurve = smooth(photo(10000:20000), windowSize);
% 
% % Plot the original and smoothed curves
% figure;
% plot(photo(10000:20000), 'b-', 'LineWidth', 1.5, 'DisplayName', 'Original');
% hold on;
% plot(smoothedCurve, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Smoothed');
% legend('Location', 'best');
% title('Spiky Curve Smoothing');
% xlabel('Data Point');
% ylabel('Value');
% grid on;