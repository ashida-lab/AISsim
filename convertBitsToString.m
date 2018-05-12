function [ name ] = convertBitsToString( bits )
%convertBitsToString reads in bits from and AIS message and converts them
%to the ASCII characters as specified in M.1371, table 14 

% Copyright 2016, The MathWorks, Inc.

name='';
chars = (reshape(bits,6,length(bits)/6))';
lut='@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^__!"#$%&~()*+,-./0123456789:;<=>?';
for ii=1:size(chars,1)
    idx=chars(ii,:)*2.^(5:-1:0)'+1;
    name=strcat(name,lut(idx));
end
    
end

