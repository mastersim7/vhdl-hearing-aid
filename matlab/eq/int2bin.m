% int2bin.m
% Mathias Lundell
% 2011-02-10
% Takes a integer value v and the number of bits as parameters and returns a 
% string of signed binary.
function bv = int2bin(v, n)
 
% Give error message if v is not an integer
if mod(v,1) ~= 0
    fprintf('Error in int2bin. Only integers allowed.\n');
    
% Give error message if v exceeds boundary for n bits.
elseif (v > 2^(n-1)-1) || (v < -2^(n-1))
    if v > 0
        fprintf('Error in int2bin. Integer v = %d exceeds max value %d for n = %d bits.\n', v, 2^(n-1)-1, n);
    else
        fprintf('Error in int2bin. Integer v = %d exceeds min value %d for n = %d bits.\n', v, -2^(n-1), n);
    end
    
% Do 2's complement for negative numbers
elseif v < 0
    v = -v;
    bv = dec2bin(v, n);
    
    % Find first 1
    index = 1;
    i = 1;
    for i = length(bv):-1:1
        if bv(i) == '1'
            index = i;
            break;
        end
    end
    
    % Invert all bits left of first 1
    for i = 1:length(bv)
        if i < index
            if bv(i) == '0'
                bv(i) = '1';
            else
                bv(i) = '0';
            end
        end
    end
% Regular conversion to binary
else
    bv = dec2bin(v, n);
end