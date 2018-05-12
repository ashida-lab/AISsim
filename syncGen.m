function syncIdeal = syncGen(samplesPerSymbol)
% Generate ideal AIS sync waveform

% Copyright 2016, The MathWorks, Inc.

% Set up training sequence
tr1=logical([1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0]);

% Set up GMSK Modulator
mod=comm.GMSKModulator;
mod.BandwidthTimeProduct=.3;
mod.SamplesPerSymbol=samplesPerSymbol;
mod.BitInput=true;
mod.PulseLength=3;
mod.SymbolPrehistory=[1 -1];

% Apply NRZI encoding
for ii=2:length(tr1)
    if tr1(ii)==1
        tr1(ii)=tr1(ii-1);
    else
        tr1(ii)=~tr1(ii-1);
    end
end

% Generate GMSK waveform for training sequence
syncIdeal = step(mod,tr1');

