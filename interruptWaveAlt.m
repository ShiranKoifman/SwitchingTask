function [x, Fs, OutLevelChange]=interruptWaveAlt(SignalWav, NoiseWav, ...
    rate, duty, RiseFall, snr, outRMS, warning_noise_duration, ...
    InterruptedFilesOut, ear, MaskerWavStart)
%
% Function
% Generation of mixed target and/or noise signal with interruption rate
% (controlled by the amount of duty cycle [parameter 'duty']), and with
% alternation between the ears (with modulation reate=5ms [parameter 'rate'])
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
%	'out_rms':                  defined rms value for the function's overall output signal. Signal unchanged if rms=0
%                               (Note! rms values are calculated Matlab style with waveform values assumed to 
%                               be in the range +/- 1)
%   'warning_noise_duration':   time (ms) between masker/s and target beginning
%   'InterruptedFilesOut':      Saves output waves [1='on', 0='off]
%   'ear':                      'A'= Alternating between the ears; 'M'= Mixed ;
%                               'D'== Dichotic (noise played in Left/Right ear only)
%   'MaskerWavStart':           pseudo-randomised starting value for the noise file
% Output
%   x:              total mixed signal
%   Fs:             sampling frequency
%   OutLevelChange: overal level correction to aviod clipping

[sig, Fs] = audioread(ensureWavExtension(SignalWav));
% check if stereo -- if so, take only one channel
n=size(sig);
if n(2)>1
     sig = sig(:,1);
end

if ~strcmp(NoiseWav,'none')
    [nz, Fn] = audioread(ensureWavExtension(NoiseWav));
    if Fs~=Fn,
        error('The sampling rate of the noise and signal waveforms must be equal.');
    end
end

% $$ to delete? 
% function wav=interrupt(rate, duty, riseFall, signal, masker, SampFreq, snr, fixed, outRMS)
% if snr>60
%     fixed='signal';
% else
%     fixed='noise';
% end
fixed='signal';

if ~strcmp(NoiseWav,'none')
warningS = samplify(warning_noise_duration, Fs); % duration of 'warning_noise_duration' in samples
nzStart = MaskerWavStart % $$$$ SK 06.07.2017
%nzStart = round(rand()*(length(nz)-(length(sig)+1+warningS)))
end

if duty==1
    x=sig;
    OutLevelChange=0;
    % Problem here! There is no noise
elseif ear== 'A' || ear=='M' 
    % change from original interruptWave -- pick random section of noise
    [x, OutLevelChange]=interruptAlt(rate, duty, RiseFall, sig, ...
        nz(nzStart:nzStart+warningS+length(sig)-1), Fs, snr, fixed, outRMS, warningS, InterruptedFilesOut);
else % ear=='D'
    [x, OutLevelChange]=interruptDich(rate, duty, RiseFall, sig, ...
        nz(nzStart:nzStart+warningS+length(sig)-1), Fs, snr, fixed, outRMS, warningS, InterruptedFilesOut);    
end

if ear=='M' % add two channels together
    x(:,1)=sum(x,2);
    x(:,2)=x(:,1);
end


