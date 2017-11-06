function varargout = ASLNew2(varargin)
% ASLNew2 MATLAB code for ASLNew2.fig
%      ASLNew2, by itself, creates a new ASLNew2 or raises the existing
%      singleton*.
%
%      H = ASLNew2 returns the handle to a new ASLNew2 or the handle to
%      the existing singleton*.
%
%      ASLNew2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASLNew2.M with the given input arguments.
%
%      ASLNew2('Property','Value',...) creates a new ASLNew2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ASLNew2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ASLNew2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ASLNew2

% Last Modified by GUIDE v2.5 02-Sep-2017 14:58:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ASLNew2_OpeningFcn, ...
                   'gui_OutputFcn',  @ASLNew2_OutputFcn, ...
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


% --- Executes just before ASLNew2 is made visible.
function ASLNew2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ASLNew2 (see VARARGIN)

% param initialisation
handles.response = cell(3,1);
setappdata(gcf, 'sentence_submitted', 0);  
setappdata(gcf, 'correct', 99);

% Choose default command line output for ASLNew2
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% Move the GUI to the center of the screen.
movegui('center'); 

% strip out the required number of keywords, given by varargin{1}, from the concatenated string varargin{2}
KeyWords = cell(3,1);
remnant = char(varargin{2});
for i=1:varargin{1}
  [KeyWords{i}, remnant]=strtok(remnant);
end

% get info for text boxes 
set(handles.TrialNumber_edit, 'String', sprintf('completed %d out of %d', varargin{8},varargin{9}))

% turn on/off GUI items
handles.KW1_tb.Visible = 'Off';
handles.KW2_tb.Visible = 'Off';
handles.KW3_tb.Visible = 'Off';
handles.Clear_pb.Visible = 'Off';
handles.All_pb.Visible = 'Off';
handles.TotalBox_edit.Visible = 'Off';
handles.SentenceResponse_pb.Visible = 'Off';
handles.text16.Visible = 'On';
handles.SentenceResponse_edit.Visible = 'On';
handles.SentenceSubmit_pb.Visible = 'On';

handles.text1.Visible = 'On';
handles.text1.String = 'Type in the sentence that you heard';

% put sentence response box into focus
h = findobj('tag','SentenceResponse_edit');
uicontrol(h);

% play signal
if (varargin{5}==0)
   [y,Fs] = audioread(varargin{6});
   playEm = audioplayer(y, Fs);
   play(playEm);
else
   % wavplay(varargin{7},varargin{5},'sync');
   playEm = audioplayer(varargin{7},varargin{5});
   play(playEm);       
end

 %% collect sentence response

 % initialisation 
sentence_submitted = 0;

% get marking
while ~sentence_submitted
    sentence_submitted = getappdata(gcf, 'sentence_submitted');
    pause(0.05);
end

typed_sentence = getappdata(gcf, 'typed_sentence'); % get a vector with the typed text
handles.SentenceSubmit_pb.Visible = 'Off'; % turn OK button off
handles.SentenceResponse_edit.BackgroundColor = [0.6, 0.6, 0.6]; % change text filed colour
 
 %% check sentence response
handles.text1.String = 'Click on the words you got correct';

% put the key words onto the buttons [only for ASL and BKB]
handles.KW1_tb.String = KeyWords{1};
handles.KW2_tb.String = KeyWords{2};
handles.KW3_tb.String = KeyWords{3};

% turn buttons on
handles.KW1_tb.Visible = 'on';
handles.KW2_tb.Visible = 'on';
handles.KW3_tb.Visible = 'on';
handles.All_pb.Visible = 'on';
handles.Clear_pb.Visible = 'on';
handles.TotalBox_edit.Visible = 'on';
handles.SentenceResponse_pb.Visible = 'on'; 

%% collect sentence marks

% initialisation
correct = 99;
% get marking
while correct == 99
    correct = getappdata(gcf, 'correct');
    pause(0.05);
