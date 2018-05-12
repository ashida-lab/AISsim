function [bitsOut] = aisStuff(bitsIn)
% aisUnstuff takes message bits in and outputs a new bitstream with the
% zero stuffing bits removed
% In HDLC, if a message has 5 consecutive 1's a zero should be inserted

% Copyright 2016, The MathWorks, Inc.

onesCount=0;
bitsIn=double(bitsIn);
bitsOut=zeros(length(bitsIn)+10,1);
bitsOutIdx=1;
for ii=1:length(bitsIn)
    if bitsIn(ii)==1
        onesCount=onesCount+1;
    else
        onesCount=0;
    end
    
    bitsOut(bitsOutIdx)=bitsIn(ii);
    bitsOutIdx=bitsOutIdx+1;
    
    if onesCount==5
        bitsOut(bitsOutIdx)=0;
        bitsOutIdx=bitsOutIdx+1;
        onesCount=0;
    end
    

end
bitsOutIdx=max(length(bitsIn),bitsOutIdx);
bitsOut=bitsOut(1:bitsOutIdx);

