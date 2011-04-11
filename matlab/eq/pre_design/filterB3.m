% 2011-04-11, Mathias Lundell, Alexey Sidelnikov
% Clean-up

% All frequency values are in Hz.
Fs = 22.3e3; % Sampling Frequency

N    = 39; % Filter order


FcB11= 1;       % First Cutoff Frequency
FcB12= 1e4/2^7; % Second Cutoff Frequency
FcB2 = 1e4/2^6;
FcB3 = 1e4/2^5;
FcB4 = 1e4/2^4;
FcB5 = 1e4/2^3;
FcB6 = 1e4/2^2;
FcB7 = 1e4/2;
FcB8 = 1e4;

% Calculate the coefficients using the FIR1 function.
Nyquist = Fs/2;
b{1} = fir1(N, FcB12/Nyquist, 'low')/5;
b{2} = fir1(N, [FcB12+30 FcB2+40]/Nyquist, 'bandpass')/4;
b{3} = fir1(N, [FcB2+140 FcB3+100]/Nyquist, 'bandpass')/4;
b{4} = fir1(N, [FcB3+140 FcB4+50]/Nyquist, 'bandpass')/4;
b{5} = fir1(N, [FcB4+60 FcB5]/Nyquist, 'bandpass')/2;
b{6} = fir1(N, [FcB5 FcB6]/Nyquist, 'bandpass')/1.1;
b{7} = fir1(N, [FcB6 FcB7]/Nyquist, 'bandpass');
b{8} = fir1(N, [FcB7 FcB8+1e3]/Nyquist, 'bandpass');


% These could be used with filter visualization tool
%{
Hd1 = dfilt.dffir(b{1});
Hd2 = dfilt.dffir(b{2});
Hd3 = dfilt.dffir(b{3});
Hd4 = dfilt.dffir(b{4});
Hd5 = dfilt.dffir(b{5});
Hd6 = dfilt.dffir(b{6});
Hd7 = dfilt.dffir(b{7});
Hd8 = dfilt.dffir(b{8});
%Hd9 = dfilt.dffir(b{9});
Hd(9) = dfilt.dffir (b{1}+b{2}+b{3}+b{4}+b{5}+b{6}+b{7}+b{8});%+b{9}); %
%}

% Added up the filters here to see
[H1 W1] = freqz(b{1});
[H2 W2] = freqz(b{2});
[H3 W3] = freqz(b{3});
[H4 W4] = freqz(b{4});
[H5 W5] = freqz(b{5});
[H6 W6] = freqz(b{6});
[H7 W7] = freqz(b{7});
[H8 W8] = freqz(b{8});

% Frequency response of all filters summed together
H9 = H1+H2+H3+H4+H5+H6+H7+H8;

% Lines for 0 dB and 10kHz
a = zeros(length(W1), 1);
c = -60:0.01:6;

% Before made to binary
dB = @(x) 20*log10(abs(x));

figure(1);
plot(W1*Nyquist/pi, dB(H1));
hold on;
plot(W1*Nyquist/pi, a, 'black');
plot(W2*Nyquist/pi, dB(H2));
plot(W3*Nyquist/pi, dB(H3));
plot(W4*Nyquist/pi, dB(H4));
plot(W5*Nyquist/pi, dB(H5));
plot(W6*Nyquist/pi, dB(H6));
plot(W7*Nyquist/pi, dB(H7));
plot(W8*Nyquist/pi, dB(H8));
plot(W9*Nyquist/pi, dB(H9), 'r');
plot(10e3, c, 'black');


% Frequency response for coefficients with a certain bit width
bits = 10;
b2 = cell2mat(b);
b3 = zeros(8, N+1);

for i = 1:8
    b3(i,:) = b2((i-1)*(N+1)+1:i*(N+1));
    for j = 1:N+1
        d = floor((2^(bits-1)-1)*(b3(i,j)));
        e = d/(2^(bits-1)-1);
        b3(i,j) = e;
    end;
end;

% When made binary
[H1 W1] = freqz(b3(1,:));
[H2 W2] = freqz(b3(2,:));
[H3 W3] = freqz(b3(3,:));
[H4 W4] = freqz(b3(4,:));
[H5 W5] = freqz(b3(5,:));
[H6 W6] = freqz(b3(6,:));
[H7 W7] = freqz(b3(7,:));
[H8 W8] = freqz(b3(8,:));

figure(2);
plot(W1*Nyquist/pi, dB(H1));
hold on;
plot(W1*Nyquist/pi, a, 'black');
plot(W2*Nyquist/pi, dB(H2));
plot(W3*Nyquist/pi, dB(H3));
plot(W4*Nyquist/pi, dB(H4));
plot(W5*Nyquist/pi, dB(H5));
plot(W6*Nyquist/pi, dB(H6));
plot(W7*Nyquist/pi, dB(H7));
plot(W8*Nyquist/pi, dB(H8));
plot(W9*Nyquist/pi, dB(H9), 'r');
plot(10e3, c, 'black');