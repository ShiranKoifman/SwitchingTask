function AdaptDichoticInterruptions(ListenerID, varargin)
%
% function AdaptInterruptions()
%
% Titrate duty cycle adaptively for IEEE sentences at a fixed modulation rate,
% optionally adding in a pre-computed noise waveform during the silences
%
% All masker files are assumed to be in the directory 'Maskers'
%
% ASL, BKB or IEEE sentences (3 key words for BKB & ASL but 5 for IEEE)
% Program accounts for the fact that some ASL/BKB sentences are missing
%       (those with 4 key words), hence not all sentence numbers exist
%
% AdaptInterruptions('SentenceDirectory',['ASL' 'BKB' 'IEE' or 'ABC',
%   with additional single character indicator])
% The full string is taken as the name of the directory with the stimuli
% Stimulus wav file  names must be of the form BKBQ0101, for example.
% The first 3 characters indicate the name of the text file with the key
% words
%
% AdaptInterruptions('SentenceDirectory','ABC','NoiseFile','SpNz','Listener','L27','ListNumber',2,'FinalStep',2,'MaxTrials',20)
%
%% Version 4.6. [SK 10.07.2017] 
% changes made: 
%    -runAdaptDichoticInterruptions() was implemented based on the CCRM script
%     to enable running a sequence of test blocks based on a .csv listener-specific conditions list.
%    -Pre-randomisation of the NoiseFile starting point to minimise noise
%     segments repetition during a run.
%	 -GUI menu changed to improve clarity.
%	 -rms scaling is carried out in the function 'rmsNormalisation()' for: a) interrupted(), 
%     b) InterruptedDich, and c) InterruptedAltaltenating signals prioir to signals manipulations.
%     CAVA! in_rms is not implemented in 'rmsNormalisation()' at the moment [see SimpleAddWavs()]
%    -warningS and ramping time were added to interrupted only signals.
%    -Self-Response GUI window [ASLSelfResponse()] was implemented (based on Tim Green code) to
%     enable subject automatic self-response [on/off button is avilable in
%     the main GUI menu].
%    -duty cycle=1 is now possible for all test conditions
% (For older versions info see bottom of the script)



%--------------------------------------------------------------------------
%------------------------------- Initialisation ---------------------------
%--------------------------------------------------------------------------
VERSION='Version 4.6';
DEBUG=0;
warning_noise_duration=500;       % time (ms) between masker/s and target beginning
RiseFall=5;                       % rise/fall time in ms
rand('twister', sum(100*clock));  % initialise the random number generator on the basis of the time
mInputArgs = varargin;
OutputDir = 'results';

addpath('maskers'); addpath(genpath(pwd));
warning('off', 'MATLAB:MKDIR:DirectoryExists')
warning('off', 'MATLAB:str2func:invalidFunctionName');

