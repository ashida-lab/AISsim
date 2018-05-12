function [ bits ] = aisDecodeMsg1( MsgType,Rpt,MMSI,navStat,rateOfTurn,speed,posAcc,...
    Long,Lat,course,hdg,timeStamp,rsvd,spare,RAIM,commState)

bits(1:6)=de2bi(MsgType,6,'left-msb');
bits(7:8)=de2bi(Rpt,2,'left-msb');
bits(9:38)=de2bi(MMSI,30,'left-msb');
bits(39:42)=de2bi(navStat,4,'left-msb');
bits(43:50)=de2bi(rateOfTurn,8,'left-msb');
bits(51:60)=de2bi(speed,10,'left-msb');
bits(61)=de2bi(posAcc,1,'left-msb');
bits(62:89)=de2bi(floor(Long*60*10000),28,'left-msb');
bits(90:116)=de2bi(floor(Lat*60*10000),27,'left-msb');
bits(117:128)=de2bi(course,12,'left-msb');
bits(129:137)=de2bi(hdg,9,'left-msb');%True heading, Degrees (0-359)
bits(138:143)=de2bi(timeStamp,6,'left-msb');
bits(144:147)=de2bi(rsvd,4,'left-msb');
bits(148)=de2bi(spare,1,'left-msb');
bits(149)=de2bi(RAIM,1,'left-msb');
bits(150:168)=de2bi(commState,19,'left-msb');