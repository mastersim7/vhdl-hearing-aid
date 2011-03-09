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