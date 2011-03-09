% Takes a decimal value v and the number of bits as parameters and returns a 
% string of signed binary.
function bv = dec2signedbinary(v, n)

if v < 0
    % Do 2's complement for negative numbers
    v = -v;
    bv = dec2bin(v, n)
    
    % Find first 1
    index = 1;
    i = 1;
    for i = length(bv):-1:1
        if bv(i) == '1'
            index = i
            break;
        end
    end

    for i = 1:length(bv)
        if i < index
            if bv(i) == '0'
                bv(i) = '1';
            else
                bv(i) = '0';
            end
        end
    end
else
    bv = dec2bin(v, n);
end