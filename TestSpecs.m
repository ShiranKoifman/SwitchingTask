function varargout = TestSpecs(varargin)
%
%   output variables:
%   1: T type:   'fixed' or 'adaptiveup'
%   2: Ear to T: e.g., 'Both')
%   3: Target directory: e.g., 'IEEE'
%   4: Masker: e.g., 'SpchNz.wav'
%   5: Modulation rate in Hz
%   6: SNR
%   7: Listener code: e.g., LGP01
%   8: Maximum number of trials
%   9: t or p
%  10: unprocessed files directory
%  11: Test trial (T) / practice trial (P) button
%  12: Practice target signals directory
%  13: Fixed signal level / fixed masker level (1/0)
%  14: Self-response menu on/off (1/0)
%
% TESTSPECS Mixed-file for TestSpecs.fig
%      TESTSPECS, by itself, creates alternate new TESTSPECS or raises the existing
%      singleton*.
%
%      H = TESTSPECS returns the handle to alternate new TESTSPECS or the handle to
%      the existing singleton*.
%
%      TESTSPECS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTSPECS.Mixed with the given input arguments.
%
%      TESTSPECS('Property','Value',...) creates alternate new TESTSPECS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TestSpecs_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TestSpecs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TestSpecs

% Last Modified by GUIDE v2.5 04-Sep-2017 11:42:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TestSpecs_OpeningFcn, ...
                   'gui_OutputFcn',  @TestSpecs_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TestSpecs is made visible.
function TestSpecs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TestSpecs (see VARARGIN)

% Move the GUI to the center of the screen.
movegui(hObject,'center')

