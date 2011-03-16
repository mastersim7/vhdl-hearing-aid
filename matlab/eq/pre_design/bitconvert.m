magnitude = 23
greatest = 2^ 23 
n = 111;
for m=1:8 ,
for i=1:n ,
    y = b{m}(i) * greatest;
    y=round(y);
    l{m,i} = dec2bin(mod((y),2^24),24);
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



