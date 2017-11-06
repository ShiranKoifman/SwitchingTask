% function summaries(InputDir, ExcelOutput, NameDirInFile)

InputDir = 'speech';
d=dir(fullfile(InputDir, '*.'));

for i=3:length(d)
    summaries(fullfile(InputDir,d(i).name), d(i).name, 1) ;
end