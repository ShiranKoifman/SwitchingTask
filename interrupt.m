function [TotalSignal, OutLevelChange]=interrupt(rate, duty, riseFall, Target, Masker, SampFreq, SNR, fixed, in_rms, out_rms, warningS,InterruptedFilesOut)

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
    if length(Masker)>length(Target)+warningS
        Target=[Target zeros(length(Masker)-length(Target)+warningS,1)];
    elseif length(Target)>length(Masker)
        error('Signal cannot be longer than masker');
    end
end

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
TargetCycle=[s; zeros(nOff,1)];

if ~strcmp(Masker,'none')
    % generate noise modulation, with noise initially 'on'
    %nOnMasker=(nPeriod-round(duty*nPeriod))+nRise; % $$ commented out SK 06.07.2017
    nOnMasker=round(duty*nPeriod)+nRise;
    nOffMasker=nPeriod-nOnMasker;
    % function s=NewTaper(wave, rise, fall, SampFreq,type)
    s=TaperInSamples(ones(nOnMasker,1), nRise, nRise);
    MaskerCycleTmp=[s; zeros(nOffMasker,1)];
    % offset noise cycle so as to start mid-way through the off-ramp of the
    % noise modulator
    MaskerCycle=zeros(size(TargetCycle));
    MaskerCycle(1:length(MaskerCycle)-(nOnMasker-nRise)+1)=MaskerCycleTmp(nOnMasker-nRise:end);
    MaskerCycle(length(MaskerCycle)-(nOnMasker-nRise)+2:end)=MaskerCycleTmp(1:nOnMasker-nRise-1);
end
% plot the single cycle
% plot([0:length(TargetCycle)-1],TargetCycle,[0:length(TargetCycle)-1],MaskerCycle)

% string together whole cycles to a duration about twice as long as the masker
if ~strcmp(Masker,'none')
    while length(TargetCycle)<2*length(Masker)
        TargetCycle=[TargetCycle; TargetCycle];
        MaskerCycle=[MaskerCycle; MaskerCycle];
        
        % plot a long thing
        % figure; plot([0:length(TargetCycle)-1],TargetCycle,[0:length(TargetCycle)-1],MaskerCycle)
    end
else % if no masker was selected
    while length(TargetCycle)<2*length(Target)
    TargetCycle=[TargetCycle; TargetCycle];
    end
end


% randomise the phase by selecting a starting point in the cycle
% with a uniform distribution
RandomStart=floor(rand()*nPeriod)+1;

% apply the modulating envelope to both target and masker (separately)
if duty == 1 % enable duty cycle of 1, i.e. no interruption
    TargetMod = Target;
    if ~strcmp(Masker,'none')
       MaskerMod = Masker; 
    else
        MaskerMod = zeros(size(TargetMod));
    end
else % if duty cycle < 1, apply modulation envelope
        TargetMod = Target .* TargetCycle(1+RandomStart:length(Target)+RandomStart);
        % ensure onsets and offsets also ramped
        TargetMod = TaperInSamples(TargetMod, nRise, nRise);
        if ~strcmp(Masker,'none')
            MaskerMod = Masker .* MaskerCycle(1+RandomStart:length(Masker)+RandomStart);
            % ensure onsets and offsets also ramped
            MaskerMod = TaperInSamples(MaskerMod, nRise, nRise);
        else
            MaskerMod = zeros(size(TargetMod));
        end
end

% combin channels
if ~strcmp(Masker,'none')
    TotalSignal = [TargetMod + MaskerMod];
else
    TotalSignal = [TargetMod];
end

OutLevelChange=0; % needs deleting later 


% plot the current stare of the two waves
%plot([0:length(TargetMod)-1],Target,[0:length(TargetMod)-1],MaskerMod)

% function [sig, correction] = SimpleAddWavs(TargetMod, MaskerMod, snr, fixed, in_rms, out_rms)

% $$$$$ SK 09.10.17 rmsNormalisation was implemented instead before
% applying interruptions
% % % % [wav, OutLevelChange] = SimpleAddWavs(TargetMod, MaskerMod, snr, fixed, in_rms, out_rms, Target, warningS);
% % % % % ensure onsets and offsets also ramped
% % % % wav=TaperInSamples(wav, nRise, nRise);

% plot(wav)
% sound(wav, SampFreq)

%% write out modulating envelopes if a flag is set
if InterruptedFilesOut
    EnvTarget=.8*TaperInSamples(TargetCycle(1+RandomStart:length(Target)+RandomStart), nRise, nRise);
    if ~strcmp(Masker,'none')
        EnvMasker=.8*TaperInSamples(MaskerCycle(1+RandomStart:length(Masker)+RandomStart), nRise, nRise);
        audiowrite('CurrentModulators.wav', [EnvTarget, EnvMasker], SampFreq);
        % plot the two modulators on top of one another
        % t=(0:length(EnvTarget)-1)/SampFreq;  plot(t,EnvTarget,t,EnvMasker)
    else
        audiowrite('CurrentModulators.wav', EnvTarget, SampFreq);
        % plot the two modulators on top of one another
        % t=(0:length(EnvTarget)-1)/SampFreq;  plot(t,EnvTarget)
    end
end

function samples = samplify(duration, SampFreq)
samples = round(SampFreq*(duration/1000));


    
