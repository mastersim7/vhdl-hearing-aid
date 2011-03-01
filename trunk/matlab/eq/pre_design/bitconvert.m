magnitude = 23
greatest = 2^ 23 
%val1=cellstr(24)
val1= cell(111,1);


str = '000000010101111010001000';
n = 111;

% no pre-allocation

for i=1:n
   l(i) = str;
end

for i=1:n ,
y = b1(i) * greatest
y=round(y);

l(i) = dec2bin(mod((y),2^24),24)
end;



% 
% str = dec2bin(y,23)
% zeros = dec2bin(0,1)
% ones = dec2bin(1,1)
%   
% str1= [zeros str]
% 
% str1+str1
%   
