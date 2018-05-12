function [ charStr ] = aisDecodeMsg5( bits )
%aisDecodeMsg reads in the bits from an AIS Msg Type 5 and outputs  
% the data fields for the message.  AIS Msg Types 5 is a ship static or 
% voyage report.

% Copyright 2016, The MathWorks, Inc.


MsgType=2.^(5:-1:0)*bits(1:6);
Rpt=[2 1]*bits(7:8);
UserID=2.^(29:-1:0)*bits(9:38);
AISversion=2.^(1:-1:0)*bits(39:40);
IMO=2.^(29:-1:0)*bits(41:70);
callSign=convertBitsToString(bits(71:112));
shipName=convertBitsToString(bits(113:232));
shipType=2.^(7:-1:0)*bits(233:240);
dimension=2.^(29:-1:0)*bits(241:270);
navDev=2.^(3:-1:0)*bits(271:274);
eta=2.^(19:-1:0)*bits(275:294);
draught=2.^(7:-1:0)*bits(295:302);
destination=convertBitsToString(bits(303:422));
dte=bits(423);
spare=bits(424);

charStr{1}=strcat('Msg Type: ',num2str(MsgType));
charStr{2}=strcat('Repeat: ',num2str(Rpt));
charStr{3}=strcat('MMSI: ',num2str(UserID));
charStr{4}=strcat('AIS Version: ',num2str(AISversion));
charStr{5}=strcat('IMO: ',num2str(IMO));
charStr{6}=strcat('Call Sign: ',callSign);
charStr{7}=strcat('Ship Name: ',shipName);
charStr{8}=strcat('Ship Type: ',num2str(shipType));
charStr{9}=strcat('Dimension: ',num2str(dimension));
charStr{10}=strcat('Nav Device: ',num2str(navDev));
charStr{11}=strcat('ETA: ',num2str(eta));
charStr{12}=strcat('Draught: ',num2str(draught));
charStr{13}=strcat('Destination: ',destination);
charStr{14}=strcat('DTE: ',num2str(dte));



end

