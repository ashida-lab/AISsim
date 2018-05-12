function [ charStr ] = aisDecodeMsg18( bits )
%aisDecodeMsg18 reads in the bits from an AIS Msg Type 18 and outputs  
% the data fields for the message.  AIS Msg Types 18 are class B ship
% position reports.

% Copyright 2016, The MathWorks, Inc.


MsgType=2.^(5:-1:0)*bits(1:6);
Rpt=[2 1]*bits(7:8);
MMSI=2.^(29:-1:0)*bits(9:38);
rsvd=2.^(7:-1:0)*bits(39:46);
speed=2.^(9:-1:0)*bits(47:56);
posAcc=bits(57);
Long=(-2^27*bits(58)+2.^(26:-1:0)*bits(59:85))/10000/60;
Lat=(-2^26*bits(86)+2.^(25:-1:0)*bits(87:112))/10000/60;
course=2.^(11:-1:0)*bits(113:124);
hdg=2.^(8:-1:0)*bits(125:133);
timeStamp=2.^(5:-1:0)*bits(134:139);
rsvd2=2.^(3:-1:0)*bits(140:143);
spare=bits(144:147);
RAIM=bits(148);
commStateFlag=bits(149);
commState=2.^(18:-1:0)*bits(150:168);

charStr{1}=strcat('Msg Type: ',num2str(MsgType));
charStr{2}=strcat('Repeat: ',num2str(Rpt));
charStr{3}=strcat('MMSI: ',num2str(MMSI));
charStr{4}=strcat('Position Accuracy: ',num2str(posAcc));
charStr{5}=strcat('Longitude: ',num2str(Long));
charStr{6}=strcat('Latitude: ',num2str(Lat));
charStr{7}=strcat('Course Over Ground: ',num2str(course));
charStr{8}=strcat('Heading: ',num2str(hdg));
charStr{9}=strcat('Time Stamp: ',num2str(timeStamp));
charStr{10}=strcat('RAIM: ',num2str(RAIM));
charStr{11}=strcat('Communication State Flag: ',num2str(commStateFlag));
charStr{12}=strcat('Communication State: ',num2str(commState));

end