% Variables 
PermuteMaskerWave = 1;    % minimise repeated playing of sections of noise wav
InterruptedFilesOut = 1;  % save output waves [1='on', 0='off]
SentenceNumber=1;         % can be modified if list number is not an integer

%% duty cycle is adjusted in linear terms with the following increments
START_change = 0.12;
MIN_change = 0.04;
% and the following start value
start_DC=0.9;

%% initial reversals (turns) are where the step-size is decreasing
INITIAL_TURNS = 3; % need one for the initial sentence up from the bottom if adaptiveUp
FINAL_TURNS = 6;
MaxBumps = 10;

%% minimum duty cycles permitted
MIN_DC = 0.05;

%% Settings for level
VolumeSettingsFile='VolumeSettings.txt';
[in_rms, out_rms]=SetLevels(VolumeSettingsFile);

% main volume for mac [seems not to work!]
%!osascript set_volume_applescript.scpt
%% get essential information for running a test
if nargin==0 % if no sequence file was used, open GUI menu $$ SK 04.07.2017 $$
    [TestType, ear, SentenceDirectory, NoiseFile, ModulationRate, SNR_dB, ...
    OutFile, MaxTrials, ListNumber, start_DC, TorP, UnProcDir, fixed, SelfResponse] ...
    = TestSpecs(mInputArgs);

else % pick up defaults and specified values from args (SK 04.07.2017)
    if ~rem(nargin,2)
        error('You should not have an even number of input arguments');
    end
    SpecifiedArgs=AdaptDichoticTestParseArgs(char(ListenerID),varargin{1:end});
    % now set all parameters obtained
    fVars=fieldnames(SpecifiedArgs);
    for f=1:length(fVars)
        if ischar(eval(['SpecifiedArgs.' char(fVars{f})]))
            eval([char(fVars{f}) '=' '''' eval(['SpecifiedArgs.' char(fVars{f})]) ''';']);
        else % it's a number
            eval([char(fVars{f}) '='  num2str(eval(['SpecifiedArgs.' char(fVars{f})])) ';'])
        end
    end 
%% Add practice trials before the begining of the test trials [for runAdaptDichoticInterruptions()]
    if ~isempty(findstr(ListenerID, '_Prac'))
        TorP = 'P';
    end
end
  
%% initialision:
% if fixed SNR procedure is selected:
SentenceType=upper(SentenceDirectory([1:3]));
if strcmp(TestType,'fixed')
    START_change = 0;
    MIN_change = 0;
    FINAL_TURNS = 50;
    MaxBumps = 50;
    % error('Fixed procedure not yet implemented');
end

% if self-response is turned off:
if SelfResponse<1
    TypedSentence = 'none';
end

%% calculate maximum duty cycle permitted
if strcmp(TestType,'fixed')
    MAX_DC = 1.0;
else % depends upon rise time and modulation rate
    MAX_DC = 1- (.001+(ModulationRate*RiseFall)/1000);
end

% check if a non-integral list number has been specified
if round(ListNumber)~=ListNumber
    switch SentenceType
        case 'ABC'
            SentenceNumber=mod(round((ListNumber-1)*30),30);
        case 'IEE'
            SentenceNumber=mod(round((ListNumber-1)*10),10);
        case 'CAL'
            SentenceNumber=mod(round((ListNumber-1)*25),25);         
        case 'ASL'
            %SentenceNumber=mod(round((ListNumber-1)*15),15); 
            SentenceNumber=mod(round((ListNumber-1)*19),14); 
        otherwise % BKB
            SentenceNumber=mod(round((ListNumber-1)*14),14);
    end
    ListNumber=floor(ListNumber);
end

%% set rules for adaptively altering levels
if strcmp(SentenceType,'IEE')|| strcmp(SentenceType,'ABC')
    % define the direction in which to change levels for [0  1  2  3 4 5] correct
    % CHANGE_VECTOR = [1  1  0 -1]; % 0 or 1 correct makes it easier; 2 correct stays at same level; 3 correct makes it more difficult
    % CHANGE_VECTOR = [1  1  1  1 0 -1]; % 0-3 correct makes it easier; 4 correct stays at the same level; 5 correct makes it more difficult
    CHANGE_VECTOR = [1  1  1  -1 -1 -1]; % 50% : 0-2 correct makes it easier; 3-5 correct makes it more difficult
elseif strcmp(SentenceType,'BKB') || strcmp(SentenceType,'ASL')
    % define the direction in which to change levels for BKB/ASL [0  1  2  3] correct
    % CHANGE_VECTOR = [1  1  0 -1]; % 0 or 1 correct makes it easier; 2 correct stays at same level; 3 correct makes it more difficult
    % CHANGE_VECTOR = [1  1  1 -1]; % 0 or 1 or 2 correct makes it easier; 3 correct makes it more difficult
    CHANGE_VECTOR = [1  1  -1 -1]; % 50% : 0 or 1 correct makes it easier; 2 or 3 correct makes it more difficult  
elseif strcmp(SentenceType,'CAL')
    % define the direction in which to change levels for Calandruccio [0  1  2  3  4] correct
    % CHANGE_VECTOR = [1  1  0 -1]; % 0 or 1 correct makes it easier; 2 correct stays at same level; 3 correct makes it more difficult
    % CHANGE_VECTOR = [1  1  1 -1]; % 0 or 1 or 2 correct makes it easier; 3 correct makes it more difficult
    CHANGE_VECTOR = [1  1 0 -1 -1]; % Track 50% -- 0 or 1 correct makes it easier; 2 or 3 correct makes it more difficult
else    
    error('First 3 characters of directory given must be one of IEE, ABC, CAL, BKB or ASL');
end

%% read in list of key words (SK 09.09.17)
% assume the key words are in ASLwords.txt or BKBwords.txt
words_list = [SentenceDirectory(1:3) 'words.txt'];
if exist(words_list,'file')
    fid      = fopen(words_list);
    C        = textscan(fid, '%d%d%s', 'delimiter', '\n', 'whitespace', '');
    list     = C{1};
    sentence = C{2};
    KeyWords = C{3};
else % ensure the file is avilable 
    FileMissingErrorMessage = sprintf('Missing file: %s does not exist',  words_list);
    h = msgbox(FileMissingErrorMessage, 'Missing file', 'error', 'modal'); uiwait(h);
    error(FileMissingErrorMessage);    
end

status = mkdir(OutputDir);
if status==0
    error('Cannot create new output directory for results: %s', OutputDir);
end

% get the starting date & time of the session
StartTime=fix(clock);
StartTimeString=sprintf('%02d:%02d:%02d',...
    StartTime(4),StartTime(5),StartTime(6));
FileNamingStartTime = sprintf('%02d-%02d',StartTime(4),StartTime(5));
StartDate=date;
% construct the output data file name
[pathstr, ListenerName, ext] = fileparts(OutFile);
% get the root name of the noise file
if ~strcmp(NoiseFile,'none')
    [pathstr, NoiseFileName, ext] = fileparts(NoiseFile);
    else NoiseFileName='none';
end
% put method, date and time on filenames so as to ensure a single file per test
% FileListenerName=[ListenerName '_' NoiseFileName '_' StartDate '_' FileNamingStartTime];
FileListenerName=[ListenerName '_' TorP '_' ear '_' NoiseFileName '_' num2str(SNR_dB, '%d') 'dB_' StartDate '_' FileNamingStartTime];
OutFile = fullfile(OutputDir, [FileListenerName '.csv']);
SummaryOutFile = fullfile(OutputDir, [FileListenerName '_sum.csv']);
% write some headings and preliminary information to the output file
fout = fopen(OutFile, 'at');
fprintf(fout, 'listener,date,sTime,ear,trial,targets,SNR,OutLevelChange,duty,change,masker,wave,w1,w2,w3,sum,PlayedSentence,TypedSentence,total,rTime,rev');
fclose(fout);

%% find starting place in list of sentences
% modification for IEEE should be applicable to ~any~ list
if strcmp(SentenceType,'IEE') || strcmp(SentenceType,'ABC')
    % find list and sentences in given list of stimuli
    % throw error if not available
    SentenceIndex=find(list==ListNumber & sentence==SentenceNumber);
    if isempty(SentenceIndex)
        error('List %d sentence %d not in stimulus list',ListNumber,SentenceNumber);
    end
    % SentenceIndex = (ListNumber-1)*10 + SentenceNumber; % oldest version
elseif strcmp(SentenceType,'ASL')
       SentenceIndex = (ListNumber-1)*15 + SentenceNumber;
elseif strcmp(SentenceType,'CAL')
    SentenceIndex = (ListNumber-1)*25 + SentenceNumber;    
else % BKB sentences
    SentenceIndex = (ListNumber-1)*14 + SentenceNumber;
end


%%% set up sentence task for this trial
%% generate randomised NoiseFile starting points (SK 05.07.2017)
if PermuteMaskerWave % keep track of masker sections used
       % find longest duration target
       MaxDurTargetSamples=0;
       for SI=SentenceIndex:SentenceIndex+MaxTrials-1
            % construct complete filename
           InFileName = construct_filename(SentenceDirectory,list(SI), sentence(SI));
           StimulusFile = fullfile(SentenceDirectory, InFileName);           
           [x,SampFreq] = audioread([StimulusFile '.wav']);
           % check if stereo
           dim=size(x);
           % get number of samples
           n=dim(1);
           MaxDurTargetSamples=max(MaxDurTargetSamples,n);
       end
       %MaxDurTargetSamples=MaxDurTargetSamples + ceil(SampFreq*(warning_noise_duration+2*NoiseRiseFall)/1000);
       %'NoiseRiseFall' was removed (noise is not ramped at the end of the signal)
       MaxDurTargetSamples=MaxDurTargetSamples + ceil(SampFreq*(warning_noise_duration+2)/1000);

       if ~strcmp(NoiseFile,'none') % if NoiseFile exists, generate a set of random sections of the masker wave for possible use later
           [nSections, wavSections]=GenerateWavSections(NoiseFile, MaxDurTargetSamples);
       end
end

%% set number of key words
if strcmp(SentenceType,'IEE')|| strcmp(SentenceType,'ABC')
    nKW = 5;
elseif strcmp(SentenceType,'CAL')
    nKW = 4;
elseif strcmp(SentenceType,'BKB') || strcmp(SentenceType,'ASL')
    nKW = 3;    
else
    error('First 3 characters of directory given must be one of IEE, ABC, BKB, ASL, CAL or BEL');
end 

%% setup a few starting values
duty=start_DC;
if strcmp(TestType,'adaptiveUp')
    previous_change = 1; % assume track is initially moving from hard to easy
else
    previous_change = -1; % assume track is initially moving from easy to hard
end
num_turns = 0;
num_final_trials = 0;
change = START_change;
inc = (START_change-MIN_change)/INITIAL_TURNS;
limit = 0;
response_count = 0;
trial = 0;
nWavSection=0;
nCorrect = 0;
nKeys = 0;

FirstSentence=1; % indicate different procedure for first sentence for adaptiveUp
if strcmp(TestType,'adaptiveUp')
    tmpCHANGE_VECTOR=CHANGE_VECTOR;
    CHANGE_VECTOR=ones(size(CHANGE_VECTOR));
    CHANGE_VECTOR(end)=0;
end

%% ready to go!
% open a GUI window with a message and a go button

if nargin<1 % if a start message was not given, make one
    StartMessage=[sprintf('\n\n Press the Go button to start')];
end

if SelfResponse==1
    StartMessage = sprintf('%-s\n',StartMessage);
    GoOrMessageButton(StartMessage);
else % insert condition information if SelfResponse is off
    DisplayItem1 = char(['Noise: ' NoiseFile]);
    DisplayItem2 = char(['Ear: ' ear]);
    StartMessage=[sprintf('%-s\n\n',StartMessage, DisplayItem1, DisplayItem2)];
    GoOrMessageButton(StartMessage);
end

%% run the test (do adaptive tracking until stop criterion)
while (num_turns<FINAL_TURNS  && limit<=MaxBumps && trial<MaxTrials)
    trial=trial+1;
    nWavSection=nWavSection+1;
    % construct complete filename
    InFileName = construct_filename(SentenceDirectory,list(SentenceIndex), sentence(SentenceIndex));
    StimulusFile = fullfile(SentenceDirectory, InFileName);
    
    %% generat the audio files
    % function [y, Fs, OutLevelChange]=add_signal(StimulusFile, NoiseFile, ...
    %                                  ModulationRate, duty, RiseFall, SNR_dB,...
    %                                  in_rms, out_rms, warning_noise_duration,...
    %                                  InterruptedFilesOut, ear, MaskerWavStart, fixed);
    %
    % selecting a starting point from a vector (MaskerWavStart) if PremuteMaskerWave is on (i.e. =1)
    
        if  PermuteMaskerWave % keep track of masker sections used
            if  ~strcmp(NoiseFile,'none')
                MaskerWavStart=wavSections(nWavSection);
                % check WavSectoions
                %wavSections(nWavSection)/Fs
            else
                MaskerWavStart=-1;
            end
        end
            [y, Fs, OutLevelChange]=add_signal(StimulusFile, NoiseFile, ...
            ModulationRate, duty, RiseFall, SNR_dB, in_rms, out_rms, warning_noise_duration, ...
            InterruptedFilesOut, ear, MaskerWavStart, fixed);
    % check if NoiseFile starting points are available, if not randomise
    % radomise more
        if PermuteMaskerWave % keep track of masker sections used
             if  ~strcmp(NoiseFile,'none')
                   if nWavSection==nSections
                      nWavSection=0;
                      [nSections, wavSections]=GenerateWavSections(NoiseFile, MaxDurTargetSamples);
                   end
             end
        end
    
    % make a silent contralateral noise for monaural presentations
    ContraNoise=zeros(size(y));
    % determine the ear(s) to play out the stimuli
    switch ear
        case 'L', y=[y ContraNoise];
        case 'R', y=[ContraNoise y];
        case 'B', y=[y y];
        case 'r', y=[y(:,2) y(:,1)]; % need to swap dichotic channels here           
        case {'A', 'l', 'M'},             
        otherwise error('variable ear must be one of l, r, A, L, R, B or M')
    end
    
    % save wav files if InterruptedFilesOut is on (==1)
    if InterruptedFilesOut
        audiowrite('CurrentInterruptedWave.wav', y, Fs);
    end

    if ~DEBUG
        % play it out and score it. (open scoring window)
        if strcmp(SentenceType,'IEE') || strcmp(SentenceType,'ABC')
            response = IEEE(nKW,KeyWords{SentenceIndex},list(SentenceIndex),sentence(SentenceIndex),Fs,duty,y);
        elseif strcmp(SentenceType,'CAL')
            response = CAL(nKW,KeyWords{SentenceIndex},list(SentenceIndex),sentence(SentenceIndex),Fs,duty,y);            
        else
            if SelfResponse==1 
            [response, TypedSentence] = ASLSelfResponse(nKW,KeyWords{SentenceIndex},list(SentenceIndex),sentence(SentenceIndex),Fs,duty,y, trial, MaxTrials);   
            else % when SelfResponse is off (==0)
                response = ASLscore(nKW,KeyWords{SentenceIndex},list(SentenceIndex),sentence(SentenceIndex),Fs,duty,y);  
            end
        end
    else
        if strcmp(SentenceType,'IEE') || strcmp(SentenceType,'ABC')
            RandomPropCorrect=0.5;
            response=[rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect];
        elseif strcmp(SentenceType,'CAL')
            RandomPropCorrect=0.5;
            response=[rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect];     
        else
            RandomPropCorrect=0.5;
            response=[rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect];
        end
    end
    TmpTimeOfResponse = fix(clock);
    TimeOfResponse=sprintf('%02d:%02d:%02d',...
        TmpTimeOfResponse(4),TmpTimeOfResponse(5),TmpTimeOfResponse(6));
    
    % test for quitting
    if strcmp(response,'quit')
        break
    end
    
    %% keep track of levels visited: perhaps better sometimes than reversals?
    if ((change-0.001) <= MIN_change) % allow for rounding error
        % we're in the final stretch
        num_final_trials = num_final_trials + 1;
        final_trials(num_final_trials) = duty;
    end

    fout = fopen(OutFile, 'at');
    % print out relevant information
    % fprintf(fout, 'listener,date,sTime,ear,trial,targets,SNR,OutLevelChange,duty,change,masker,wave,w1,w2,w3,sum,OriginalSentence,TypedSentence,total,rTime,rev');
    if strcmp(SentenceType,'BKB') || strcmp(SentenceType,'ASL')
            fprintf(fout, '\n%s,%s,%s,%c,%d,%s,%+5.1f,%+5.1f,%5.3f,%5.3f,%s,%s,%d,%d,%d,%d,%s,%s,%s', ...
            ListenerName,StartDate,StartTimeString,ear,trial,SentenceDirectory,SNR_dB,OutLevelChange,duty,change,NoiseFileName,InFileName,...
            response(1),response(2),response(3),sum(response),char(KeyWords(SentenceIndex)),TypedSentence,TimeOfResponse);
    elseif strcmp(SentenceType,'CAL') 
        fprintf(fout, '\n%s,%s,%s,%c,%d,%s,%+5.1f,%+5.1f,%5.3f,%5.3f,%s,%s,%d,%d,%d,%d,,%d,%s', ...
            ListenerName,StartDate,StartTimeString,ear,trial,SentenceDirectory,SNR_dB,OutLevelChange,duty,change,NoiseFileName,InFileName,...
            response(1),response(2),response(3),response(4),sum(response),TimeOfResponse);        
    else
        fprintf(fout, '\n%s,%s,%s,%c,%d,%s,%+5.1f,%+5.1f,%5.3f,%5.3f,%s,%s,%d,%d,%d,%d,%d,%d,%s', ...
            ListenerName,StartDate,StartTimeString,ear,trial,SentenceDirectory,SNR_dB,OutLevelChange,duty,change,NoiseFileName,InFileName,...
            response(1),response(2),response(3),response(4),response(5),sum(response),TimeOfResponse);
    end 
    
    %% give feedback if required for a practice session
    if TorP=='P'
        PracticeFile = fullfile(UnProcDir, InFileName);
        [unProc, Fp] = audioread(ensureWavExtension(PracticeFile));
        % check if stereo -- if so, take only one channel
        n=size(unProc);
        if n(2)>1
            unProc = unProc(:,1);
        end
        % play Unprocessed signal
        playEm = audioplayer(unProc, Fp);
        playblocking(playEm);
        %wavplay(unProc, Fp)
        % play processed signal again 
        pause(1);
        playEm = audioplayer(y, Fs);
        playblocking(playEm);
        % wavplay(y, Fs)
        pause(1.5);
    end
    
    nCorrect = nCorrect + sum(response);
    nKeys = nKeys + length(response);
    
    % decide in which direction to change levels
    current_change = CHANGE_VECTOR(sum(response)+1);
    
    % are we at a turnaround? (defined here as any change in direction)
    % If so, do a few things
    if (previous_change ~= current_change)
        % reduce step proportion if not minimum */
        if ((change-0.001) > MIN_change) % allow for rounding error
            change = change-inc;
        else % final turnarounds, so start keeping a tally
            num_turns = num_turns + 1;
            reversals(num_turns)=duty;
            fprintf(fout,',*');
        end
        % reset change indicator
        previous_change = current_change;
    end
    
    % change stimulus level
    duty = duty +  change*current_change;
    
    % ensure that the current stimulus level is within the possible range
    % and keep track of hitting the endpoints, but not for the first sentence
    if duty>MAX_DC
        duty = MAX_DC;
        if  ~FirstSentence
            limit = limit+1;
        end
    end
    if duty<MIN_DC
        duty=MIN_DC;
    end

    % close file for safety
    fclose(fout);
    
    if strcmp(TestType,'adaptiveUp')
        if FirstSentence
            % move on to proper test if all words identified
            if sum(response)==length(CHANGE_VECTOR)-1
                FirstSentence=0;
                CHANGE_VECTOR=tmpCHANGE_VECTOR;
            end
        end
    end
    % increment sentence counter except if first trial
    if ~FirstSentence || ~strcmp(TestType,'adaptiveUp')
        SentenceIndex = SentenceIndex + 1;
    else
        trial=trial-1;
    end
        
end  % end of a single trial */

%% We're done!
EndTime=fix(clock);
EndTimeString=sprintf('%02d:%02d:%02d',EndTime(4),EndTime(5),EndTime(6));

%% output summary statistics
fout = fopen(SummaryOutFile, 'at');
if strcmp(TestType,'fixed')
    fprintf(fout, 'listener,date,sTime,endTime,ear,SelfResponse,type,stimuli,noise,SNR,version,');
    fprintf(fout, 'finish,nCorrect,nKeys,pc,nTrials');
    fprintf(fout, '\n%s,%s,%s,%s,%s,%g,%s,%s,%s,%g,%s', ...
        ListenerName,StartDate,StartTimeString,EndTimeString,...
        ear,SelfResponse,SentenceType,SentenceDirectory,NoiseFileName,SNR_dB,VERSION);
    if strcmp(response,'quit')  % test for quitting
        fprintf(fout, ',QUIT');
    else
        fprintf(fout, ',OK');
    end
    fprintf(fout, ',%d,%d,%d,%g,%d\n', ...
        nCorrect,nKeys,nCorrect/nKeys,trial);
else % TestType is Adaptive
    fprintf(fout, 'listener,date,sTime,endTime,ear,SelfResponse,type,stimuli,noise,SNR,version');
    fprintf(fout, ',finish,uRevs,sdRevs,nRevs,nTrials,uLevs,sdLevs,nLevs');
    fprintf(fout, '\n%s,%s,%s,%s,%s,%g,%s,%s,%s,%g,%s', ...
        ListenerName,StartDate,StartTimeString,EndTimeString,...
        ear,SelfResponse,SentenceType,SentenceDirectory,NoiseFileName,SNR_dB,VERSION);
    
    % print out summary statistics -- how did we get here?
    if (limit>=3) % bumped up against the limits
        fprintf(fout,',BUMPED');
    elseif strcmp(response,'quit')  % test for quitting
        fprintf(fout, ',QUIT');
    elseif (num_turns<FINAL_TURNS)
        fprintf(fout, ',RanOut');
    else
        fprintf(fout, ',OK');
    end
    
    if num_turns>1
        fprintf(fout, ',%5.2f,%5.2f', ...
            mean(reversals), std(reversals));
    else
        fprintf(fout, ',,');
    end
    fprintf(fout, ',%d,%d', num_turns, trial);
    % now output the statistics for levels visited after the initial reversals
    if num_final_trials>1
        fprintf(fout, ',%5.4f,%5.4f,%d\n', ...
            mean(final_trials), std(final_trials), num_final_trials);
    else
        fprintf(fout, ',,,%d\n',num_final_trials);
    end    
end

fclose(fout);
fclose('all');
set(0,'ShowHiddenHandles','on');
delete(findobj('Type','figure'));
%finish; % indicate test is over % $$$$$$$ commented out because of a bug
%with ASLSelfResponse

function name = construct_filename(SentenceIndicator,list, sentence)
if strcmp(SentenceIndicator([1:3]),'IEE')
    name = sprintf('ieee%02d%c%02d', list, SentenceIndicator(5), sentence);
elseif strcmp(SentenceIndicator([1:3]),'ABC')
    name = sprintf('abc%s%02d%02d', 'f', list, sentence);
else
    name = [SentenceIndicator sprintf('%02d%02d', list, sentence)];
end

%% Versions details for AdaptInterruptions() 
% Version 4.5 - June 2016
%   implement a 'mixed' version of alternate
%
% Version 4.0 - May 2016
%   update wavread and wavplay to audioread and audioplay
%
% Version 3.3 - December 2014
%   Make practice target file directory same as main on in TestSpecs
%   This is labelled as unprocdir as a legacy from programs in which the
%       target processing is done offline, so there needs to be a directory
%       of the unprocessed target sentences in order to do practice
%
% Version 3.2 - December 2014
%   Correct errors in setting ear conditions in TestSpecs
%
% Version 3.1 - December 2014
%   Allow the use of CAL sentence with 4 key words
%
% Version 3.0 - November 2014
%   Allow the use of CAL sentence with 4 key words
%   scale practice trials to an appropriate level
%
% Version 2.0 - November 2014
%   allow a dichotic version where there is competing speech in the
%   opposite ear but no alternation
%
% Version 1.5 - November 2014
%   allow the specification of a warning masker duration to precede the
%   target speech: simple addition of silence to target stimuli but need to
%   ensure that period is not included in calculations for SNR
%
% Version 1.0 - October 2014
%   from Version 2.5 of AdaptInterruptions()
%   allow interruptions to be present alternating dichotically
%
% Version 2.5 - October 2013
%   implement possibility of a practice session with feedback
%   allow duty cycle to be 1.0 (uninterrupted) for fixed level testing
%
% Version 2.0 - September 2013
%   implement fixed duty cycle procedure
%   implement new volume controls
%   noted odd behaviour of target levels when silent gaps are introduced
%       rms scaling is applied to entire signal, so as duty cycle
%       decreases, the level of the signal icreases causing overloads
%       Implemented a quick fix in SimpleAddWavs.m in which the scaling is
%       applied to the uninterrupted signal if the SNR>80. This way, the
%       signal level will decrease with shorter duty cycles
%
% Version 1.0 - August 2010
%   based on Version 3.0 of SentInNoiseAdaptive.m
%
% -------------------------------------------------------------------------
% Version 3.0 - January 2010
%   fix level of noise and vary signal
%   OBS!! Must add this to GUI to ensure proper specification and behaviour!!
%   Put information about overloads into output file, allowing any level
% Version 2.9 - January 2010
%   make RISE_FALL an arg to add_noise
% Version 2.8 - November 2009
%   allow a more general specification of file names, but require all
%   directories to have the format of a 3-character type
%   ['ASL' 'BKB' 'IEE' or 'ABC'] and a single character more specific
%   identifier, i.e., IEEm
%
% Version 2.7 - November 2009
%   correct error in specifying name of text files with key words
%   throw more legible error messages for missing text files that need to
%       be read in
% Version 2.5 - August 2009
%   allow for warning noise duration and rise/fall times when calculating
%       maximum length of masker needed (when permuting wave sections)
%       Frequent crashes arose from short masker files, in particular SpchNz
%       Would need to modify code to allow for constant duration output wave
% Version 2.4 - June 2009
%   allow specification of final step size in call to script
% Version 2.3 - May 2009
%   correct error in use of non-integral list numbers in specifying start
% Version 2.2 - May 2009
%   allow the use of ABC sentences (similar to IEEE)
%
% Version 2.1 - May 2009
%   read in rms from VolumeSettings.txt as in CCRM
%   allow typical adaptive procedure starting from high SNR, as well as
%       Plomp & Mimpen up from bottom
%
% Version 2.0 - May 2009
%   control which sections of long noise wave get played out to minimise
%       repeated playing of particular sections
%   use function add_noise.m from CCRM 2009, in place of AddNoiseReturnAnother.m
%       possibility of a contralateral noise nobbled in this version
%       could be added back later.
% Version 1.2 - February 2008
%   allow specification of run-time paramaters on command line
% Version 1.1 - January 2008
%   modify bumping rules to stop premature termination of trials, esp on
%   the 2nd trial.
%   Make MaxBumps an explicit paramater
%   Up the Bumps
% Version 1.0 - December 2007, based on SentInNoiseFixed for Arooj
%   and SentInNoise for KMair
%   Major changes:
%   Bring sentence up from a low level until heard correctly,
%       and then begion adaptive track (as in Plomp & Mimpen, 1978)
%   Use GUI for entering information for starting procedure
%-----------------------------------------------------------------------
% To do:
%   put rms levels in and out on to the interface
%   put MaxBumps on the interface
%   figure out a general way to initialise the parameter values in the
%   interface from a text file, line a .ini
%   browse masker file names choose?
%-----------------------------------------------------------------------
% Previous History:
% Version 2.0 - November 2007, modified for Arooj's project
%   read in volume settings from a file for easier use in compiled mode
%   convert arguement strings to numbers when appropriate
%   delete interface completely at end of session
% June 2007 based on SentInNoise from K Mair's project
% Vs 1.5 December 2006: only play sentences in specified file list, and
% index properly into the list.
% Stuart Rosen stuart@phon.ucl.ac.uk -- October 2006
% based on version for Bronwen Evans -- 27 August 2003
% based on ASLBKBrun -- December 2001
