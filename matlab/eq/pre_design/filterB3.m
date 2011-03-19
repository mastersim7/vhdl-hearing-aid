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

N    = 219;      % Order220


FcB11=	78 % First Cutoff Frequency
FcB12=	((1e4)/(2^7))% Second Cutoff Frequency
FcB2=   ((1e4)/(2^6))
FcB3=     ((1e4)/(2^5))
FcB4=     ((1e4)/(2^4))
FcB5=     ((1e4)/(2^3))
FcB6=     ((1e4)/(2^2))
FcB7=     ((1e4)/2)
FcB8=     ((1e4))




flag = 'scale';  % Sampling Flag


% Create the window vector for the design algorithm.
win = hamming(N+1);
%win = nuttallwin(N+1);

% Calculate the coefficients using the FIR1 function.
%b{9}=fir1(N, 78/(Fs/2), 'high', win, flag);
%b{9}  = (fir1(N, [FcB11 FcB8]/(Fs/2), 'bandpass', win, flag))./2^6;
b{1}=(fir1(N, (FcB11)/(Fs/2), 'low', win, flag))./2;
% tested a highpass b1  = fir1(N, 100/(Fs/2), 'high', win, flag);

Hd1 = dfilt.dffir(b{1});
b{2}  = (fir1(N, [FcB12+30 FcB2+40]/(Fs/2), 'bandpass', win, flag))
Hd2 = dfilt.dffir(b{2});
b{3}  = fir1(N, [FcB2+140 FcB3+100]/(Fs/2), 'bandpass', win, flag);
Hd3 = dfilt.dffir(b{3});
b{4}  = fir1(N, [FcB3+140 FcB4+50]/(Fs/2), 'bandpass', win, flag);
Hd4 = dfilt.dffir(b{4});
b{5}  = fir1(N, [FcB4+60 FcB5]/(Fs/2), 'bandpass', win, flag);
Hd5 = dfilt.dffir(b{5});
b{6}  = fir1(N, [FcB5 FcB6]/(Fs/2), 'bandpass', win, flag);
Hd6 = dfilt.dffir(b{6});
b{7}  = fir1(N, [FcB6 FcB7]/(Fs/2), 'bandpass', win, flag);
Hd7 = dfilt.dffir(b{7});
b{8}  = fir1(N, [FcB7 FcB8]/(Fs/2), 'bandpass', win, flag);
Hd8 = dfilt.dffir(b{8});
Hd9 = dfilt.dffir(b{9});

Hd(10) = dfilt.dffir (b{1}+b{2}+b{3}+b{4}+b{5}+b{6}+b{7}+b{8}+b{9}); %
%added up the filters here to see
    [H1 W1] = freqz(b{1},1);
    
    [H2 W2] = freqz(b{2},1);
    [H3 W3] = freqz(b{3},1);
    [H4 W4] = freqz(b{4},1);
    [H5 W5] = freqz(b{5},1);
    [H6 W6] = freqz(b{6},1);
    [H7 W7] = freqz(b{7},1);
    [H8 W8] = freqz(b{8},1);
   % [H9 W9] = freqz(b{9},1);
    [H9 W9] = freqz(b{1}+b{2}+b{3}+b{4}+b{5}+b{6}+b{7}+b{8}); %b2+b3+b4
    %added up the filters here to see hjow they look like in the bank
    
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
%plot(W9*Fs/2/pi, 20*log10(abs(H10)));

hold off

fvtool (Hd1,Hd2,Hd3,Hd4,Hd5,Hd6,Hd7,Hd8)%
