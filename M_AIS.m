clear all
close all

sw_fig=0;

logFlag=1;
if logFlag
    logfile='capture.txt';
    fileID=fopen(logfile,'a');
end

% [filename,pathname]=uigetfile('X:\DATA\AIS\*.wav');
% [signal, SampleRate] =audioread(strcat(pathname,'\',filename));
% data=signal(:,1)+1i*signal(:,2);
% figure;plot((abs(data)));title('Original');
% 
% return

% ss=11500000;
samplesPerSymbol = 24;

%受信データの読み込み
Dtype=0;

switch Dtype
    case 0
        [filename,pathname]=uigetfile('*.mat');
        load(strcat(pathname,'\',filename))
        
    case 1
        [filename,pathname]=uigetfile('Z:\DATA\AIS\*.wav');
        [signal, SampleRate] =audioread(strcat(pathname,'\',filename));
        data=signal(:,1)+1i*signal(:,2);
%         data=signal(ss+1:ss+1000000,1)+1i*signal(ss+1:ss+1000000,2);
        figure;plot((abs(data)));title('Original');
        
        data=resample(data,230400,SampleRate);
        
        RX=comm.SDRRTLReceiver('CenterFrequency',161976000,...
            'SampleRate',samplesPerSymbol*9600,...
            'SamplesPerFrame',262144,...
            'OutputDataType','single');
    case 2
        AIS_signal_generator;
        
        RX=comm.SDRRTLReceiver('CenterFrequency',161976000,...
            'SampleRate',samplesPerSymbol*9600,...
            'SamplesPerFrame',262144,...
            'OutputDataType','single');
    
    case 3
         RX=comm.SDRRTLReceiver('CenterFrequency',161976000,...
            'SampleRate',samplesPerSymbol*9600,...
            'SamplesPerFrame',262144,...
            'EnableTunerAGC',false,...
            'TunerGain',20,...
            'OutputDataType','single');
        
        data=[];
        
        for p=1:10
            data = [data; RX.step]; 
        end
        
    case 4
        RX=comm.SDRRTLReceiver('CenterFrequency',161976000,...
            'SampleRate',samplesPerSymbol*9600,...
            'SamplesPerFrame',262144,...
            'OutputDataType','single');
        
        [filename,pathname]=uigetfile('*.mat');
        load(strcat(pathname,'\',filename))
        
        data=double(data2);
end

% aaa=circshift(fft(data),-2.225e6);
% data=ifft(aaa);

data=data-mean(data);

ok_data=[];

nCaptures = 3;      % Each data file has 1 capture

figure;spectrogram(data);

syncCalc = syncGen(samplesPerSymbol);
syncIdeal = unwrap(diff(angle(syncCalc(1:samplesPerSymbol*20+1))));

% Checksum using comm.CRCGenerator
crcGen = comm.CRCGenerator('Polynomial','X^16 + X^12 + X^5 + 1',...
    'InitialConditions',1,'DirectMethod',true,'FinalXOR',1);

% Gaussian Filter Design
BT=0.3;
pulseLength=3;
gx = gaussdesign(BT,pulseLength,samplesPerSymbol);

% Phase Extractor
phaseCalc=dsp.PhaseExtractor;

tic;
% Loop for nCaptures
for nn=1:nCaptures
    % Loop until find invalid message
    validCRC=1;

    data=double(data);

    while validCRC
        figure;plot(abs(data));title('original data');
        
        % Find strongest RX signal in capture
        windowLen = RX.SamplesPerFrame/128;
        l=floor(length(data)/windowLen);
        m=sum(reshape(abs(data(1:l*windowLen)),windowLen,l));
        d=diff(m);
        
        if sw_fig
            figure;plot(d);title('Find strongest RX signal');
        end
        
        [mx,inx]=max(d(1:l-1));
        md=mean(abs(d(1:l-1)));
        inx = max(2,inx);
        inx = min(inx,l-2);

        % Search the data set for a transition from low to high power. The max
        % needs to be 8x greater than the mean in a segment to be a transition.
        % Then trim the waveform from the start of the transition until the end.
        if mx>8*md
            a1=d(inx)-d(inx-1);
            a2=d(inx)-d(inx+1);
            if a1>a2
                startPt = inx*windowLen;
            else
                startPt = max(1,(inx-1)*windowLen);
            end
        else
            startPt = 1;
        end

        % Trim waveform
        % Messages can be from 184 bits long (including CRC) to 440 bits long.
        % There are also some ramp up bits, 24 sync bits and and an 8 bit start flag.
        % Capture enough samples to get longest message, which is the window length
        % plus 480bits*samplesPerSymbol.
        endPt = min(length(data),startPt+windowLen+480*samplesPerSymbol);
        dataSlice=data(startPt:endPt);
        aisIdx=[startPt endPt];
        
        if sw_fig
            figure;plot(abs(dataSlice));title('Trim waveform')
        end
        
        % Coarse Frequency Correction
        Y=abs(fftshift(fft(dataSlice)));
        idx=find(Y==max(Y));
        frShift=(floor(length(dataSlice)/2)-idx)*RX.SampleRate/length(Y);
        hc=comm.PhaseFrequencyOffset('FrequencyOffset',frShift,'SampleRate',RX.SampleRate);
        dataShifted=step(hc,dataSlice);
        
        if sw_fig
            figure;plot(abs(((dataShifted))));title('Coarse Frequency Correction');
            figure;plot(abs(fftshift(fft(dataShifted))));title('Coarse Frequency Correction');
        end
        
        % Find Start and End Points
        newStart=21;
        newEnd=length(dataShifted)-20;
        m=mean(abs(dataShifted));
        idx1=find(abs(dataShifted)>m,1,'first');
        idx2=find(abs(dataShifted)>m,1,'last');
        idxStart=max(newStart,idx1);
        idxEnd=min(newEnd,idx2);
        aisSig=dataShifted(idxStart:idxEnd);
        
        % GMSK Filter
        rxf = filter(gx,1,aisSig);

        % Fine Frequency Correction with comm.FrequencySynchronizer
        rxfShifted = rxf;
        
        if sw_fig
            figure;plot(abs(fftshift(fft(rxfShifted))));title('Spectrum after FFC')
        end
        
        % Find max correlation to preamble
        rxAngles = step(phaseCalc,rxfShifted);
        syncCorr=zeros(length(rxAngles)-length(syncIdeal),1);
        if (length(rxAngles) > samplesPerSymbol*50 + length(syncIdeal))
            for ii=1:samplesPerSymbol*50
                syncCorr(ii)=syncIdeal'*rxAngles(ii:ii+length(syncIdeal)-1);
            end
        else
            syncCorr(1)=1;
        end
       
        % Compute best sample phase for making bit decisions
        [m,idx]=max(abs(syncCorr));
        samplePhase=mod(idx,samplesPerSymbol)+floor(samplesPerSymbol/2);
        
        % Make bit decisions (phase change greater than pi/4 is logical 1
        abits=zeros(size(rxfShifted(samplePhase:samplesPerSymbol:end)));
        idx=find(abs(diff(step(phaseCalc,rxfShifted(samplePhase:samplesPerSymbol:end))))>pi/4);
        abits(idx)=1;
        
        sb=1;
        % Search the first 50 bits for the StartByte flag (0x7E)
        if length(abits)>56
            for ii=2:50
                if (sum(abits(ii:ii+5))==6 && abits(ii-1)==0 && abits(ii+6)==0 && sb==1)
                    sb=ii+7
                end
            end
        end

        % Read the message type and route the bits to the correct decode
        % function
        msgType=0;
        if length(abits) >= sb+7
            msgType=(2.^(0:5)*abits(sb+2:sb+7));
        end

        % Follow AIS spec to unstuff after 5 consecutive 1's.  This will 
        % unstuff everything, including the end flag in the AIS message. 
        ubits=aisUnstuff(abits(sb:end));

        % Decode message based on detected message type
        % Compute the checksum, compare to the received message bits, and
        % if the checksum passes flip the bytes and decode the message.
        
        switch msgType
            case 1
                if length(ubits)>=184
                    checkSum = step(crcGen,ubits(1:168));
                    if isequal(checkSum(169:184),ubits(169:184))
                        flippedData=aisFlipBytes(ubits(1:184));
                        [cs,ship]=aisDecodeMsg1(flippedData);
                        validCRC=1;
                    else
                        validCRC=0;
                    end
                    reset(crcGen);
                else
                    validCRC=0;
                end
            case 2
                if length(ubits)>=184
                    checkSum = step(crcGen,ubits(1:168));
                    if isequal(checkSum(169:184),ubits(169:184))
                        flippedData=aisFlipBytes(ubits(1:184));
                        cs=aisDecodeMsg1(flippedData);
                        validCRC=1;
                    else
                        validCRC=0;
                    end
                    reset(crcGen);
                else
                    validCRC=0;
                end
            case 3
                if length(ubits)>=184
                    checkSum = step(crcGen,ubits(1:168));
                    if isequal(checkSum(169:184),ubits(169:184))
                        flippedData=aisFlipBytes(ubits(1:184));
                        cs=aisDecodeMsg1(flippedData);
                        validCRC=1;
                    else
                        validCRC=0;
                    end
                    reset(crcGen);
                else
                    validCRC=0;
                end
            case 4
                if length(ubits)>=184
                    checkSum = step(crcGen,ubits(1:168));
                    if isequal(checkSum(169:184),ubits(169:184))
                        flippedData=aisFlipBytes(ubits(1:184));
                        cs=aisDecodeMsg4(flippedData);
                        validCRC=1;
                    else
                        validCRC=0;
                    end
                    reset(crcGen);
                else 
                    validCRC=0;
                end
            case 5
                if length(ubits)>=440
                    checkSum = step(crcGen,ubits(1:424));
                    if isequal(checkSum(425:440),ubits(425:440))
                        flippedData=aisFlipBytes(ubits(1:440));
                        cs=aisDecodeMsg5(flippedData);
                        validCRC=1;
                    else
                        validCRC=0;
                    end
                    reset(crcGen);
                else
                    validCRC=0;
                end
            case 18
                if length(ubits)>=184
                    checkSum = step(crcGen,ubits(1:168));
                    if isequal(checkSum(169:184),ubits(169:184))
                        flippedData=aisFlipBytes(ubits(1:184));
                        cs=aisDecodeMsg18(flippedData);
                        validCRC=1;
                    else
                        validCRC=0;
                    end
                    reset(crcGen);
                else
                    validCRC=0;
                end
            case 19
                if length(ubits)>=328
                    checkSum = step(crcGen,ubits(1:312));
                    if isequal(checkSum(313:328),ubits(313:328))
                        flippedData=aisFlipBytes(ubits(1:328));
                        cs=aisDecodeMsg19(flippedData);
                        validCRC=1;
                    else
                        validCRC=0;
                    end
                    reset(crcGen);
                else
                    validCRC=0;
                end
            case 21
                if length(ubits)>=288
                    checkSum = step(crcGen,ubits(1:272));
                    if isequal(checkSum(273:288),ubits(273:288))
                        flippedData=aisFlipBytes(ubits(1:288));
                        cs=aisDecodeMsg21(flippedData);
                        validCRC=1;
                    else
                        validCRC=0;
                    end
                    reset(crcGen);
                else
                    validCRC=0;
                end
            otherwise
                disp('Message Checksum Failed');
                validCRC=0;
        end
        
        if validCRC==1
            if msgType==1 || msgType==2 || msgType==3
                if logFlag
                    fprintf(fileID,'%s  %s  %s  Altitude:0  %s  %s\n',cs{3},cs{8},cs{9}, bitsToHex(flippedData(1:184)), datestr(datetime('now')));
                end
                fprintf('%s  %s  %s  %s  %s\n',cs{3}, cs{9}, cs{8}, bitsToHex(flippedData(1:184)), datestr(datetime('now')));
            elseif msgType==5
                if logFlag
                  fprintf(fileID,'%s  %s  %s  %s  %s  %s  %s  %s\n',cs{3}, cs{6}, cs{7}, cs{8}, cs{9}, cs{13}, bitsToHex(flippedData(1:440)), datestr(datetime('now')));
                end
                fprintf('%s  %s  %s  %s  %s  %s  %s  %s\n',cs{3}, cs{6}, cs{7}, cs{8}, cs{9}, cs{13}, bitsToHex(flippedData(1:440)), datestr(datetime('now')));
            elseif msgType==18
                if logFlag
                    fprintf(fileID,'%s  %s  %s  Altitude:0  %s  %s\n',cs{3},cs{5},cs{6}, bitsToHex(flippedData(1:184)), datestr(datetime('now')));
                end
                fprintf('%s  %s  %s  %s  %s\n',cs{3}, cs{6}, cs{5}, bitsToHex(flippedData(1:184)), datestr(datetime('now')));
            elseif msgType==21
                if logFlag
                    fprintf(fileID,'%s  %s  %s  Altitude:0  %s  %s\n',cs{3},cs{7},cs{8}, bitsToHex(flippedData(1:288)), datestr(datetime('now')));
                end
                fprintf('%s  %s  %s  %s  %s\n',cs{3}, cs{8}, cs{7}, bitsToHex(flippedData(1:288)), datestr(datetime('now')));
            end
        end
        
        % Remove signal from data set
        
        
        ok_data=[ok_data;data(aisIdx(1):aisIdx(2))];
        data(aisIdx(1):aisIdx(2))=zeros(aisIdx(2)-aisIdx(1)+1,1);
        
        
%         remove_signal=aisRemoveMsg1(flippedData(1:168),samplesPerSymbol);
%         idxStart=idxStart-1;
%         
%         test=data(aisIdx(1):aisIdx(2));
%         r=xcorr(test,remove_signal);
%         idx_r=aisIdx(1)+find(max(abs(r))==abs(r))-length(test)-1;
%         data(idx_r+1:idx_r+size(remove_signal))=data(idx_r+1:idx_r+size(remove_signal))-max(r)/length(remove_signal)*remove_signal;
        
%         +idxStart+1:aisIdx(1)+idxStart+size(remove_signal))-remove_signal;
%         figure;plot(abs(test))

        
%         data(aisIdx(1)+idxStart+1:aisIdx(1)+idxStart+size(remove_signal))=data(aisIdx(1)+idxStart+1:aisIdx(1)+idxStart+size(remove_signal))-remove_signal;
%         data=[data(1:aisIdx(1));data(aisIdx(2):end)];
        
%        validCRC=0; 
    end
end

toc

% buffer_sequence= randi([0 1],24,1);
% signal=logical([zero_sequence;training_sequence;start_flag;checkSum;end_flag;buffer_sequence]);
% figure;plot(abits)
% hold on
% plot(signal)

% figure;plot(signal-abits);

fclose('all');

figure;hold on
map=imread('../land_ocean_ice_8192.png');

image(map,'XData',[-180 180],'YData',[90 -90])
if ship.speed<1.
    plot(ship.Long,ship.Lat,'r*');
else
    quiver(ship.Long,ship.Lat,ship.speed/100*cos(ship.course*pi/180),ship.speed/100*sin(ship.course*pi/180), 'r');
end
    
% % BlueMarbleURL =  'http://neowms.sci.gsfc.nasa.gov/wms/wms?SERVICE=WMS&LAYERS=BlueMarbleNG&EXCEPTIONS=application/vnd.ogc.se_xml&FORMAT=image/jpeg&TRANSPARENT=FALSE&HEIGHT=10800&BGCOLOR=0xFFFFFF&REQUEST=GetMap&WIDTH=21600&BBOX=-180.0,-90.0,180.0,90.0&STYLES=&SRS=EPSG:4326&VERSION=1.1.1';
% % % A is the image, and R is the raster reference, "grid translation" I guess.
% % [A, R] = wmsread(BlueMarbleURL);
% 
% load('map.mat');
% axesm('mercator', 'MapLatLimit', [30 45], 'MapLonLimit', [130 145])
% Will remove axis-constrained background
% axis off;
% Plot blue marble.
% geoshow(A, R);
% 
% ship=geopoint(40.67,139.55);
% ship.Metadata.FeatureType='waypoint';
% geoshow(ship.Latitude, ship.Longitude);

% plot(abs(signal_gmsk-remove_signal))
