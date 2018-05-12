MsgType=1;
Rpt=0;
MMSI=23456;
navStat=0;
rateOfTurn=100;
speed=300;%1/10knot
posAcc=0;%0=deafult 1=high
Long=139.55;
Lat=40.67;
course=900;%1/10deg
hdg=250;%deg
timeStamp=48;
rsvd=0;
spare=0;
RAIM=0;
commState=0;

bits=aisEncodeMsg1( MsgType,Rpt,MMSI,navStat,rateOfTurn,speed,posAcc,...
    Long,Lat,course,hdg,timeStamp,rsvd,spare,RAIM,commState);

zero_sequence=[0;0;0;0;0;0;0;0];
training_sequence=[1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0];%bit
start_flag=[0;1;1;1;1;1;1;0];

bits=bits.';
flippedData=aisFlipBytes(bits);

crcGen = comm.CRCGenerator('Polynomial','X^16 + X^12 + X^5 + 1',...
    'InitialConditions',1,'DirectMethod',true,'FinalXOR',1);
checkSum = step(crcGen,flippedData);

% figure;plot(bits)
% hold on;plot(checkSum)

end_flag=[0;1;1;1;1;1;1;0];
buffer_sequence=[1;1;1;1;0;0;1;1;1;0;1;1;1;0;0;0;1;0;1;1;1;0;1;0];
% buffer_sequence= randi([0 1],24,1);

sbits=aisStuff(checkSum);

% figure;plot(flippedData)
% hold on;plot(sbits)

signal=logical([zero_sequence;training_sequence;start_flag;sbits;end_flag;buffer_sequence]);

samplesPerSymbol = 24;
hMod = comm.GMSKModulator('BitInput', true,'BandwidthTimeProduct',0.3,'PulseLength',3, 'InitialPhaseOffset', 0,'SamplesPerSymbol',samplesPerSymbol);
hAWGN = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)','SNR',25);
hDemod = comm.GMSKDemodulator('BitOutput', true,'BandwidthTimeProduct',0.3,'PulseLength',3, 'InitialPhaseOffset', 0,'SamplesPerSymbol',samplesPerSymbol);
% figure;%plot(signal);
% hold on

% Apply NRZI encoding
for ii=2:length(signal)
    if signal(ii)==1
        signal(ii)=signal(ii-1);
    else
        signal(ii)=~signal(ii-1);
    end
end

% plot(signal)

signal_gmsk=step(hMod,signal);
signal_demod=step(hDemod,signal_gmsk);

% plot(circshift(signal_demod,[-16,0]));
% hold off
% 
% figure;plot(real(signal_gmsk))

data=zeros(100000,1);

t=1:length(signal_gmsk);
t=t.'/9600/samplesPerSymbol;
fdop=3e3;

data(12345+1:12345+length(signal_gmsk))=1.0*signal_gmsk;
data(12345+1+length(signal_gmsk)/2:12345+length(signal_gmsk)/2+length(signal_gmsk))...
    =data(12345+1+length(signal_gmsk)/2:12345+length(signal_gmsk)/2+length(signal_gmsk))+0.3*signal_gmsk.*exp(1i*fdop*t);
% data(45678+1:45678+length(signal_gmsk))=0.8*signal_gmsk;

data=step(hAWGN,data);

aisDecodeMsg1(bits)

% 
% figure;plot(abs(fft(data)));
% hold on;
% data=data;
% plot(abs(fft(data)));
% hold off