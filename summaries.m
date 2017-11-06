function summaries(InputDir, ExcelOutput, NameDirInFile)

%	Calculate various summary statistics 
%   for all the wav files in a single directory
%   Usage: summaries(InputDir, ExcelOutput)
%       ExcelOutput = name of Excel output file; default to screen
%       NameDirInFile = 0 for nothing and 1 for input directory to be output
%
%   Version 4.0: Dec 2007
%       allow option of input directory name in Excel output
%   Version 3.0: Dec 2007
%       allow option of Excel output
%       modify column headings for legal SPSS variable names
%   Version 2.2: October 2006
%       lose extention to wav files
%       add measure of relative level across channels
%   Version 2.0: June 2006
%       clean up output format
%       add dB rms values
%       change organisation of loop
%       make work with stereo and mono files
%	April 2002 -- modified from
%   November 2001 -- modified to get .wav files in a smarter way
%
%	Stuart Rosen, UCL: stuart@phon.ucl.ac.uk
%
if nargin<3
    NameDirInFile=0;
end

if nargin<2
    ExcelOutput=[];
end

ChannelLabel=['L', 'R'];

Files = dir(fullfile(InputDir, '*.wav'));
nFiles = size(Files);

if isempty(ExcelOutput)
    fprintf('\n%10s %3s %8s %8s %12s %10s %8s %5s\n', ...
        'FileName', 'L/R', 'SampFreq', 'nPoints', 'duration', 'max amp', 'rms', 'dB');
else
    [p,fileroot,e]=fileparts(ExcelOutput);
    ExcelOutput=fullfile(p, [fileroot '.csv']);
    Xout=fopen(ExcelOutput,'wt');
    if NameDirInFile
        fprintf(Xout, 'InputDir,')
    end
    fprintf(Xout, '%s,%s,%s,%s,%s,%s,%s,%s\n', ...
        'FileName', 'L/R', 'SampFreq', 'nPoints', 'duration', 'MaxAmp', 'rms', 'dB');
end
for i=1:nFiles
   % construct input file names
   InputFile =  fullfile(InputDir, Files(i).name);
   % fprintf('Processing file %d: %s\n', i, InputFile);
   % read the waveform, also picking up the sampling frequency (SampFreq) --
   [x,SampFreq] = audioread(InputFile);
   % check if stereo
   dim=size(x);
   % get number of samples
   n=dim(1);
   maximum=max(abs(x));
   rmsV = sqrt(mean(x.^2));
   dBrms = 20*log10(2*rmsV/sqrt(2));
   for channel=1:dim(2)
       if channel==1
           [p,fileroot,e]=fileparts(Files(i).name);
           if isempty(ExcelOutput)
               fprintf('%10s ', fileroot);
           else
               if NameDirInFile
                   fprintf(Xout, '%s,', InputDir)
               end
               fprintf(Xout, '%s,', fileroot);
           end
       else
           if isempty(ExcelOutput)
               fprintf('%10s ', ' ');
           else
               if NameDirInFile
                   fprintf(Xout, '%s,', InputDir)
               end
               fprintf(Xout, '%s,', fileroot);
           end
       end

       if isempty(ExcelOutput)
           fprintf('%3s %8d %8d %12.3f %10.4f %8.4f %5.1f',...
               ChannelLabel(channel),SampFreq,n,n/SampFreq,maximum(channel), ...
               rmsV(channel),dBrms(channel));
       else
           fprintf(Xout, '%s,%d,%d,%12.3f,%10.4f,%8.4f,%5.1f',...
               ChannelLabel(channel),SampFreq,n,n/SampFreq,maximum(channel), ...
               rmsV(channel),dBrms(channel));
       end
          
       if channel==2
           if isempty(ExcelOutput)
               fprintf('  %5.1f', 20*log10(rmsV(1)/rmsV(2)));
           else
               fprintf(Xout, ',%5.1f', 20*log10(rmsV(1)/rmsV(2)));
           end
       end
       if isempty(ExcelOutput)
           fprintf('\n');
       else
           fprintf(Xout, '\n');
       end
   end
end
if ~isempty(ExcelOutput)
    fclose(Xout);
end




   