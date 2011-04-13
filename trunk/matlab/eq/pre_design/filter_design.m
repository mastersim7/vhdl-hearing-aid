% Title: filter_design.m
% Author: Mathias Lundell
% Date: 2011-04-12
% Description:
% File which generates coefficients for 8 filters of different order.
clc;clear;
% Sampling frequency
fs = 22.3e3;

% Nyquist frequency
Nyquist = fs/2;

% Define order for all filters:
filter_order = [201 201 201 201 151 61 31 21];

% Define weights
filter_weight = [1 1 1 1 1.3 1 1 1];

% Cut-off frequencies
fc = 1e4*1./[2^7, 2^6, 2^5, 2^4, 2^3, 2^2, 2^1, 0.9];

% Normalized cut-off frequencies
fc_norm = fc/Nyquist;

% Generate coefficients
win = kaiser(filter_order(1)+1);
b{1} = fir1(filter_order(1), fc_norm(1), 'low', win);
for i = 2:8
    win = kaiser(filter_order(i)+1);
    b{i} = iir1(filter_order(i), [fc_norm(i-1) fc_norm(i)], 'bandpass', win);
end;

% Weigh coefficients
for i = 1:8
    b{i} = b{i}./filter_weight(i);
end;

% Calculate frequency response
n = 1024; % Number of points to use
[h1 w] = freqz(b{1}, 1, n);
h2 = freqz(b{2}, 1, n);
h3 = freqz(b{3}, 1, n);
h4 = freqz(b{4}, 1, n);
h5 = freqz(b{5}, 1, n);
h6 = freqz(b{6}, 1, n);
h7 = freqz(b{7}, 1, n);
h8 = freqz(b{8}, 1, n);

abs_h = [abs(h1) abs(h2) abs(h3) abs(h4) abs(h5) abs(h6) abs(h7) abs(h8)]';
h_sum = sum(abs_h);

dB = @(x) 20*log10(abs(x));

% Plot frequency response
f = w*Nyquist/pi;
plot(f, dB(h1), f, dB(h2), f, dB(h3), f, dB(h4), ...
    f, dB(h5), f, dB(h6), f, dB(h7), f, dB(h8), f, dB(h_sum));
axis([0 10e3 -4 8]);
hold on;