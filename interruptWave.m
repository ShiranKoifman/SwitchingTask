function [x, Fs, OutLevelChange]=interruptWave(SignalWav, NoiseWav, rate, duty, RiseFall, snr, outRMS, InterruptedFilesOut)

%	'SignalWav' - the name of a .wav file containing the signal or target
%	'NoiseWav' - the name of a .wav file containing the noise (must be longer in duration than signal)
%	snr - signal-to-noise ratio at which to combine the waveforms
%	duration - (ms) of final waveform. If 0, the signal duration is used
%  fixed - 'noise' or 'signal' to be fixed in level at level specified by in_rms
%  in_rms - if 0, level of signal or noise left unchanged
%  out_rms - rms output of final combined wave. Signal unchanged if rms=0
%		(Note! rms values are calculated Matlab style with waveform values assumed to 
%		be in the range +/- 1)
%
%   Version 2.0 -- allow duty cycle = 1 (uninterrupted)

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

% function wav=interrupt(rate, duty, riseFall, signal, masker, SampFreq, snr, fixed, outRMS)
if snr>60
    fixed='signal';
else
    fixed='noise';
end

% $$ add here the WaveStart parameter!!!!!!!!!!!!!! SK 06.07.2017

if duty==1
    x=sig;
    OutLevelChange=0;
else
    if ~strcmp(NoiseWav,'none')
        [x, OutLevelChange]=interrupt(rate, duty, RiseFall, sig, nz(1:length(sig)), Fs, snr, fixed, outRMS, InterruptedFilesOut);
    else % for presentation in quiet (NoiseWave='none')
        [x, OutLevelChange]=interrupt(rate, duty, RiseFall, sig, NoiseWav, Fs, snr, fixed, outRMS, InterruptedFilesOut);
    end
end