end 

% turn buttons off
set(handles.TotalBox_edit, 'Visible', 'Off');
handles.KW1_tb.Visible = 'Off';
handles.KW2_tb.Visible = 'Off';
handles.KW3_tb.Visible = 'Off';
handles.All_pb.Visible = 'Off';
handles.Clear_pb.Visible = 'Off';    
handles.text16.Visible = 'Off';
handles.SentenceResponse_edit.Visible = 'Off';
handles.SentenceResponse_pb.Visible = 'Off';

% save final responses for each individual keyword
response(1) = getappdata(gcf, 'response1');
response(2) = getappdata(gcf, 'response2');
response(3) = getappdata(gcf, 'response3');

% save in a handle to use as an output parameter
handles.response = response;

 %% reset buttons for next trial
    set(handles.text1, 'Visible', 'Off');
    %handles.text1.String = 'Type in the sentence that you heard';
    handles.SentenceResponse_edit.String = 'xxxxx';
    
    handles.KW1_tb.String = 'KW1';
    handles.KW2_tb.String = 'KW2';
    handles.KW3_tb.String = 'KW3';
    handles.KW4_tb.String = 'KW4';
    
    handles.KW1_tb.ForegroundColor = [1 0 0];
    handles.KW1_tb.FontWeight = 'light';
    handles.KW1_tb.Value = 0;
    handles.KW2_tb.ForegroundColor = [1 0 0];
    handles.KW2_tb.FontWeight = 'light';   
    handles.KW2_tb.Value = 0;
    handles.KW3_tb.ForegroundColor = [1 0 0];
    handles.KW3_tb.FontWeight = 'light';
    handles.KW3_tb.Value = 0;
    AddUpButtons(handles);    
    
    handles.SentenceResponse_edit.BackgroundColor = [1, 1, 1];
    
    pause(0.5);

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = ASLNew2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.response;
varargout{2} = getappdata(gcf, 'typed_sentence');
%delete(handles.figure1);


function SentenceResponse_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SentenceResponse_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SentenceResponse_edit as text
%        str2double(get(hObject,'String')) returns contents of SentenceResponse_edit as a double
setappdata(gcf, 'typed_sentence', get(handles.SentenceResponse_edit, 'String'));
setappdata(gcf, 'sentence_submitted', 1);

% --- Executes during object creation, after setting all properties.
function SentenceResponse_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SentenceResponse_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SentenceSubmit_pb.
function SentenceSubmit_pb_Callback(hObject, eventdata, handles)
% hObject    handle to SentenceSubmit_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(gcf, 'typed_sentence', get(handles.SentenceResponse_edit, 'String'));
setappdata(gcf, 'sentence_submitted', 1);

% --- Executes on button press in KW1_tb.
function KW1_tb_Callback(hObject, eventdata, handles)
% hObject    handle to KW1_tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KW1_tb
if handles.KW1_tb.Value
    handles.KW1_tb.ForegroundColor = [0 0 0];
    handles.KW1_tb.FontWeight = 'bold';
else
    handles.KW1_tb.ForegroundColor = [1 0 0];
    handles.KW1_tb.FontWeight = 'light';
end
AddUpButtons(handles);

% % % % set(handles.TotalBox_edit, 'String', sprintf('Total= %d', ...
% % % %    get(handles.KW1_tb, 'Value')+get(handles.KW2_tb, 'Value')+get(handles.KW3_tb, 'Value')));

% --- Executes on button press in KW2_tb.
function KW2_tb_Callback(hObject, eventdata, handles)
% hObject    handle to KW2_tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KW2_tb
if handles.KW2_tb.Value
    handles.KW2_tb.ForegroundColor = [0 0 0];
    handles.KW2_tb.FontWeight = 'bold';
else
    handles.KW2_tb.ForegroundColor = [1 0 0];
    handles.KW2_tb.FontWeight = 'light';
