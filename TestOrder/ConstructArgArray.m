%% construct the argument cell array
function ArgArray = ConstructArgArray_SK(s, SS)
%
% go through the specified arguments, convert strings that are numbers to
% strings.
% Future version: skip over unnecessary arguments.
%%%%%ArgArray=cell(1,2*(size(SS,2)-2));
ArgArray=cell(1,size(SS,2));
    for col=3:size(SS,2)
        ArgArray{2*col-5}=SS{1,col};
            maybeNumber = str2double(SS{s,col});
            if isnan(maybeNumber)
                ArgArray{2*col-4}=SS{s,col};
            else
                ArgArray{2*col-4}=maybeNumber;
            end
    end
end