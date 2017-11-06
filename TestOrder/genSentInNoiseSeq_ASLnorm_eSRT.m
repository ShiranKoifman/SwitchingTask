function genSentInNoiseSeq_ASLnorm_eSRT(Iterations, OrderFile, nListener)
% 
% use a Latin square to generate random orders from a given sequence file
%
% Modified on June 2017 by SL to generate sequence files from a .CSV list
% containing individuals pre-randomised test conditions.
%
%   genSentInNoiseSeq_ASLnorm_eSRT(15, 'SentInNoiseSeqList.csv',1)
%
%   Modifications for BSc Affiliates 2015 to run from Matlab
%   nListener = to start numbering from
%

% construct an output directory with a distinguishing name
[~,Exptr,~]=fileparts(OrderFile);
Exptr = strrep(Exptr, 'SeqList','');

OutputDir = ['TestOrders_' Exptr];
ClearAndMakeDir(OutputDir);

%% read in the sequence
SS=robustcsvread(OrderFile);

%% determine dimensions of the input
nSize=size(SS); % list size (row, column)
nCols=nSize(2); % column size
nMeasurements=1; % number of blocks per subject
% how many conditions are there?
numTestConditions=nSize(2)-2; % number of parameters 


counter=1; % counter for subjects
for iters=1:Iterations
        ListenerCode = ['P' sprintf('%02d',nListener)];
        OutFileName = [ListenerCode '.csv'];
        fprintf('Processing: %s\n', OutFileName);
        fout = fopen(fullfile(OutputDir, OutFileName),'wt');
        % output the first header line
        for col=2:nCols
            fprintf(fout, '%s,', char(SS{1,col}));
        end
        fprintf(fout,'\n');
        % now output the sequences per subject
        trial=0;
        i = 2:1:nSize(1);
        for trial=trial:nMeasurements-1
            for col=2:nCols
                fprintf(fout, '%s,', char(SS{trial+i(counter),col}));  
            end
            fprintf(fout,'\n');
        end
        fclose(fout);
        BatchFileName = [ListenerCode '.m'];
        fout = fopen(fullfile(OutputDir, BatchFileName),'wt');
        fprintf(fout, 'runSentInNoiseSeq(''%s'', ''%s'')\n', 'XX', [ListenerCode '.csv']);
        % fprintf(fout, 'runCCRMseq.exe %s %s\n', ListenerCode,1 [ListenerCode '.csv']);
        nListener=nListener+1;
        fclose(fout);
    fclose('all');
  counter = counter+1;  
end

