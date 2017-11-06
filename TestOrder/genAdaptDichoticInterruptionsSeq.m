function genAdaptDichoticInterruptionsSeq(Iterations, OrderFile, nListener)
%
% use a Latin square to generate random orders from a given sequence file
%
%   genAdaptDichoticInterruptionsSeq(15, 'AdaptDichoticInterruptionsSeqList.csv',1)
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
nSize=size(SS);
nCols=nSize(2);
% how many conditions are there?
numTestConditions=nSize(1)-1;

% create test list vector:
ListNumber = ['1.050';'2.250';'3.450';'4.070';'6.010';'7.030';'8.050';'9.750';'11.15';'12.35';'13.06';'14.08';'16.02';'17.04'];



for iters=1:Iterations
    % generate a new randomised Latin square
    [m,r]=latsq(numTestConditions);
    [mTL,rTL]=latsq(numTestConditions);
    for listener=1:numTestConditions
        ListenerCode = ['L' sprintf('%02d',nListener)];
        OutFileName = [ListenerCode '.csv'];
        fprintf('Processing: %s\n', OutFileName);
        fout = fopen(fullfile(OutputDir, OutFileName),'wt');
        % output the first header line
        for col=1:nCols
            fprintf(fout, '%s,', char(SS{1,col}));
        end
        fprintf(fout,'\n');
        
        % now output the sequences in a randomised Latin square
        for trial=1:numTestConditions
            for col=1:9
                fprintf(fout, '%s,', char(SS{r(trial,listener)+1,col}));
            end
            for col=10
                fprintf(fout, '%s,', char(SS{rTL(trial,listener)+1,col})); %char(rTL(trial,listener)));
            end
            for col=11:nCols
                fprintf(fout, '%s,', char(SS{r(trial,listener)+1,col}));
            end
            fprintf(fout,'\n');

        end
        fclose(fout);
        BatchFileName = [ListenerCode '.m'];
        fout = fopen(fullfile(OutputDir, BatchFileName),'wt');
        fprintf(fout, 'runAdaptDichoticInterruptions(''%s'', ''%s'')\n', 'XX', [ListenerCode '.csv']);
        % fprintf(fout, 'runCCRMseq.exe %s %s\n', ListenerCode, [ListenerCode '.csv']);
        nListener=nListener+1;
        fclose(fout);
    end
    fclose('all');
    
end
