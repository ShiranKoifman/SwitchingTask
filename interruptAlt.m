function [TotalSignal, OutLevelChange]=interruptAlt(rate, duty, riseFall, Target, Masker, SampFreq, SNR, fixed, in_rms, out_rms, warningS, InterruptedFilesOut)

% this one goes across ears
%
% allow masker and carrier to be unequal in duration, but extend the
% signal to the length of the masker, if the masker is longer
%
% Do not extend the masker, but throw an error if the signal is longer
%
% rate -- (Hz)
% duty -- ranging from 0->1
% riseFall -- (ms)
%
% Version 2.0 -- September 2013
%   pass original signal to SimpleAddWavs

InitialRise=30;     % minimise onset transition for signal 
                    % when a preliminary period of silence is added

if ~strcmp(Masker,'none')
    if length(Masker)>length(Target)+warningS % allowing for initial burst of masker
        Target=[Target zeros(length(Masker)-length(Target)+warningS,1)];
    elseif length(Target)>length(Masker)
        error('Target cannot be longer than masker');
    end
end

%% set appropriate levels for signal and masker, on the basis of their entire durations
% Assume for the moment that outRMS is set and that this level should be
% applied to the signal or noise separately, depending upon the 'fixed' sound.
% Therefore, the total level will be higher but even at a duty cycle=1, 
% the level will be that in one ear

%% Calculate the rms levels of the signal and noise
[Target, Masker] = rmsNormalisation(Target, Masker, SNR, fixed, out_rms);

%% taper target onset and add warningS duration if masker was selected
% taper the onset for a smooth transition
% function s=NewTaper(wave, rise, fall, SampFreq, type)
Target = NewTaper(Target, InitialRise, 0, SampFreq);
if ~strcmp(Masker,'none')
    % now add a period of silence preceding the target
    Target = [zeros(warningS,1);Target];
end

%% add modulations
% generate a single cycle of the modulating envelope,
% turning signal on at its onset (at least initially)
period=1000/rate;
nRise=samplify(riseFall, SampFreq);

% ensure nRise is an even number so can be split
if mod(nRise,2)~=0
    nRise=nRise+1;
end

nPeriod=samplify(period, SampFreq);
nOn=round(duty*nPeriod)+nRise;
nOff=nPeriod-nOn;
% function s=NewTaper(wave, rise, fall, SampFreq,type)
s=TaperInSamples(ones(nOn,1), nRise, nRise);
LCycle=[s; zeros(nOff+nPeriod,1)];
RCycle=[ zeros(nPeriod,1); s; zeros(nOff,1)];
%figure; plot(1000*[0:length(LCycle)-1]/SampFreq,LCycle,1000*[0:length(RCycle)-1]/SampFreq,RCycle)

% string together whole cycles to a duration about twice as long as the masker
LtarCycle=[];
RtarCycle=[];

if ~strcmp(Masker,'none')
    while length(LtarCycle)<2*length(Masker)
        LtarCycle=[LtarCycle; LCycle];
        RtarCycle=[RtarCycle; RCycle];
    end
else % if no masker was selected
    while length(LtarCycle)<2*length(Target)
    LtarCycle=[LtarCycle; LCycle];
    RtarCycle=[RtarCycle; RCycle];
    end
end
% plot a long thing
%offset=0;
%figure; plot(1000*[0:length(LtarCycle)-1]/SampFreq,LtarCycle,1000*[0:length(RtarCycle)-1]/SampFreq,RtarCycle+offset)

% randomise the phase by selecting a starting point in the cycle
% with a uniform distribution
RandomStart=floor(rand()*2*nPeriod)+1;

% One pair of envelopes is applied to the signal, and then the flipped
% versions are applied to the masker.

% apply the modulating envelope to the target
Ltar = Target .* LtarCycle(1+RandomStart:length(Target)+RandomStart);  %Target left channel with Cycles Left channel
Rtar = Target .* RtarCycle(1+RandomStart:length(Target)+RandomStart);  %Target right channel with Cycles right channel
% ensure onsets and offsets also ramped
Ltar=TaperInSamples(Ltar, nRise, nRise); 
Rtar=TaperInSamples(Rtar, nRise, nRise);

% apply the modulating envelope to the masker (flipped cycles!)
if ~strcmp(Masker,'none') 
    Rmsk = Masker .* LtarCycle(1+RandomStart:length(Target)+RandomStart); %Masker right channel with Cycles Left channel
    Lmsk = Masker .* RtarCycle(1+RandomStart:length(Target)+RandomStart); %Masker left channel with Cycles right channel
    % ensure onsets and offsets also ramped
    Lmsk=TaperInSamples(Lmsk, nRise, nRise);
    Rmsk=TaperInSamples(Rmsk, nRise, nRise);
    % add T & M together (channel-wise)
    TotalSignal = [Ltar+Lmsk, Rtar+Rmsk];
else % if no masker was selected, combine target channels only
    TotalSignal = [Ltar,Rtar];
end
% plot the current stare of the two waves
%plot([0:length(Target)-1],Target,[0:length(Target)-1],Masker)

% % function [sig, correction] = SimpleAddWavs(sig, noise, snr, fixed, in_rms, out_rms)
% in_rms=0;
% [wav, OutLevelChange] = SimpleAddWavs(sig, nz, snr, fixed, in_rms, outRMS, signal);
OutLevelChange=0; % needs deleting later

%plot(TotalSignal)
%sound(TotalSignal, SampFreq)

%% write out modulating envelopes if a flag is set
if InterruptedFilesOut
    EnvL=.8*TaperInSamples(LtarCycle(1+RandomStart:length(Target)+RandomStart), nRise, nRise);
    EnvR=.8*TaperInSamples(RtarCycle(1+RandomStart:length(Target)+RandomStart), nRise, nRise);
    audiowrite('CurrentModulators.wav', [EnvL, EnvR], SampFreq);
    % plot the two modulators on top of one another
    %  t=(0:length(EnvL)-1)/SampFreq;  plot(t,EnvL,t,EnvR)
end

function samples = samplify(duration, SampFreq)
samples = round(SampFreq*(duration/1000));


    
