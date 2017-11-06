function ClearAndMakeDir(OutputDir)
[stat, mess, id]=rmdir(OutputDir,'s');
status = mkdir(OutputDir);
if status==0 
   error('Cannot create new output directory');
end