% Choose default command line output for TestSpecs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% process any arguments to re-set the TestSpecs GUI
if length(varargin{1})>1
    for index=1:2:length(varargin{1})
        if length(varargin{1}) < index+1
            break;
        elseif strcmp('ModulationRate', varargin{1}(index))
            set(handles.ModulationRate,'String', num2str(cell2mat(varargin{1}(index+1))));           
        elseif strcmp('NoiseFile', varargin{1}(index))
            % set(handles.MaskerFile,'String',['Maskers\' char(varargin{1}(index+1)) '.wav']); 
            set(handles.MaskerFile,'String',[ensureWavExtension(char(varargin{1}(index+1)))]);            
            index=get(handles.MaskerFile, 'value');
        elseif strcmp('SentenceDirectory', varargin{1}(index))
            set(handles.OrderFile,'String',char(varargin{1}(index+1)));
            set(handles.UnProcDir,'String',char(varargin{1}(index+1)));
        elseif strcmp('ListNumber', varargin{1}(index))
            set(handles.ListNumber,'String',num2str(cell2mat(varargin{1}(index+1)))); 
        elseif strcmp('Listener', varargin{1}(index))
            set(handles.ListenerCode,'String',char(varargin{1}(index+1)));
        elseif strcmp('FinalStep', varargin{1}(index))
            set(handles.DutyCycle,'String',num2str(cell2mat(varargin{1}(index+1))));  
        elseif strcmp('MaxTrials', varargin{1}(index))
            set(handles.MaxTrialsSpec,'String',num2str(cell2mat(varargin{1}(index+1))));
        elseif strcmp('SNR', varargin{1}(index))
            set(handles.StartLevel,'String',num2str(cell2mat(varargin{1}(index+1)))); 
        elseif strcmp('DutyCycle', varargin{1}(index))
            set(handles.DutyCycle,'String',num2str(cell2mat(varargin{1}(index+1))));  
        elseif strcmp('TestType', varargin{1}(index))
            if strcmp('adaptiveUp', char(varargin{1}(index+1)))
                set(handles.AdaptiveUp,'Value',1);
            elseif strcmp('adaptiveDown', char(varargin{1}(index+1)))
                set(handles.AdaptiveDown,'Value',1);
            else
                set(handles.Fixed,'Value',1)
            end  
        elseif strcmp('Ear', varargin{1}(index))
            if strcmp('A', char(varargin{1}(index+1)))
                set(handles.Alternate,'Value',1);
            elseif strcmp('B', char(varargin{1}(index+1)))
                set(handles.Both,'Value',1);   
            elseif strcmp('L', char(varargin{1}(index+1)))
                set(handles.Left,'Value',1);        
            elseif strcmp('R', char(varargin{1}(index+1)))
                set(handles.Right,'Value',1);   
            elseif strcmp('l', char(varargin{1}(index+1)))
                set(handles.DichoticL,'Value',1)
            elseif strcmp('M', char(varargin{1}(index+1)))
                set(handles.Mixed,'Value',1)                
            else
                set(handles.DichoticR,'Value',1)
            end
        elseif strcmp('TorP', varargin{1}(index))
            if strcmp('P', char(varargin{1}(index+1)))
                set(handles.P,'Value',1);
            elseif strcmp('T', char(varargin{1}(index+1)))
                set(handles.T,'Value',1)
            end 
        elseif strcmp('FixedSignal', varargin{1}(index))
            if strcmp('FixedTarget', char(varargin{1}(index+1)))
                set(handles.FixedTarget,'Value',1);
            else
                set(handles.FixedMasker,'Value',1)
            end
        elseif strcmp('SelfResponse_rb', char(varargin{1}(index+1)))
                set(handles.SelfResponse_rb,'Value',1);
        else
            error('Illegal option: %s -- Legal options are:\nModulationRate\nNoiseFile\nSentenceDirectory\nListNumber\nListener\nFinalStep\nMaxTrials\nSNR\nDutyCycle', ...
                char(varargin{1}(index)));
        end
    end
end

% put all conditions possibilities into dropdown box
[maskers]=ReadConditions();
set(handles.MaskerFile, 'String', maskers);
index=get(handles.MaskerFile,'Value');

% UIWAIT makes TestSpecs wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TestSpecs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.AorF; % Adaptive or fixed method
varargout{2} = handles.Ear;  
varargout{3} = handles.O;
varargout{4} = handles.Mixed; % Masker file name
varargout{5} = handles.rate;
varargout{6} = handles.SNR;
varargout{7} = handles.Left; % Listener ID
varargout{8} = handles.Max; % Max bumber of trials
varargout{9} = handles.nList; % Test list number
varargout{10} = handles.dutycycle;
varargout{11} = handles.TorP; % Test or practice run
varargout{12} = handles.unprocdir; % Practice target signals directory
varargout{13} = handles.FixedSignal;
varargout{14} = handles.SelfResponse_rb; % Self-response menu on/off

% The figure can be deleted now
delete(handles.figure1);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function StartLevel_Callback(hObject, eventdata, handles)
% hObject    handle to StartLevel (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartLevel as text
%        str2double(get(hObject,'String')) returns contents of StartLevel as alternate double


% --- Executes during object creation, after setting all properties.
function StartLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartLevel (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OrderFile_Callback(hObject, eventdata, handles)
% hObject    handle to OrderFile (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OrderFile as text
%        str2double(get(hObject,'String')) returns contents of OrderFile as alternate double


% --- Executes during object creation, after setting all properties.
function OrderFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OrderFile (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TestTrials_Callback(hObject, eventdata, handles)
% hObject    handle to TestTrials (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TestTrials as text
%        str2double(get(hObject,'String')) returns contents of TestTrials as alternate double


% --- Executes during object creation, after setting all properties.
function TestTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestTrials (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaskerFile_Callback(hObject, eventdata, handles)
% hObject    handle to MaskerFile (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskerFile as text
%        str2double(get(hObject,'String')) returns contents of MaskerFile as alternate double
[maskers]=ReadConditions();
index=get(handles.MaskerFile,'Value');

handles.maskerfilename=get(hObject,'String');
guidata(hObject, handles); % Save the updated structure


% --- Executes during object creation, after setting all properties.
function MaskerFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskerFile (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ListenerCode_Callback(hObject, eventdata, handles)
% hObject    handle to ListenerCode (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListenerCode as text
%        str2double(get(hObject,'String')) returns contents of ListenerCode as alternate double


% --- Executes during object creation, after setting all properties.
function ListenerCode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListenerCode (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.AdaptiveUp,'Value')
    handles.AorF='adaptiveUp';
elseif get(handles.AdaptiveDown,'Value')
    handles.AorF='adaptiveDown'; 
else get(handles.Fixed,'Value')
    handles.AorF='fixed';
end

% value for ear
if get(handles.Both,'Value')
    handles.Ear='B';
elseif get(handles.Left,'Value')
    handles.Ear='L';
elseif get(handles.Right,'Value')
    handles.Ear='R';
elseif get(handles.Alternate,'Value')
    handles.Ear='A';  
elseif get(handles.DichoticR,'Value')
    handles.Ear='r';    
elseif get(handles.DichoticL,'Value')
    handles.Ear='l';   
elseif get(handles.Mixed,'Value')
    handles.Ear='M';       
else
    handles.Ear='Other';
end

% value for T type
if get(handles.T,'Value')
    handles.TorP='T';
elseif get(handles.P,'Value')
    handles.TorP='P';
end

% value for fixed signal sound level (target/masker)
if get(handles.FixedTarget,'Value')
    handles.FixedSignal='target';
else get(handles.FixedMasker,'Value')
    handles.FixedSignal='masker';
end


handles.O=get(handles.OrderFile,'String');
handles.Mixed=get(handles.MaskerFile,'String');
handles.Mixed=handles.Mixed{get(handles.MaskerFile,'Value')};
handles.SNR=str2num(get(handles.StartLevel,'String'));
handles.Left=get(handles.ListenerCode,'String');
handles.Max=str2num(get(handles.MaxTrialsSpec,'String'));
handles.nList=str2num(get(handles.ListNumber,'String'));
handles.rate=str2num(get(handles.ModulationRate,'String'));
handles.dutycycle=str2num(get(handles.DutyCycle,'String'));
handles.unprocdir=get(handles.UnProcDir,'String');
handles.SelfResponse_rb=get(handles.SelfResponse_rb,'Value');

guidata(hObject, handles); % Save the updated structure
uiresume(handles.figure1);

% --------------------------------------------------------------------
function AdaptiveOrFixed_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to AdaptiveOrFixed (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.AorF=lower(get(hObject,'Tag'))   % Get Tag of selected object

function MaxTrialsSpec_Callback(hObject, eventdata, handles)
% hObject    handle to MaxTrialsSpec (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxTrialsSpec as text
%        str2double(get(hObject,'String')) returns contents of MaxTrialsSpec as alternate double


% --- Executes during object creation, after setting all properties.
function MaxTrialsSpec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxTrialsSpec (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ListNumber_Callback(hObject, eventdata, handles)
% hObject    handle to ListNumber (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListNumber as text
%        str2double(get(hObject,'String')) returns contents of ListNumber as alternate double


% --- Executes during object creation, after setting all properties.
function ListNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListNumber (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DutyCycle_Callback(hObject, eventdata, handles)
% hObject    handle to DutyCycle (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DutyCycle as text
%        str2double(get(hObject,'String')) returns contents of DutyCycle as alternate double


% --- Executes during object creation, after setting all properties.
function DutyCycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DutyCycle (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ModulationRate_Callback(hObject, eventdata, handles)
% hObject    handle to ModulationRate (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ModulationRate as text
%        str2double(get(hObject,'String')) returns contents of ModulationRate as alternate double


% --- Executes during object creation, after setting all properties.
function ModulationRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ModulationRate (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function UnProcDir_Callback(hObject, eventdata, handles)
% hObject    handle to UnProcDir (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UnProcDir as text
%        str2double(get(hObject,'String')) returns contents of UnProcDir as alternate double


% --- Executes during object creation, after setting all properties.
function UnProcDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UnProcDir (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to UnProcDir (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UnProcDir as text
%        str2double(get(hObject,'String')) returns contents of UnProcDir as alternate double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UnProcDir (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in T.
function T_Callback(hObject, eventdata, handles)
% hObject    handle to T (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T


% --- Executes on button press in T.
function P_Callback(hObject, eventdata, handles)
% hObject    handle to T (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T


% % --- Executes on selection change in InterruptedEar.
% function InterruptedEar_Callback(hObject, eventdata, handles)
% % hObject    handle to InterruptedEar (see GCBO)
% % eventdata  reserved - to be defined in alternate future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% index=get(handles.InterruptedEar,'Value'); % interrupted ear
% handles.EarI=get(hObject,'String');
% % Hints: contents = cellstr(get(hObject,'String')) returns InterruptedEar contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from InterruptedEar


% % --- Executes during object creation, after setting all properties.
% function InterruptedEar_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to InterruptedEar (see GCBO)
% % eventdata  reserved - to be defined in alternate future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have alternate white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% 
% % --- Executes on selection change in AlternatedEar.
% function AlternatedEar_Callback(hObject, eventdata, handles)
% % hObject    handle to AlternatedEar (see GCBO)
% % eventdata  reserved - to be defined in alternate future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% %index=get(handles.EarA,'Value'); %altenated ear
% %index=get(handles.EarA,'Value');
% % Hints: contents = cellstr(get(hObject,'String')) returns AlternatedEar contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from AlternatedEar
% 
% 
% % --- Executes during object creation, after setting all properties.
% function AlternatedEar_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to AlternatedEar (see GCBO)
% % eventdata  reserved - to be defined in alternate future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have alternate white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% % --- Executes on button press in Interrupted.
% function Interrupted_Callback(hObject, eventdata, handles)
% % hObject    handle to Interrupted (see GCBO)
% % eventdata  reserved - to be defined in alternate future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of Interrupted


% --- Executes on button press in Right.
function Right_Callback(hObject, eventdata, handles)
% hObject    handle to Right (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Right


% --- Executes on button press in Left.
function Left_Callback(hObject, eventdata, handles)
% hObject    handle to Left (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Left


% --- Executes on button press in Both.
function Both_Callback(hObject, eventdata, handles)
% hObject    handle to Both (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Both



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to DutyCycle (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DutyCycle as text
%        str2double(get(hObject,'String')) returns contents of DutyCycle as alternate double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DutyCycle (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in right.
function DichoticR_Callback(hObject, eventdata, handles)
% hObject    handle to right (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of right


% --- Executes on button press in left.
function DichoticL_Callback(hObject, eventdata, handles)
% hObject    handle to left (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of left


% --- Executes on button press in Mixed.
function Mixed_Callback(hObject, eventdata, handles)
% hObject    handle to Mixed (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Mixed



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to ModulationRate (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ModulationRate as text
%        str2double(get(hObject,'String')) returns contents of ModulationRate as alternate double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ModulationRate (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have alternate white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Alternate.
function Alternate_Callback(hObject, eventdata, handles)
% hObject    handle to Alternate (see GCBO)
% eventdata  reserved - to be defined in alternate future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Alternate


% --- Executes on button press in SelfResponse_rb.
function SelfResponse_rb_Callback(hObject, eventdata, handles)
% hObject    handle to SelfResponse_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelfResponse_rb
