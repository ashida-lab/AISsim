function [ charStr,ship ] = aisDecodeMsg1( bits )
%aisDecodeMsg1 reads in the bits from an AIS Msg Type 1,2 or 3 and outputs  
% the data fields for the message.  AIS Msg Types 1,2 or 3 are ship
% position reports.

% Copyright 2016, The MathWorks, Inc.


MsgType=2.^(5:-1:0)*bits(1:6);
Rpt=[2 1]*bits(7:8);
MMSI=2.^(29:-1:0)*bits(9:38);
navStat=2.^(3:-1:0)*bits(39:42);
rateOfTurn=2.^(7:-1:0)*bits(43:50);
speed=2.^(9:-1:0)*bits(51:60)*.1;
posAcc=bits(61);
% Long=2.^(27:-1:0)*bits(62:89);
% Lat=2.^(26:-1:0)*bits(90:116);
Long=(-2^27*bits(62)+2.^(26:-1:0)*bits(63:89))/10000/60;
Lat=(-2^26*bits(90)+2.^(25:-1:0)*bits(91:116))/10000/60;
course=2.^(11:-1:0)*bits(117:128)*.1;
hdg=2.^(8:-1:0)*bits(129:137);
timeStamp=2.^(5:-1:0)*bits(138:143);
rsvd=2.^(3:-1:0)*bits(144:147);
spare=bits(148);
RAIM=bits(149);
commState=2.^(18:-1:0)*bits(150:168);

charStr{1}=strcat('Msg Type: ',num2str(MsgType));
charStr{2}=strcat('Repeat: ',num2str(Rpt));
charStr{3}=strcat('MMSI: ',num2str(MMSI));
charStr{4}=strcat('Nav State: ',num2str(navStat));
charStr{5}=strcat('Rate Of Turn: ',num2str(rateOfTurn));
charStr{6}=strcat('Speed: ',num2str(speed));
charStr{7}=strcat('Position Accuracy: ',num2str(posAcc));
charStr{8}=strcat('Longitude: ',num2str(Long));
charStr{9}=strcat('Latitude: ',num2str(Lat));
charStr{10}=strcat('Course Over Ground: ',num2str(course));
charStr{11}=strcat('Heading: ',num2str(hdg));
charStr{12}=strcat('Time Stamp: ',num2str(timeStamp));
charStr{13}=strcat('RAIM: ',num2str(RAIM));
charStr{14}=strcat('Communication State: ',num2str(commState));

ship.Long=Long;
ship.Lat=Lat;
ship.speed=speed;
ship.course=course;

end

