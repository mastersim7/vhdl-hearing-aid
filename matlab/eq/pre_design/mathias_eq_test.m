clc;
%% Bark edges
bard_edges = [0, 100, 200, 300, 400, 510, 630, 770, ...
              920, 1080, 1270, 1480, 1720, 2000, 2320, ... 
              2700, 3150, 3700, 4400, 5300, 6400, 7700, ...
              9500, 12000, 15500];
band_centers = [50, 150, 250, 350, 450, 570, 700, 840, ...
                1000, 1170, 1370, 1600, 1850, 2150, 2500, ...
                2900, 3400, 4000, 4800, 5800, 7000, 8500, ...
                10500, 13500];
            
%% Some filter values based on Bark scale 
fs = 20e3/2;
pb8 = 7700; % hp
sb8 = 6400;
pb7 = [4400 5300];
sb7 = [3700 6400];
pb6 = [2700 3150];
sb6 = [2320 3700];
pb5 = [1720 2000];
sb5 = [1480 2320];
pb4 = [1080 1270];
sb4 = [920 1480];
pb3 = [630 770];
sb3 = [510 920];
pb2 = [300 400];
sb2 = [200 510];
pb1 = 100; % lp
sb1 = 200;

%% Logarithmically spaced filter bands
b8 = [5e3 10e3];
b7 = b8/2;
b6 = b7/2;
b5 = b6/2;
b4 = b5/2;
b3 = b4/2;
b2 = b3/2;
b1 = b2/2;


%% Plot the filters...
n = 128;
a = [0 0 1 1];
f8 = [0 0.9*b8(1) b8]/fs;
b = firpm(n, f8, a);
[h8,w8] = freqz(b,1,1024);

a = [0 0 1 1 0 0];
f7 = [0 0.9*b7(1) b7 1.1*b7(2) fs]/fs;
b = firpm(n, f7, a);
[h7,w7] = freqz(b,1,1024);

f6 = [0 0.9*b6(1) b6 1.1*b6(2) fs]/fs;
b = firpm(n, f6, a);
[h6,w6] = freqz(b,1,1024);

f5 = [0 0.9*b5(1) b5 1.1*b5(2) fs]/fs;
b = firpm(n, f5, a);
[h5,w5] = freqz(b,1,1024);

f4 = [0 0.9*b4(1) b4 1.1*b4(2) fs]/fs;
b = firpm(n, f4, a);
[h4,w4] = freqz(b,1,1024);

f3 = [0 0.9*b3(1) b3 1.1*b3(2) fs]/fs;
b = firpm(n, f3, a);
[h3,w3] = freqz(b,1,1024);

f2 = [0 0.9*b2(1) b2 1.1*b2(2) fs]/fs;
b = firpm(n, f2, a);
[h2,w2] = freqz(b,1,1024);

f1 = [0 0.9*b1(1) b1 1.1*b1(2) fs]/fs;
b = firpm(n, f1, a);
[h1,w1] = freqz(b,1,1024);

plot(fs*w8/pi,20*log10(abs(h8)),...
    fs*w7/pi, 20*log10(abs(h7)), ...
    fs*w6/pi, 20*log10(abs(h6)), ...
    fs*w5/pi, 20*log10(abs(h5)), ...
    fs*w4/pi, 20*log10(abs(h4)), ...
    fs*w3/pi, 20*log10(abs(h3)), ...
    fs*w2/pi, 20*log10(abs(h2)), ...
    fs*w1/pi, 20*log10(abs(h1)));
legend('b8', 'b7', 'b6', 'b5', 'b4', 'b3', 'b2', 'b1')
xlim([0 10e3]);
%%