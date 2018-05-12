function [ signal_gmsk ] = aisRemoveMsg1( bits,samplesPerSymbol )
%aisDecodeMsg1 reads in the bits from an AIS Msg Type 1,2 or 3 and outputs  
% the data fields for the message.  AIS Msg Types 1,2 or 3 are ship
% position reports.

% Copyright 2016, The MathWorks, Inc.

zero_sequence=[0;0;0;0;0;0;0;0];
training_sequence=[1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0];%bit
start_flag=[0;1;1;1;1;1;1;0];

flippedData=aisFlipBytes(bits);

crcGen = comm.CRCGenerator('Polynomial','X^16 + X^12 + X^5 + 1',...
    'InitialConditions',1,'DirectMethod',true,'FinalXOR',1);
checkSum = step(crcGen,flippedData);

end_flag=[0;1;1;1;1;1;1;0];
% buffer_sequence= randi([0 1],24,1);
buffer_sequence=[1;1;1;1;0;0;1;1;1;0;1;1;1;0;0;0;1;0;1;1;1;0;1;0];

sbits=aisStuff(checkSum);

signal=logical([zero_sequence;training_sequence;start_flag;sbits;end_flag;buffer_sequence]);

hMod = comm.GMSKModulator('BitInput', true,'BandwidthTimeProduct',0.3,'PulseLength',3, 'InitialPhaseOffset', 0,'SamplesPerSymbol',samplesPerSymbol);

% Apply NRZI encoding
for ii=2:length(signal)
    if signal(ii)==1
        signal(ii)=signal(ii-1);
    else
        signal(ii)=~signal(ii-1);
    end
end


signal_gmsk=step(hMod,signal);

end