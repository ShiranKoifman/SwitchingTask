function [Target, Masker]=rmsNormalisation(Target, Masker, SNR, fixed, in_rms, out_rms, warningS)

%% set appropriate levels for signal and masker, on the basis of their entire durations
% Assume for the moment that outRMS is set and that this level should be
% applied to the signal or noise separately, depending upon the 'fixed' sound.
% Therefore, the total level will be higher but even at a duty cycle=1, 
% the level will be that in one ear

%% Level adjustment
% calculate the multiplicative factor for the signal-to-noise ratio
snr = 10^(SNR/20);

% Calculate the rms levels of the target and masker
rmsT = rms(Target);
normTarget = Target/rmsT;
if ~strcmp(Masker,'none')
    rmsM = rms(Masker);
    normMasker = Masker/rmsM;
end

% if in_rms is not predefined adjust all signal rms to target or masker rms
if  in_rms == 0 && strcmp(fixed, 'target');  
    in_rms = rmsT; 
elseif in_rms == 0 && strcmp(fixed, 'masker');  
    in_rms = rmsM;  
end

% Applying in_rms to T and M
Target = normTarget * in_rms;
if ~strcmp(Masker,'none')
    Masker = normMasker * in_rms;
end

% Applying current SNR
if strcmp(fixed, 'target') && ~strcmp(Masker,'none')
     Masker = Masker / snr;
elseif strcmp(fixed, 'masker') && ~strcmp(Target,'none') 
     Target = Target * snr; 
end

% generate T or T+M
if ~strcmp(Target,'none') && strcmp(Masker,'none')
        Signal = Target;
elseif ~strcmp(Target,'none') && ~strcmp(Masker,'none')
        Signal = Target + Masker;
end  

% Calculate rms level of combined target + masker/s
if (out_rms>0) 
        rms_total = max(rms(Signal)); % Scale total to obtain desired rms
        Signal = Signal * out_rms/rms_total;
end

% Check output signal for clipping 
[Signal_noclip, correction] = no_clip(Signal);
TotalSignal = Signal_noclip;
end