function AdaptInterruptions(varargin)
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
%       interface from a text file, line a .ini
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


%% initialisations

VERSION='Version 2.0';
DEBUG=0;
% set following = 0 if no output waves are required (which would be typical)
InterruptedFilesOut=1;

OutputDir = 'results';
%% minimum and maximum duty cycles permitted
MAX_DC = 1.0;
MIN_DC = 0.05;

SentenceNumber=1; % can be modified if list number is not an integer

%% duty cycle is adjusted in linear terms with the following increments
START_change = 0.12;
MIN_change = 0.04;
% and the following start value
start_DC=0.9;

%% initial reversals (turns) are where the step-size is decreasing
INITIAL_TURNS = 3; % need one for the initial sentence up from the bottom if adaptiveUp
FINAL_TURNS = 18;
MaxBumps = 10;

RiseFall=5; % rise/fall time in ms

% initialise the random number generator on the basis of the time
rand('twister', sum(100*clock));

mInputArgs = varargin;

%% Settings for level
VolumeSettingsFile='VolumeSettings.txt';
[InRMS, OutRMS]=SetLevels(VolumeSettingsFile);

%% get essential information for running a test
[TestType, ear, SentenceDirectory, NoiseFile, ModulationRate, SNR_dB, ...
    OutFile, MaxTrials, ListNumber, start_DC, TorP, UnProcDir] ...
    = TestSpecs(mInputArgs);
SentenceType=upper(SentenceDirectory([1:3]));
if strcmp(TestType,'fixed')
    START_change = 0;
    MIN_change = 0;
    FINAL_TURNS = 50;
    MaxBumps = 50;
    % error('Fixed procedure not yet implemented');
end

% check if a non-integral list number has been specified
if round(ListNumber)~=ListNumber
    switch SentenceType
        case 'ABC'
            SentenceNumber=mod(round((ListNumber-1)*30),30);
        case 'IEE'
            SentenceNumber=mod(round((ListNumber-1)*10),10);
        otherwise % BKB
            SentenceNumber=mod(round((ListNumber-1)*14),14);
    end
    ListNumber=floor(ListNumber);
end

%% set rules for adaptively altering levels
if strcmp(SentenceType,'IEE')|| strcmp(SentenceType,'ABC')
    % define the direction in which to change levels for
    %               [0  1  2  3 4 5] correct
    % CHANGE_VECTOR = [1  1  0 -1]; % 0 or 1 correct makes it easier; 2 correct stays at same level; 3 correct makes it more difficult
    % CHANGE_VECTOR = [1  1  1  1 0 -1]; % 0-3 correct makes it easier; 4 correct stays at the same level; 5 correct makes it more difficult
    CHANGE_VECTOR = [1  1  1  -1 -1 -1]; % 50% : 0-2 correct makes it easier; 3-5 correct makes it more difficult
elseif strcmp(SentenceType,'BKB') || strcmp(SentenceType,'ASL')
    % define the direction in which to change levels for BKB/ASL
    %               [0  1  2  3] correct
    CHANGE_VECTOR = [1  1  0 -1]; % 0 or 1 correct makes it easier; 2 correct stays at same level; 3 correct makes it more difficult
    % CHANGE_VECTOR = [1  1  1 -1]; % 0 or 1 or 2 correct makes it easier; 3 correct makes it more difficult
else
    error('First 3 characters of directory given must be one of IEE, ABC, BKB or ASL');
end

%% read in list of key words
% assume the key words are in ASLwords.txt     or BKBwords.txt
% ensure the file is avilable
if exist([upper(SentenceType) 'words.txt'],'file')
    [list, sentence, KeyWords]= textread([upper(SentenceType) 'words.txt'],'%d %d %s','delimiter','\n','whitespace','');
else
    FileMissingErrorMessage=sprintf('Missing file: %s does not exist',  [upper(SentenceType) 'words.txt']);
    h=msgbox(FileMissingErrorMessage, 'Missing file', 'error', 'modal'); uiwait(h);
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
[pathstr, NoiseFileName, ext] = fileparts(NoiseFile);
% put method, date and time on filenames so as to ensure a single file per test
% FileListenerName=[ListenerName '_' NoiseFileName '_' StartDate '_' FileNamingStartTime];
FileListenerName=[ListenerName '_' TorP '_' NoiseFileName '_' num2str(SNR_dB, '%d') 'dB_' StartDate '_' FileNamingStartTime];
OutFile = fullfile(OutputDir, [FileListenerName '.csv']);
SummaryOutFile = fullfile(OutputDir, [FileListenerName '_sum.csv']);
% write some headings and preliminary information to the output file
fout = fopen(OutFile, 'at');
fprintf(fout, 'listener,date,sTime,trial,targets,SNR,OutLevelChange,duty,masker,wave,w1,w2,w3,w4,w5,total,rTime,rev');
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
else % BKB sentences
    SentenceIndex = (ListNumber-1)*14 + SentenceNumber;
end

%% setup a few starting values
duty=start_DC;
if strcmp(TestType,'adaptiveUp')
    previous_change = 1; % assume track is initially moving from hard to easy
