function [maskers]=ReadConditions()

%function [maskers, ear, tar_selection, mskr_selection, starts, finals, trials, fRevs]=ReadConditions()
            %1      %2      %3          %4              %5        %6    %7      %8         

% function [targets, maskers, starts, initials, finals, max_trials, catch_trials, warns, fRevs]=ReadConditions()
%% read in the list of masker conditions and associated parameters, 
%% and return appropriate values from the file
%% Also get (separate) list of target conditions 
% TargetLists=robustcsvread('TargetsList.csv');
% nTargets=size(TargetLists,1);
% targets=cell(nTargets-1,1);
% for c=2:nTargets
%     targets{c-1}=TargetLists{c,1};
% end

%% Read maskers:
conditions=robustcsvread('MaskerConditionsList.csv');
nConditions= size(conditions,1);
maskers=cell(nConditions-1,1);

%starts=[]; ear=[]; tar_selection=[]; mskr_selection=[]; ...
%finals=[]; trials=[]; fRevs=[];
% starts=[]; initials=[]; finals=[]; max_trials=[]; catch_trials=[]; 
% warns=[]; fRevs = [];
for c=2:nConditions
    maskers{c-1}=conditions{c,1};
    %ear=[ear str2double(conditions{c,2})];
    %tar_selection=[tar_selection str2double(conditions{c,3})];
    %mskr_selection=[mskr_selection str2double(conditions{c,4})];
    %starts=[starts str2double(conditions{c,5})];
    %finals=[finals str2double(conditions{c,6})];
    %trials=[trials str2double(conditions{c,7})];
    %fRevs=[fRevs str2double(conditions{c,8})];  
end
