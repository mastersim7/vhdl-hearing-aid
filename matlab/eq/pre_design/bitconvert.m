magnitude = 23
greatest = 2^ 23 
n = 111;
for m=1:8 ,
for i=1:n ,
y = b1(i) * greatest;
y=round(y);
l{m,i} = dec2bin(mod((y),2^24),24);
end;
end;


%now let's write them to a text file 
fid=fopen('coeff.txt','wt');
[rows,cols]=size(l);

for i=1:cols
%fprintf(fid,'%s,',l{i,1:end})
fprintf(fid,'CO(1,1)=%s;\t',l{1:rows,i});
fprintf(fid,'\n');
end

fclose(fid);