else
    previous_change = -1; % assume track is initially moving from easy to hard
end
num_turns = 0;
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

GoButton;

%% run the test (do adaptive tracking until stop criterion)
while (num_turns<FINAL_TURNS  && limit<=MaxBumps && trial<MaxTrials)
    trial=trial+1;
    nWavSection=nWavSection+1;
    % construct complete filename
    InFileName = construct_filename(SentenceDirectory,list(SentenceIndex), sentence(SentenceIndex));
    StimulusFile = fullfile(SentenceDirectory, InFileName);
    
    % function [x, Fs]=interruptWave(SignalWav, NoiseWav, rate, duty, RiseFall, snr, outRMS)
    [y, Fs, OutLevelChange]=interruptWave(StimulusFile, NoiseFile, ...
        ModulationRate, duty, RiseFall, SNR_dB, OutRMS, InterruptedFilesOut);
    
    % make a silent contralateral noise for monaural presentations
    ContraNoise=zeros(size(y));
    % determine the ear(s) to play out the stimuli
    switch upper(ear)
        case 'L', y=[y ContraNoise];
        case 'R', y=[ContraNoise y];
        case 'B', y=[y y];
        otherwise error('variable ear must be one of L, R or B')
    end
    
    if InterruptedFilesOut
        wavwrite(y, Fs, 'CurrentInterruptedWave');
    end
    
    if ~DEBUG
        % play it out and score it.
        if strcmp(SentenceType,'IEE') || strcmp(SentenceType,'ABC')
            response =     IEEE(5,KeyWords{SentenceIndex},list(SentenceIndex),sentence(SentenceIndex),Fs,duty,y);
        else
            response = ASLscore(3,KeyWords{SentenceIndex},list(SentenceIndex),sentence(SentenceIndex),Fs,duty,y);
        end
    else
        if strcmp(SentenceType,'IEE') || strcmp(SentenceType,'ABC')
            RandomPropCorrect=0.5;
            response=[rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect];
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
    
    % strip out the required number of keywords from the concatenated string
    KW = cell(3,1);
    remnant = char(KeyWords{SentenceIndex});
    for i=1:3
        [KW{i}, remnant]=strtok(remnant);
    end
    
    fout = fopen(OutFile, 'at');
    % print out relevant information
    % fprintf(fout, 'listener,date,sTime,trial,targets,SNR,OutLevelChange,duty,masker,wave,w1,w2,w3,w4,w5,total,rTime,rev');
    fprintf(fout, '\n%s,%s,%s,%d,%s,%+5.1f,%+5.1f,%5.3f,%s,%s,%d,%d,%d,%d,%d,%d,%s', ...
        ListenerName,StartDate,StartTimeString,trial,SentenceDirectory,SNR_dB,OutLevelChange,duty,NoiseFileName,InFileName,...
        response(1),response(2),response(3),response(4),response(5),sum(response),TimeOfResponse);
    
    %% give feedback if required for a practice session
    if TorP=='P'
        PracticeFile = fullfile(UnProcDir, InFileName);
        [unProc, Fp] = wavread(PracticeFile);
        % check if stereo -- if so, take only one channel
        n=size(unProc);
        if n(2)>1
            unProc = unProc(:,1);
        end
        wavplay(unProc, Fp)
        pause(2);
        wavplay(y, Fs)   
        pause(2);
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
    fprintf(fout, 'listener,date,sTime,endTime,type,stimuli,noise,SNR,version,');
    fprintf(fout, 'finish,nCorrect,nKeys,pc,nTrials');
    fprintf(fout, '\n%s,%s,%s,%s,%s,%s,%s,%g,%s', ...
        ListenerName,StartDate,StartTimeString,EndTimeString,...
        SentenceType,SentenceDirectory,NoiseFileName,SNR_dB,VERSION);
    if strcmp(response,'quit')  % test for quitting
        fprintf(fout, ',QUIT');
    else
        fprintf(fout, ',OK');
    end
    fprintf(fout, ',%d,%d,%d,%g,%d\n', ...
        nCorrect,nKeys,nCorrect/nKeys,trial);
else
    fprintf(fout, 'listener,date,sTime,endTime,type,stimuli,noise,SNR,version');
    fprintf(fout, ',finish,uRevs,sdRevs,nRevs,nTrials');
    fprintf(fout, '\n%s,%s,%s,%s,%s,%s,%s,%g,%s', ...
        ListenerName,StartDate,StartTimeString,EndTimeString,...
        SentenceType,SentenceDirectory,NoiseFileName,SNR_dB,VERSION);
    
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
end

fclose(fout);
fclose('all');
set(0,'ShowHiddenHandles','on');
delete(findobj('Type','figure'));
finish; % indicate test is over

function name = construct_filename(SentenceIndicator,list, sentence)
if strcmp(SentenceIndicator([1:3]),'IEE')
    name = sprintf('ieee%02d%c%02d', list, SentenceIndicator(5), sentence);
elseif strcmp(SentenceIndicator([1:3]),'ABC')
    name = sprintf('abc%s%02d%02d', 'f', list, sentence);
else
    name = [SentenceIndicator sprintf('%02d%02d', list, sentence)];
end


