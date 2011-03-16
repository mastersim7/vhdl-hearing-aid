% generate_testvectors.m
% Mathias Lundell
% 2011-03-10
% Generates a specific number of test vectors. For Saves them to arrays. At the
% moment an addition with is performed.
clc;

num = 1000; % number of test vectors
sign = 1; % want signed bit vectors

sample_int = 0; 
sample_frac = 0.0;
sample_bin = ''; 
sample_n = 13; % Sample should be 13 bits (two samples added together)
sample_max = 2^(sample_n-1)-1;

coeff_int = 0;
coeff_frac = 0.0;
coeff_bin = '';  
coeff_n = 24; % Coefficients should be 24 bits
coeff_max = 2^(coeff_n-1)-1;

y_int = 0;
y_frac = 0.0;
ybin = ''; 
y_n = 37; % Result should be 37 bits
y_max = 2^(y_n-1)-1;

for i = 1:num
    % Generate a pair of test vectors
    sample_int(i) = generate_random(sample_n, sign);
    sample_frac(i) = sample_int(i)/sample_max;
    sample_bin(i,:) = int2bin(sample_int(i), sample_n);
    
    coeff_int(i) = generate_random(coeff_n, sign);
    coeff_frac(i) = coeff_int(i)/coeff_max;
    coeff_bin(i,:) = int2bin(coeff_int(i), coeff_n);
    
    % Generate the corresponding output
    y_int(i) = sample_int(i) * coeff_int(i);
    
    % when generating the result it is necessary to multiply with 2
    % this is equal to a shift left
    y_frac(i) = (y_int(i)/y_max)*2; 
    y_bin(i,:) = int2bin(y_int(i), y_n);
end


% Save values to excel file
text = {'Sample fraction', 'Coeff fraction', 'Y fraction', ...
    'Test fraction', 'Sample integer', 'Coeff integer', ...
    'Y integer', 'Test integer', '', 'Sample binary', 'Coeff binary', 'Y binary'};
xlswrite('test_vectors_multiply.xls', text, 'Generated test vector values', 'A1');

temp = sample_frac';
xlswrite('test_vectors_multiply.xls', temp, 'Generated test vector values', 'A2');
temp = coeff_frac';
xlswrite('test_vectors_multiply.xls', temp, 'Generated test vector values', 'B2');
temp = y_frac';
xlswrite('test_vectors_multiply.xls', temp, 'Generated test vector values', 'C2');

temp = sample_int';
xlswrite('test_vectors_multiply.xls', temp, 'Generated test vector values', 'E2');
temp = coeff_int';
xlswrite('test_vectors_multiply.xls', temp, 'Generated test vector values', 'F2');
temp = y_int';
xlswrite('test_vectors_multiply.xls', temp, 'Generated test vector values', 'G2');