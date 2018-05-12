function [ charStr ] = aisDecodeMsg21( bits )
%aisDecodeMsg19 reads in the bits from an AIS Msg Type 21 and outputs  
% the data fields for the message.  AIS Msg Types 21 are Aids To  
% Navigation name and position reports.

% Copyright 2016, The MathWorks, Inc.


MsgType=2.^(5:-1:0)*bits(1:6);
Rpt=[2 1]*bits(7:8);
ID=2.^(29:-1:0)*bits(9:38);
navType=2.^(4:-1:0)*bits(39:43);
name=convertBitsToString(bits(44:163));
posAcc=bits(164);
Long=2.^(27:-1:0)*bits(165:192);
Lat=2.^(26:-1:0)*bits(193:219);
refPos=2.^(29:-1:0)*bits(220:249);
posFix=2.^(3:-1:0)*bits(250:253);
timeStamp=2.^(5:-1:0)*bits(254:259);
offPos=bits(260);
rsvd=2.^(7:-1:0)*bits(261:268);
RAIM=bits(269);
spare=2.^(2:-1:0)*bits(270:272);

charStr{1}=strcat('Msg Type: ',num2str(MsgType));
charStr{2}=strcat('Repeat: ',num2str(Rpt));
charStr{3}=strcat('ATON: ',num2str(ID));
charStr{4}=strcat('Nav Type: ',num2str(navType));
charStr{5}=strcat('ATON Name: ',name);
charStr{6}=strcat('Position Accuracy: ',num2str(posAcc));
charStr{7}=strcat('Longitude: ',num2str(Long));
charStr{8}=strcat('Latitude: ',num2str(Lat));
charStr{9}=strcat('Reference Position: ',num2str(refPos));
charStr{10}=strcat('Position Fix: ',num2str(posFix));
charStr{10}=strcat('Time Stamp: ',num2str(timeStamp));
charStr{11}=strcat('Off Position Flag: ',num2str(offPos));
charStr{12}=strcat('RAIM: ',num2str(RAIM));

end

