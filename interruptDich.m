function [TotalSignal, OutLevelChange]=interruptDich(rate, duty, riseFall, Target, Masker, SampFreq, SNR, fixed, in_rms, out_rms, warningS, InterruptedFilesOut)

% this one keeps target and masker within ears
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
Cycle=[s; zeros(nOff,1)];
% figure; plot(1000*[0:length(Cycle)-1]/SampFreq,Cycle)

% string together whole cycles to a duration about twice as long as the masker
TargetCycle=[];
if ~strcmp(Masker,'none')
    while length(TargetCycle)<2*length(Masker)
            TargetCycle=[TargetCycle; Cycle];
    end
else
    while length(TargetCycle)<2*length(Target)
            TargetCycle=[TargetCycle; Cycle];
    end
end

% plot a long thing
%offset=0;
%figure; plot(1000*[0:length(TargetCycle)-1]/SampFreq,TargetCycle)

% randomise the phase by selecting a starting point in the cycle
% with a uniform distribution
RandomStart=floor(rand()*2*nPeriod)+1;

% apply the modulating envelope to both target and masker (separately) 
if duty == 1 % enable duty cycle of 1, i.e. no interruption
    Ltar = Target;
    if ~strcmp(Masker,'none')
        Rmsk = Masker;
    else % in case no masker was selected
        Rmsk = zeros(size(Ltar));
    end
else
    % apply the modulating envelope to the Target and put into L channel
    Ltar = Target .* TargetCycle(1+RandomStart:length(Target)+RandomStart);
    % ensure onsets and offsets also ramped
    Ltar=TaperInSamples(Ltar, nRise, nRise);
    
    % apply the modulating envelope to the Masker and put into R channel
    Rmsk = Masker .* TargetCycle(1+RandomStart:length(Target)+RandomStart);
    % ensure onsets and offsets also ramped
    Rmsk=TaperInSamples(Rmsk, nRise, nRise);
end

% wavplay(Ltar,SampFreq)

% combin channels
TotalSignal = [Ltar, Rmsk];

% plot the current stare of the two waves
%plot([0:length(Target)-1],Ltar,[0:length(Target)-1],Rmsk)

% % function [sig, correction] = SimpleAddWavs(sig, noise, snr, fixed, in_rms, out_rms)
% in_rms=0;
% [wav, OutLevelChange] = SimpleAddWavs(sig, nz, snr, fixed, in_rms, outRMS, signal);
OutLevelChange=0; % needs deleting later

% plot(TotalSignal)
%sound(TotalSignal, SampFreq)

%% write out modulating envelopes if a flag is set
if InterruptedFilesOut
    EnvL=.8*TaperInSamples(TargetCycle(1+RandomStart:length(Target)+RandomStart), nRise, nRise);
    EnvR=.8*TaperInSamples(TargetCycle(1+RandomStart:length(Target)+RandomStart), nRise, nRise);
    %wavwrite([EL, ER], SampFreq, 'CurrentModulators');
    audiowrite('CurrentModulators.wav', [EnvL, EnvR], SampFreq);
    % plot the two modulators on top of one another
    %t=(0:length(Esig)-1)/SampFreq;  
    %plot(t,EnvL,t,EnvR)
end

function samples = samplify(duration, SampFreq)
samples = round(SampFreq*(duration/1000));


    
