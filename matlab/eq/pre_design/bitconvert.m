%magnitude = 24
%greatest = (2^ magnitude-1) -1
%n = 111;
% Coefficients
coeff_num = 10; % number of randomly generated coefficients
coeff_int = 0;
coeff_frac = 0.0;
coeff_bin = '';  
coeff_n = 24;    % Coefficients should be 24 bits
coeff_max = 2^(coeff_n-1)-1;

for m=1:8
    for i=1:coeff_num
        y = b{m}(i) * coeff_max;
        y=round(y)
        l{i,m} = int2bin(y, 24)
    end;
end;

%now let's write them to a text file 
fid=fopen('coeff.txt','wt');
[rows,cols]=size(l);
for m=1:rows,
for i=1:cols,
%fprintf(fid,'%s,',l{i,1:end})
%fprintf(fid,'tc(%i,%i)<="%s";', m, i, l{m,i});
fprintf(fid,'"%s",',l{m,i});

end
fprintf(fid,'\b),\n(');
end
fclose(fid);



