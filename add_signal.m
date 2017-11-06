function [TogalSignal, Fs, OutLevelChange]=add_signal(TargetWav, MaskerWav, ...
    rate, duty, RiseFall, snr, in_rms, out_rms, warning_noise_duration, ...
    InterruptedFilesOut, ear, MaskerWavStart, fixed)
%
% Function
% Generation of mixed target and/or noise signal with:
%    - interruption rate (controlled by the amount of duty cycle [parameter 'duty']), 
%    - and alternation between the ears (with modulation rate=5ms [parameter 'rate'])
% 
% Version 2.0 -- allow duty cycle = 1 (uninterrupted)
%
% Input
%	'SignalWav':                the name of a .wav file containing the signal or target
%	'NoiseWav':                 the name of a .wav file containing the noise (must be longer in duration than signal)
%   'rate':                     modulation rate in ms
%   'duty':                     The first duty cycle level change [0.9]
%   'RiseFall':                 rise/fall time in ms [5 ms]
%	'snr':                      SNR between target and noise levels
%   'in_rms':                   predefined rms value for target and combined masker
%   'out_rms':                  predefined rms value for the function's overall output signal
%                               (Note! rms values are calculated Matlab style with waveform values assumed to 
%                               be in the range +/- 1)
%   'warning_noise_duration':   time (ms) between masker/s and target beginning
%   'InterruptedFilesOut':      Saves output waves [1='on', 0='off]
%   'ear':                      'A'= Alternating between the ears; 'M'= Mixed ;
%                               'D'== Dichotic (noise played in Left/Right ear only)
%   'MaskerWavStart':           pseudo-randomised starting value for the noise file
%   'fixed':                    fixed signal sound level: 'target'/'noise'
% ------------------------------------------------------------------------%
% Output
%   x:                          total mixed signal
%   Fs:                         sampling frequency
%   OutLevelChange:             overall level correction to aviod clipping
%

[Target, Fs] = audioread(ensureWavExtension(TargetWav));
% check if stereo -- if so, take only one channel
n=size(Target);
if n(2)>1
     Target = Target(:,1);
end

if ~strcmp(MaskerWav,'none')
    [Masker, Fn] = audioread(ensureWavExtension(MaskerWav));
    if Fs~=Fn,
        error('The sampling rate of the noise and signal waveforms must be equal.');
    end 
end

% duration of 'warning_noise_duration' in samples
warningS = samplify(warning_noise_duration, Fs); 

if ~strcmp(MaskerWav,'none')
    % select masker interval
    MaskerSegmented = Masker(MaskerWavStart:MaskerWavStart+warningS+length(Target)-1);
else % if masker='none'
    MaskerSegmented=MaskerWav;
end

%$$$$ commented out by SK 09.10.17 --> was implemented in interruptedDich() & interrupted()
% % % % if duty==1 %enable duty cycle of 1, i.e. no interruption
% % % %     %TogalSignal=Target;
% % % %     OutLevelChange=0;
% % % %     [Target, Masker] = rmsNormalisation(Target, MaskerSegmented, snr, fixed, out_rms, warningS);
% % % %  
% % % %     if ~strcmp(Masker,'none')
% % % %         TogalSignal = [Target, Masker];
% % % %     else
% % % %          ContraNoise=zeros(size(Target));
% % % %          TogalSignal = [Target, ContraNoise];
% % % %     end
% % % % elseif ear== 'A' || ear=='M' 

if ear== 'A' || ear=='M' 
    % change from original interruptWave -- pick random section of noise
    [TogalSignal, OutLevelChange]=interruptAlt(rate, duty, RiseFall, Target, ...
        MaskerSegmented, Fs, snr, fixed, in_rms, out_rms, warningS, InterruptedFilesOut);

elseif ear=='l' || ear=='r' % l=Dichotic Left, i.e. target is presented only in the left ear, masker in the right ear
                            % r=Dichotic right, i.e. target is presented only in the right ear, masker in the left ear 
    [TogalSignal, OutLevelChange]=interruptDich(rate, duty, RiseFall, Target, ...
    MaskerSegmented, Fs, snr, fixed, in_rms, out_rms, warningS, InterruptedFilesOut);

elseif ear=='B' || ear=='L' || ear=='R' % interruption only
                                        % B=interrupted in both ears;
                                        % L=interrupted only in left ear;
                                        % R=interrupted only in right ear
     [TogalSignal, OutLevelChange]=interrupt(rate, duty, RiseFall, Target, MaskerSegmented, Fs, snr, fixed, in_rms, out_rms, warningS, InterruptedFilesOut);

end

if ear=='M' % add two channels together
    TogalSignal(:,1)=sum(TogalSignal,2);
    TogalSignal(:,2)=TogalSignal(:,1);
end