% generate_testvectors.m
% Mathias Lundell
% 2011-03-10
% Generates a specific number of test vectors. For Saves them to arrays. At the
% moment an addition with is performed.
clc;

n = 12; % number of bits
num = 1000; % number of test vectors
sign = 1; % want signed bit vectors
max = 2^(n-1)-1;
min = -2^(n-1);

aint = 0;
abin = '';
bint = 0;
bbin = '';

ybin = '';
for i = 1:num
    % Generate a pair of test vectors
    aint(i) = generate_random(n, sign);
    abin(i,:) = int2bin(aint(i), n);
    bint(i) = generate_random(n, sign);
    bbin(i,:) = int2bin(bint(i), n);
    
    % Generate the corresponding output
    yint(i) = aint(i) + bint(i);
    
    ybin(i,:) = int2bin(yint(i), n+1);
end