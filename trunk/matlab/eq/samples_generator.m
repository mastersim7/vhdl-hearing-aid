% Samples
samples_n = 12;    % number of bits in samples
samples_num = 80; % number of randomly generated samples
samples_int = 0; 
samples_frac = 0.0;
samples_bin = ''; 
samples_max = (2^(samples_n-1))-1;

% Generate array of samples:
for i = 1 : samples_num
    samples_int(i) = generate_random(samples_n, sign);
    samples_frac(i) = samples_int(i)/samples_max;
    samples_bin(i,:) = int2bin(samples_int(i), samples_n);
end

xlswrite('samples.xls', cellstr(samples_bin), 'Sheet1', 'A1');