% Title: filter_design.m
% Author: Mathias Lundell
% Date: 2011-04-12
% Description:
% File which generates coefficients for 8 filters of different order.

% 2011-05-09
% Changed sampling frequency to 20kHz. Added option to write coefficients
% to file.

clc;clear;

% Write to file? 
% 1 = yes, 0 = no
write_to_file = 1;

% Sampling frequency
fs = 20e3;

% Number of bits for coefficients.
bits = 13;

% Nyquist frequency
Nyquist = fs/2;

% Define order for all filters:
%filter_order = [211 211 211 211 157 127 31 15];
%filter_order = [64 64 64 64 64 64 64 64];
filter_order = [199 199 199 199 199 199 199 199];

% Define weights
filter_weight = [1 1 1 1 1 1 1 1];

% Cut-off frequencies
fc = 1e4*1./[2^7, 2^6, 2^5, 2^4, 2^3, 2^2, 2^1, 1.0000001];

% Normalized cut-off frequencies
fc_norm = fc/Nyquist;

% Generate coefficients
win = kaiser(filter_order(1)+1);
b{1} = fir1(filter_order(1), fc_norm(1), 'low', win);
for i = 2:8
    win = kaiser(filter_order(i)+1);
    b{i} = fir1(filter_order(i), [fc_norm(i-1) fc_norm(i)], 'bandpass', win);
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

if write_to_file == 1
coeff_bin = '';
coeff_max = 2^(bits-1)-1;
for m=1:8
    for i=1:filter_order(m)+1
        y = b{m}(i) * coeff_max;
        y=round(y);
        l{m,i} = int2bin(y, bits);
    end;
end;

%Now let's write them to a text file 
fid=fopen('coeff.txt','wt');
fprintf(fid,'(');
for m=1:8
    fprintf(fid,'(');
    for i=1:filter_order(m)
        %fprintf(fid,'%s,',l{i,1:end})
        %fprintf(fid,'tc(%i,%i)<="%s";', m, i, l{m,i});
        fprintf(fid,'"%s",',l{m,i});
    end
    if m ~= 8
        fprintf(fid,'"%s"),\n',l{m,end});
    else
        fprintf(fid,'"%s"));',l{m,end});
    end
end
fclose(fid);
end;
