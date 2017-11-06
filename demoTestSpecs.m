%% get essential information for running a test
mInputArgs = {'DutyCycle',.27,'SentenceDirectory','ABC','ModulationRate',6, 'Listener','L27','SNR',-6, 'Ear', 'r'};

[TestType, ear, SentenceDirectory, NoiseFile, ModulationRate, SNR_dB, OutFile, MaxTrials, ListNumber, DutyCycle, TorP, UnProcDir] ...
    = TestSpecs(mInputArgs)

