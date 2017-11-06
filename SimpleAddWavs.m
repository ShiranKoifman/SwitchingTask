function [TotalSignal, correction] = SimpleAddWavs(Target, Masker, SNR, fixed, in_rms, out_rms, OrigTarget, warningS)
%
%   Version 8.1 [SK July, 2017]
%  (see versions details at the end)
%
%
%% Level adjustment
% calculate the multiplicative factor for the signal-to-noise ratio
snr = 10^(SNR/20);

% RMS values of central part of the signals 
if ~strcmp(Target,'none')
    if ~strcmp(Masker,'none')
        OrigTarget = OrigTarget(warningS+1:end); % original signal without the zeros if warningS is applied
    else
        OrigTarget = OrigTarget;
    end
    rmsT = rms(OrigTarget);
    normTarget = Target/rmsT; 
end
if ~strcmp(Masker,'none')
    OrigMasker = Masker(warningS+1:end);
    rmsM = rms(OrigMasker);
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

% generate T, T+M
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

% See if entire output waveform should be scaled to a particular rms
if (out_rms>0)
    if SNR>60
        rms_total = max(rms(OrigTarget));
        % Scale total to obtain desired rms
        Signal = Signal * out_rms/rms_total;
    else
        % Calculate rms level of combined signal+noise
        rms_total = max(rms(Signal));
        % Scale total to obtain desired rms
        Signal = Signal * out_rms/rms_total;
    end
end

% do something if clipping occurs
[TotalSignal, correction] = no_clip(Signal);
if correction<-15 % allow a maximum of 15 dB attenuation
   error('Output signal attenuated by too much.');
end

end

%%----------------------------------------------------------------------------------------------------------------------
%
%%----------------------------------------------------------------------------------------------------------------------
%                                                                 1         2             3
% function [sig, Fs, start, SigAlone, NoiseAlone] = add_noise(SignalWav, NoiseWav, MaskerWavStart, ...
%                 snr, duration, fixed, in_rms, out_rms, warning_noise_duration, NoiseRiseFall, HRIRmatFile, Azimuths)
%                  4       5       6       7       8              9                  10             11          12
%
% 	Combine a noise and signal waveform at an arbitrary signal-to-noise ratio
%   Return the wave
%	The level of the signal or noise can be fixed, and the output level can be normalised
%
%  'SignalWav' - the signal or target
%  'NoiseWav' - the noise
%  snr - signal-to-noise ratio at which to combine the waveforms
%  fixed - 'noise' or 'signal' to be fixed in level at level specified by in_rms
%  in_rms - if 0, level of signal or noise left unchanged
%  out_rms - rms output of final combined wave. Signal unchanged if rms=0
%		(Note! rms values are calculated Matlab style with waveform values assumed to
%		be in the range +/- 1)
%
% Version 2.0 -- December 2001: modified from combine.m (December 1999) Isaac
% Version 2.1 -- protect against stereo waveforms, taking only one channel (December 2002)
% Version 3.0 -- lengthen signal so as to account for rise/fall times on noise wave
% Version 3.1 -- allow 10 dB attenuation, instead of 5.
% Version 3.2 -- allow longer start time of noise to be specified
% Version 4.0 -- restrict calculation of SNR to original duration of signal wave
%               (older versions included total length with added warning
%               silences) June 2003
% Version 5.0 -- allow specification of which part of the noise wave is selected
% Version 6.0 -- enable threshold determination for waves in silence
% Version 6.1 -- output noise alone, as well as signal alone: April 2009
% Version 7.0 -- enable use of stereo waveforms, for binaural presentations
%       if the target is a stereo file, then a stereo masker file must also
%       be specified. Binaural signals not fully implemented! OK until line
%       130
% Version 7.1 -- add NoiseRiseFall to args
%                   add correction of output level (if necessary to avoid
%                   overloads) to output args, and eliminate breaking out
%                   if a maximum degree of attenutation is breached
% Version 8.0 -- with special reference to interrupted speech in quiet
%                   change the way in which the overall level is scaled
%                   when SNR>60, in which case scale with reference to
%                   original signal
% Version 8.1 -- Enable to apply in_rms when target is fixed. 
%                If in_rms is not predefined than it is equal to the target/masker rms 
%                (depending on which signal is fixed).                   
%
%
%  Modified from add_noise.m July 2010 (February 2010 version 7.1)
%  assume noise and signal are already the same length
% Stuart Rosen stuart@phon.ucl.ac.uk

