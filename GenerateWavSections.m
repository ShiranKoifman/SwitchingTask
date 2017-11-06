function [nSections, wavSections]=GenerateWavSections(MaskerFile, MaxDurTargetSamples)

[nz, Fn] = audioread(MaskerFile);
nz_samples=length(nz);

% choose a random starting point within the first section of the masker
starts = floor((MaxDurTargetSamples)*rand);

while (starts(end)+2*MaxDurTargetSamples)<nz_samples
    starts = [starts starts(end)+MaxDurTargetSamples];
end

nSections=length(starts);
wavSections=starts(randperm(nSections));

