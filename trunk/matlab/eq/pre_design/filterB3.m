%function Hd=filterB3
%316-562 Returns a discrete-time filter object.
%Hd = 
%
% M-File generated by MATLAB(R) 7.9 and the Signal Processing Toolbox 6.12.
%
% Generated on: 20-Feb-2011 16:55:36
% 

% FIR Window Bandpass filter designed using the FIR1 function.

% All frequency values are in Hz.
Fs = 22300;  % Sampling Frequency

N    = 255;      % Order


FcB11=	1% First Cutoff Frequency
FcB12=	(1e4)/(2^7)% Second Cutoff Frequency
FcB2=   (1e4)/(2^6)
FcB3=   (1e4)/(2^5)
FcB4=   (1e4)/(2^4)
FcB5=   (1e4)/(2^3)
FcB6=   (1e4)/(2^2) 
FcB7=   (1e4)/2
FcB8=   (1e4)




flag = 'scale';  % Sampling Flag


% Create the window vector for the design algorithm.
win = hamming(N+1);

% Calculate the coefficients using the FIR1 function.
b1  = fir1(N, [FcB11 FcB12]/(Fs/2), 'bandpass', win, flag);
Hd1 = dfilt.dffir(b1);
b2  = fir1(N, [FcB12 FcB2]/(Fs/2), 'bandpass', win, flag);
Hd2 = dfilt.dffir(b2);
b3  = fir1(N, [FcB2 FcB3]/(Fs/2), 'bandpass', win, flag);
Hd3 = dfilt.dffir(b3);
b4  = fir1(N, [FcB3 FcB4]/(Fs/2), 'bandpass', win, flag);
Hd4 = dfilt.dffir(b4);
b5  = fir1(N, [FcB4 FcB5]/(Fs/2), 'bandpass', win, flag);
Hd5 = dfilt.dffir(b5);
b6  = fir1(N, [FcB5 FcB6]/(Fs/2), 'bandpass', win, flag);
Hd6 = dfilt.dffir(b6);
b7  = fir1(N, [FcB6 FcB7]/(Fs/2), 'bandpass', win, flag);
Hd7 = dfilt.dffir(b7);
b8  = fir1(N, [FcB7 FcB8]/(Fs/2), 'bandpass', win, flag);
Hd8 = dfilt.dffir(b8);
Hd9 = dfilt.dffir(b1+b2+b3+b4+b5+b6+b7+b8);
    [H1 W1] = freqz(b1,1);
    
    [H2 W2] = freqz(b2,1);
    [H3 W3] = freqz(b3,1);
    [H4 W4] = freqz(b4,1);
    [H5 W5] = freqz(b5,1);
    [H6 W6] = freqz(b6,1);
    [H7 W7] = freqz(b7,1);
    [H8 W8] = freqz(b8,1);
    
    [H9 W9] = freqz(b1+b2+b3+b4+b5+b6+b7+b8,1);
    
% [EOF]
plot(W1*Fs/2/pi, 20*log10(abs(H1)));
hold on 
plot(W2*Fs/2/pi, 20*log10(abs(H2)));
plot(W3*Fs/2/pi, 20*log10(abs(H3)));
plot(W4*Fs/2/pi, 20*log10(abs(H4)));
plot(W5*Fs/2/pi, 20*log10(abs(H5)));
plot(W6*Fs/2/pi, 20*log10(abs(H6)));
plot(W7*Fs/2/pi, 20*log10(abs(H7)));
plot(W8*Fs/2/pi, 20*log10(abs(H8)));
plot(W9*Fs/2/pi, 20*log10(abs(H9)));

fvtool (Hd1,Hd2,Hd3,Hd4,Hd5,Hd6,Hd7,Hd9)