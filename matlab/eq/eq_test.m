% eq_test.m
% Alexey Sidelnikov, Mathias Lundell
% 2011-03-17

sign = 1;          % want signed bit vectors from 'generate_random()'

% Samples
samples_n = 12;    % number of bits in samples
samples_num = 220; % number of randomly generated samples
samples_int = 0; 
samples_frac = 0.0;
samples_bin = ''; 
samples_max = 2^(samples_n-1)-1;

% Summed pairs of samples
summed_samples_int = 0;
summed_samples_bin = '';
summed_samples_frac = 0.0;
summed_samples_n = 13; % Sum should be 13 bits (two samples added together)
summed_samples_max = 2^(summed_samples_n-1)-1;

% Coefficients
coeff_num = 110; % number of randomly generated coefficients
coeff_int = 0;
coeff_frac = 0.0;
coeff_bin = '';  
coeff_n = 24;    % Coefficients should be 24 bits
coeff_max = 2^(coeff_n-1)-1;

% Coefficients multiplied with summed pairs of samples
coeff_x_summed_samples_int = 0;
coeff_x_summed_samples_frac = 0.0;
coeff_x_summed_samples_bin = ''; 
coeff_x_summed_samples_n = 37; % Result should be 37 bits
coeff_x_summed_samples_max = 2^(coeff_x_summed_samples_n-1)-1;

% Output values
pre_output_n = 40;  % result of adding all the results of multiplications, should be 40 bits   
pre_output_int = 0; % Is the result of adding all the results of multiplication
pre_output_bin = '';
pre_output_max = 2^(pre_output_n-1)-1;

output_n = 12;      % pre_output, "cutted" in 12 bits is final output
output_int = 0;
output_bin = '';
output_max = 2^(output_n-1)-1;

% Generate array of samples:
for i = 1 : samples_num
    samples_int(i) = generate_random(samples_n, sign);
    samples_bin(i,:) = int2bin(samples_int(i), samples_n);
end

% Generate array of summed samples' pairs:
for i = 1 : (samples_num/2)
    summed_samples_int(i) = samples_int(i) + samples_int(samples_num-i);
    summed_samples_bin(i,:) = int2bin(summed_samples_int(i), summed_samples_n);
    summed_samples_frac(i) = summed_samples_int(i)/summed_samples_max;
end

% Generate array of coefficients:
for i = 1 : coeff_num
    coeff_int(i) = generate_random(coeff_n, sign);
    coeff_frac(i) = coeff_int(i)/coeff_max;
    coeff_bin(i,:) = int2bin(coeff_int(i), coeff_n);
end

% Generate array of multipications between summed samples and corresponding
% coefficients:
for i = 1 : coeff_num
    coeff_x_summed_samples_int(i) = summed_samples_int(i) * coeff_int(i);
    
    % it is necessary to multiply with 2. This is equal to a shift left:
    coeff_x_summed_samples_frac(i) = (coeff_x_summed_samples_int(i)/coeff_x_summed_samples_max)*2; 
    coeff_x_summed_samples_bin(i,:) = int2bin(coeff_x_summed_samples_int(i), coeff_x_summed_samples_n);
end

% Add all the results of multiplications together:
pre_output_int = sum(coeff_x_summed_samples_int);
pre_output_bin = int2bin(pre_output_int, pre_output_n);

% pre_output_frac = pre_output_int/coeff_x_summed_samples_max; 
% <- Maybe this is wrong? Changed below. /Alexey-13:35-110317
pre_output_frac = pre_output_int/pre_output_max;

% ! At this point we have the output from a single filter. I think we can test a filter
%   with this and then we have to decide to either keep the 37 bits until we have summed
%   the output from all eight filters. But let's say we cut the binary numbers to 12 bits and
%   evaluate that case (for the sake of it). 
%   /Mathias-08:30-110317

% Cut 'pre_output' in 12 bits and get the final output:

% Alexey's old variant:
% output_int = pre_output_int;
% for i = 1 : output_n
% output_bin(i) = pre_output_bin(i);
% end

steps_to_right_shift = pre_output_n-output_n;
output_int = floor(pre_output_int/(2^steps_to_right_shift));
output_bin = int2bin(output_int, output_n);

output_frac = output_int/output_max;

% Calculate output_int with new number of bits (12 bits)
%output_int = 0;
%for i = output_n:-1:1
%  if i =
%   output_int = output_int + 2^
%output_frac = 

% Writing coeffs, samples and outputs in files as binary numbers
% to use them in the VHDL testbench:

% Opening files for writing
fid_samples = fopen('samples.tv', 'w');
fid_coeff = fopen('coeff.tv', 'w');
fid_output = fopen('output.tv', 'w');
% Writing values in files
fprintf(fid_samples, '%c%c%c%c%c%c%c%c%c%c%c%c\n', samples_bin);
fprintf(fid_coeff, '%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c\n', coeff_bin)
fprintf(fid_output, '%s', output_bin)
% Closing files
fclose(fid_samples);
fclose(fid_coeff);
fclose(fid_output);

% COMMENTS:
%
% 2) I'm also not sure about 40 bits for 'pre_output'.
% 3) Do we need to export results to excel?
% /Alexey-04:30-110317