function runAdaptDichoticInterruptions(ListenerName, OrderFile)
%
% in the current implementation, nBlocks must be first in row!
% All the other arguments can come in any order, as defined by the first row
%
% Inputs:
% 'ListenerName':   participants ID
% 'OrderFile':      participant-cpecific condition order saved as .csv file
%
% e.g. runAdaptDichoticInterruptions('test', 'L01.csv')



addpath(genpath(pwd))
%% read in the sequence and do some checks
SS=robustcsvread(OrderFile);
nBlockIndex=strmatch('nBlocks',strvcat(SS{1,:}));
if nBlockIndex>1
    error('nBlocks, the number of blocks to run must be in the first column');
end
nPracticeTrialsIndex=strmatch('nPracticeTrials',strvcat(SS{1,:}));
if nPracticeTrialsIndex~=2
    error('nPracticeTrials, the number of practice trials to run must be in the second column');
end

%%% $$ DO NOT WORK AT THE MOMENT. DO WE WANT TO IMPLEMENT IT? SK 15.05.2017
if strcmp(ListenerName,'XX')
    [I, DOB, sex] = ListenerID();
    ListenerName = [I, '_', DOB,'_', sex];
end

% %     [TestType, ear, SentenceDirectory, NoiseFile, ModulationRate, SNR_dB, ...
% %     OutFile, MaxTrials, ListNumber, start_DC, TorP, UnProcDir, fixed] ...
% %     = TestSpecs(mInputArgs);

%%% $$
for s=2:size(SS,1)
    % do practice trials, if required
    nPracticeTrials=str2double(SS(s,nPracticeTrialsIndex));
    if nPracticeTrials>0
        % add a little extra on to the message
        nStartMessageIndex=strmatch('StartMessage ',char(SS{1,:}));
        if ~isempty(nStartMessageIndex)
            MessagePrefix=['This is for practice. '];
        else
            MessagePrefix=[];
        end
        ArgArray = [[ListenerName '_Prac'] ConstructArgArray(s, SS)];
        % change SentenceDirectory to practice directory (UnProcDir)
        ArgArray{find(strcmp('SentenceDirectory', ArgArray))+1} = ArgArray{find(strcmp('UnProcDir', ArgArray))+1}; 
        % peak random target test list
        if ArgArray{find(strcmp('UnProcDir', ArgArray))+1} == 'BKBQ'
            %ListNumber = randi(21); %BKB
            ListNumber = randi([5 21],1); %BKB % $$$$ avoid using test lists 1-4
        else
            ListNumber = randi(18); %ASL
        end
        ArgArray{find(strcmp('ListNumber', ArgArray))+1}=ListNumber;
        % set number of trials
        ArgArray{find(strcmp('MaxTrials', ArgArray))+1}=str2double(SS{s,2});
        AdaptDichoticInterruptions(ArgArray{1:length(ArgArray)})  
    end

    for nB=1:str2double(SS{s,nBlockIndex});
        % add a little extra on to the message
        nStartMessageIndex=strmatch('StartMessage ',char(SS{1,:}));
        if ~isempty(nStartMessageIndex)
            MessagePrefix=['This is for real. '];
        else
            MessagePrefix=[];
        end
        
        ArgArray = [ListenerName ConstructArgArray(s, SS)];
        
        % SK 07.09.2017$$$$$
        % for practice runs: check for NoiseFile containing a .txt file (with a
        % list of possible maskers). Then, randomly choose one masker
        if ~isempty(strfind(ArgArray{find(strcmp('NoiseFile', ArgArray))+1}, 'txt')) % NoiseFile contain .txt file?
            maskers = textread(ArgArray{find(strcmp('NoiseFile', ArgArray))+1}, '%s'); % read .txt file
            nMasker = randi(size(maskers,1)); %randomly select one
            ArgArray{find(strcmp('NoiseFile', ArgArray))+1} = char(maskers(nMasker)); % save the masker in ArgArray
        end
        % SK 07.09.2017$$$$$
        
        AdaptDichoticInterruptions(ArgArray{1:length(ArgArray)})        
    end
end


%% construct the argument cell array
function ArgArray = ConstructArgArray(s, SS)
%
% go through the specified arguments, convert strings that are numbers to
% strings
% Future version: skip over unnecessary arguments.
% % % % % ArgArray=cell(1,2*(size(SS,2)-2));
ArgArray=cell(1,size(SS,2));
for col=3:size(SS,2)
    ArgArray{2*col-5}=SS{1,col};
    if strcmp('StartMessage', SS{1,col})
        ArgArray{2*col-4}=[MessagePrefix SS{s,col}];
    else
        maybeNumber = str2double(SS{s,col});
        if isnan(maybeNumber)
            ArgArray{2*col-4}=SS{s,col};
        else
            ArgArray{2*col-4}=maybeNumber;
        end
        
    end
end

end

end
