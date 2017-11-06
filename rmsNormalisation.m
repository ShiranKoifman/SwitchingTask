function [Target, Masker]=rmsNormalisation(Target, Masker, SNR, fixed, out_rms)

%% set appropriate levels for signal and masker, on the basis of their entire durations
% Assume for the moment that outRMS is set and that this level should be
% applied to the signal or noise separately, depending upon the 'fixed' sound.
% Therefore, the total level will be higher but even at a duty cycle=1, 
% the level will be that in one ear

%% Level adjustment
% calculate the multiplicative factor for the signal-to-noise ratio
snr = 10^(SNR/20);

% Calculate the rms levels of the signal and noise
rmsT = rms(Target); 
if ~strcmp(Masker,'none')
    rmsM = rms(Masker); 
end

% scale the sounds
if strcmp(fixed, 'target') % fix the signal level and scale the noise
    normTarget = Target * out_rms/rmsT;
    if ~strcmp(Masker,'none') % check if a masker file was indeed selected
        %normMasker = Masker * out_rms/(rmsM * snr); % because now rms(signal)=out_rms % wrong!
        normMasker = Masker * (snr*out_rms)/rmsM; % because now rms(signal)=out_rms
    end
elseif strcmp(fixed, 'masker') % fix the noise level and scale the signal
    normTarget = Target * (snr*out_rms)/rmsT; % because now rms(masker)=out_rms
    if ~strcmp(Masker,'none') % check if a masker file was indeed selected
        normMasker = Masker * out_rms/rmsM; 
    end
else
    error('Fixed wave must be signal or noise.');
end
% check here for overloads
% do something if clipping occurs
[Target, correction] = no_clip(normTarget);
if correction<-5 % allow a maximum of 5 dB attenuation
    error('Target attenuated by too much');
end
if correction<0 % attenuate the masker too
    Target = normTarget * 10^(correction/20);
end

if ~strcmp(Masker,'none')
    [Masker, correction] = no_clip(normMasker);
    if correction<-5 % allow a maximum of 5 dB attenuation
        error('Masker attenuated by too much');
    end
    if correction<0 % attenuate the masker too
        Masker = normMasker * 10^(correction/20);
    end
end
end