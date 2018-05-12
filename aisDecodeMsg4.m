function [ charStr ] = aisDecodeMsg4( bits )
%aisDecodeMsg reads in the bits from an AIS Msg Type 5 and outputs  
% the data fields for the message.  AIS Msg Types 5 is a base station
% reports.

% Copyright 2016, The MathWorks, Inc.


MsgType=2.^(5:-1:0)*bits(1:6);
Rpt=[2 1]*bits(7:8);
UserID=2.^(29:-1:0)*bits(9:38);
year=2.^(13:-1:0)*bits(39:52);
month=2.^(3:-1:0)*bits(53:56);
day=2.^(4:-1:0)*bits(57:61);
hour=2.^(4:-1:0)*bits(62:66);
minute=2.^(5:-1:0)*bits(67:72);
second=2.^(5:-1:0)*bits(73:78);
posAcc=bits(79);
Long=2.^(27:-1:0)*bits(80:107);
Lat=2.^(26:-1:0)*bits(108:134);
type=2.^(3:-1:0)*bits(135:138);
spare=2.^(9:-1:0)*bits(139:148);
RAIM=bits(149);
commState=2.^(18:-1:0)*bits(150:168);

charStr{1}=strcat('Msg Type: ',num2str(MsgType));
charStr{2}=strcat('Repeat: ',num2str(Rpt));
charStr{3}=strcat('User ID: ',num2str(UserID));
charStr{4}=strcat('UTC Year: ',num2str(year));
charStr{5}=strcat('UTC Month: ',num2str(month));
charStr{6}=strcat('UTC Day: ',num2str(day));
charStr{7}=strcat('UTC Hour: ',num2str(hour));
charStr{8}=strcat('UTC Minute: ',num2str(minute));
charStr{9}=strcat('UTC Second: ',num2str(second));
charStr{10}=strcat('Position Accuracy: ',num2str(posAcc));
charStr{11}=strcat('Longitude: ',num2str(Long));
charStr{12}=strcat('Latitude: ',num2str(Lat));
charStr{13}=strcat('Type: ',num2str(type));
charStr{14}=strcat('RAIM: ',num2str(RAIM));
charStr{15}=strcat('Communication State: ',num2str(commState));



end

