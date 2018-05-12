function hexChars = bitsToHex(msgBits)

% Copyright 2016, The MathWorks, Inc.

nChars = length(msgBits)/4;
for ii=1:nChars
    bits=msgBits((ii-1)*4+1:ii*4);
    ch=dec2hex(2.^(3:-1:0)*bits);
    hexChars(ii)=ch;
end