function SpecifiedArgs=AdaptDichoticTestParseArgs(OutFile,varargin)

% There is probably a smarter way to deal with numeric parameters being
% passed and converted, yet still allow the checking of the variable type
% November 2010 -- strategic decision to do it dumbly!

% get arguments for AdaptDichoticInterruptions()

p = inputParser;
p.addParamValue('TestType', 'adaptiveUp', @ischar); % Test procedure (adaptive/fixed)
p.addParamValue('ear', 'B', @ischar); % Tested ear: both (B) or left/right (L/R)
p.addParamValue('SentenceDirectory', 'ASLQ', @ischar); % Target sentences type (e.g. ASLQ/BKB)
p.addParamValue('NoiseFile', 'none', @ischar); % Masker file
p.addParamValue('ModulationRate', 5, @isnumeric); % 
p.addParamValue('SNR_dB', 0, @isnumeric); % start SNR in dB (e.g. 0 or 18 dB SNR) 
p.addParamValue('MaxTrials', 25, @isnumeric); % maximum number of trials
p.addParamValue('ListNumber', 1, @isnumeric); % target test list number
p.addParamValue('start_DC', 0.97, @isnumeric); % start duty cycle
p.addParamValue('TorP', 'T', @ischar); % P= practice block; T= Test block
p.addParamValue('UnProcDir', 'BKBQ', @ischar); % Practice target signals directory
p.addRequired('OutFile', @ischar); % Listener ID
p.addParamValue('StartMessage', @ischar);
p.addParamValue('fixed', 'masker', @ischar);
p.addParamValue('FINAL_TURNS', 6, @isnumeric); % number of reversals
p.addParamValue('SelfResponse', 1, @isnumeric); % use self-response menu [on=1/off=0]


p.parse(OutFile, varargin{:});

SpecifiedArgs=p.Results;

%[TestType, ear, SentenceDirectory, NoiseFile, ModulationRate, SNR_dB, ...
% OutFile, MaxTrials, ListNumber, start_DC, TorP, UnProcDir] ...
