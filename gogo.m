% SentInNoiseAdaptive(SentenceDirectory,NoiseFile,OutFile,ListNumber,MaxTrials)
SubjectCode='TryOut111';
MaxTrials=10;

% AdaptInterruptions('SentenceDirectory', 'IEEEm_noise_07','Listener', SubjectCode,'ListNumber',1)


% return

AdaptInterruptions('SentenceDirectory', 'IEEEm_noise_07', 'TorP', 'P', 'DutyCycle', 1, 'TorP', 'P', 'Listener', SubjectCode,'ListNumber',2.5)

