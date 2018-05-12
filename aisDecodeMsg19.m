function [ charStr ] = aisDecodeMsg19( bits )
%aisDecodeMsg19 reads in the bits from an AIS Msg Type 19 and outputs  
% the data fields for the message.  AIS Msg Types 19 are extended 
% class B ship position reports.

% Copyright 2016, The MathWorks, Inc.


MsgType=2.^(5:-1:0)*bits(1:6);
Rpt=[2 1]*bits(7:8);
MMSI=2.^(29:-1:0)*bits(9:38);
rsvd=2.^(7:-1:0)*bits(39:46);
speed=2.^(9:-1:0)*bits(47:56);
posAcc=bits(57);
Long=2.^(27:-1:0)*bits(58:85);
Lat=2.^(26:-1:0)*bits(86:112);
course=2.^(11:-1:0)*bits(113:124);
hdg=2.^(8:-1:0)*bits(125:133);
timeStamp=2.^(5:-1:0)*bits(134:139);
rsvd2=2.^(3:-1:0)*bits(140:143);
name=convertBitsToString(bits(144:263));
typeOfShip=2.^(7:-1:0)*bits(264:271);
shipDim=2.^(29:-1:0)*bits(272:301);
typeOfNav=2.^(3:-1:0)*bits(302:305);
RAIM=bits(306);
dte=bits(307);
spare=2.^(4:-1:0)*bits(308:312);

charStr{1}=strcat('Msg Type: ',num2str(MsgType));
charStr{2}=strcat('Repeat: ',num2str(Rpt));
charStr{3}=strcat('MMSI: ',num2str(MMSI));
charStr{4}=strcat('Speed: ',num2str(speed));
charStr{5}=strcat('Position Accuracy: ',num2str(posAcc));
charStr{6}=strcat('Longitude: ',num2str(Long));
charStr{7}=strcat('Latitude: ',num2str(Lat));
charStr{8}=strcat('Course Over Ground: ',num2str(course));
charStr{9}=strcat('Heading: ',num2str(hdg));
charStr{10}=strcat('Time Stamp: ',num2str(timeStamp));
charStr{11}=strcat('Ship Name: ',name);
charStr{12}=strcat('Ship Type: ',num2str(typeOfShip));
charStr{13}=strcat('Ship Dimensions: ',num2str(shipDim));
charStr{14}=strcat('Nav Type: ',num2str(typeOfNav));
charStr{15}=strcat('RAIM: ',num2str(RAIM));

end

