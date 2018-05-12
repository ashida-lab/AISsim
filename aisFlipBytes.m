function flippedBits = aisFlipBytes(bitsIn)
% aisFlipBytes takes message bits in and outputs the bytes in flipped
% order.  In an AIS message, the first 6 bits in the message are
% transmitted in bit #8 to #3, and the next 2 bits are trasnsmitted in bit
% #2 to #1.  Every byte is like that, so take every 8 bits and reverse the
% order to build an AIS message.

% Copyright 2016, The MathWorks, Inc.

nBytes=length(bitsIn)/8;
r1=reshape(bitsIn,8,nBytes);
r2=flipud(r1);
flippedBits=r2(:);

