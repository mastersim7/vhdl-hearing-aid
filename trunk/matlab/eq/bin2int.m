% bin2int.m
% Author: Mathias Lundell
% Date: 2011-04-01
% Returns integer value for signed binary string.
function int = bin2int(s)

if isstr(s) == 0
    fprintf('Input must be a string.\n');
    return;
end;

% Take 2's complement for negative numbers
if s(1) == '1'
    % Find first 1
    index = 1;
    i = 1;
    for i = length(s):-1:1
        if s(i) == '1'
            index = i;
            break;
        end
    end
    
    % Invert all bits left of first 1
    for i = 1:length(s)
        if i < index
            if s(i) == '0'
                s(i) = '1';
            else
                s(i) = '0';
            end
        end
    end;
    
    int = -bin2dec(s);
else
    int = bin2dec(s);
end;