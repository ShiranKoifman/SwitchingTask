% function [x, Fs, OutLevelChange]=interruptWave(SignalWav, NoiseWav, rate, duty, RiseFall, snr, outRMS)
clear all

SignalWav='ASLQ0104.WAV';
NoiseWav='00Fx.wav';
rate=4;
duty=.3;
RiseFall=5;
snr=0;
outRMS=.02;

% function [x, Fs, OutLevelChange]=interruptWave(SignalWav, NoiseWav, rate, duty, RiseFall, snr, outRMS, InterruptedFilesOut)

[x, Fs, OutLevelChange]=interruptWave(SignalWav, NoiseWav, rate, duty, RiseFall, snr, outRMS, 1);
audiowrite('ModulatedWave.wav',x,Fs);