end
AddUpButtons(handles);

% % % % set(handles.TotalBox_edit, 'String', sprintf('Total= %d', ...
% % % %    get(handles.KW1_tb, 'Value')+get(handles.KW2_tb, 'Value')+get(handles.KW3_tb, 'Value')));


% --- Executes on button press in KW3_tb.
function KW3_tb_Callback(hObject, eventdata, handles)
% hObject    handle to KW3_tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KW3_tb
if handles.KW3_tb.Value
    handles.KW3_tb.ForegroundColor = [0 0 0];
    handles.KW3_tb.FontWeight = 'bold';
else
    handles.KW3_tb.ForegroundColor = [1 0 0];
    handles.KW3_tb.FontWeight = 'light';
end
AddUpButtons(handles);

% % % % set(handles.TotalBox_edit, 'String', sprintf('Total= %d', ...
% % % %    get(handles.KW1_tb, 'Value')+get(handles.KW2_tb, 'Value')+get(handles.KW3_tb, 'Value')));

% --- Executes on button press in Clear_pb.
function Clear_pb_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.KW1_tb.ForegroundColor = [1 0 0];
handles.KW1_tb.FontWeight = 'light';
handles.KW1_tb.Value = 0;
handles.KW2_tb.ForegroundColor = [1 0 0];
handles.KW2_tb.FontWeight = 'light';   
handles.KW2_tb.Value = 0;
handles.KW3_tb.ForegroundColor = [1 0 0];
handles.KW3_tb.FontWeight = 'light';
handles.KW3_tb.Value = 0;
AddUpButtons(handles);

% --- Executes on button press in SentenceResponse_pb.
function SentenceResponse_pb_Callback(hObject, eventdata, handles)
% hObject    handle to SentenceResponse_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(gcf, 'response1', handles.KW1_tb.Value);
setappdata(gcf, 'response2', handles.KW2_tb.Value);
setappdata(gcf, 'response3', handles.KW3_tb.Value);
setappdata(gcf, 'correct', str2double(handles.TotalBox_edit.String'));



% --- Executes on button press in All_pb.
function All_pb_Callback(hObject, eventdata, handles)
% hObject    handle to All_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.KW1_tb.ForegroundColor = [0 0 0];
handles.KW1_tb.FontWeight = 'bold';
handles.KW1_tb.Value = 1.0;
handles.KW2_tb.ForegroundColor = [0 0 0];
handles.KW2_tb.FontWeight = 'bold';   
handles.KW2_tb.Value = 1.0;
handles.KW3_tb.ForegroundColor = [0 0 0];
handles.KW3_tb.FontWeight = 'bold';
handles.KW3_tb.Value = 1.0;
AddUpButtons(handles);

% % % set(handles.TotalBox_edit, 'String', sprintf('Total= %d', ...
% % %    get(handles.KW1_tb, 'Value')+get(handles.KW2_tb, 'Value')+get(handles.KW3_tb, 'Value')));


function TotalBox_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TotalBox_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TotalBox_edit as text
%        str2double(get(hObject,'String')) returns contents of TotalBox_edit as a double


% --- Executes during object creation, after setting all properties.
function TotalBox_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalBox_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AddUpButtons(handles)
   handles.TotalBox_edit.String = sprintf('Total= %d',...
      handles.KW1_tb.Value...
      + handles.KW2_tb.Value...
      + handles.KW3_tb.Value);

% % % set(handles.TotalBox_edit, 'String', sprintf('Total= %d', ...
% % %    get(handles.KW1_tb, 'Value')+get(handles.KW2_tb, 'Value')+get(handles.KW3_tb, 'Value')));

function TrialNumber_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TrialNumber_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrialNumber_edit as text
%        str2double(get(hObject,'String')) returns contents of TrialNumber_edit as a double


% --- Executes during object creation, after setting all properties.
function TrialNumber_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialNumber_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
