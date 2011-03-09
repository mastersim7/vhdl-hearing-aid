function num = generate_random(n, signed)

% Generate random numbers
if signed == 1
    max = 2^(n-1)-1;

    num = max*rand(1,1);

    if round(num) == max
        num = num-1;
    end
else
    max = 2^n;
    num = max*(rand(1,1) + 1)/2;
end

num = round(num);