% generate_random.m
% Mathias Lundell
% 2011-03-10
% Generates a random integer based on a specific number of bits. The
% generated integer could either be signed or unsigned.
% n : number of bits
% signed : 1 = negative and positive numbers; 0 = only positive numbers
function num = generate_random(n, signed)

% Generate random numbers
if rand(1,1) > 0.5
    neg = 1;
else
    neg = -1;
end

if signed == 1
    max = 2^(n-1)-1;

    num = neg*max*rand(1,1);

    if round(num) == max
        num = num-1;
    end
else
    max = 2^n;
    num = neg*max*rand(1,1);
end

num = round(num);