function varargout = ASLNew2(varargin)
% ASLNEW2 MATLAB code for ASLNew2.fig
%      ASLNEW2, by itself, creates a new ASLNEW2 or raises the existing
%      singleton*.
%
%      H = ASLNEW2 returns the handle to a new ASLNEW2 or the handle to
%      the existing singleton*.
%
%      ASLNEW2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASLNEW2.M with the given input arguments.
%
%      ASLNEW2('Property','Value',...) creates a new ASLNEW2 or raises the
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

% Last Modified by GUIDE v2.5 02-Sep-2017 13:15:28

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

% Choose default command line output for ASLNew2
handles.output = hObject;

% % % % % % % % % Update handles structure
% % % % % % % % guidata(hObject, handles);

% Move the GUI to the center of the screen.
movegui('center'); 

% param initialisation
handles.response = cell(3,1);
setappdata(gcf, 'sentence_submitted', 0);  
setappdata(gcf, 'correct', 0);

%% [response, TypedSentence] = ASLNew2(KeyWords{SentenceIndex},...
%%                                     list(SentenceIndex),sentence(SentenceIndex),Fs,duty,y);   

% % % if length(varargin{1})>1
% % %     for index=1:2:length(varargin{1})
% % %         if length(varargin{1}) < index+1
% % %             break;
% % %         elseif strcmpi('KeyWords', varargin{1}(index)) || strcmpi('KeyWords', varargin{1}(index))
% % %             handles.KeyWords = char(varargin{1}(index+1));
% % %         elseif strcmpi('list', varargin{1}(index)) || strcmpi('list', varargin{1}(index))
% % %             handles.list.string = char(varargin{1}(index+1));
% % %         elseif strcmpi('sentence', varargin{1}(index)) || strcmpi('sentence', varargin{1}(index))
% % %             handles.sentence.String = char(varargin{1}(index+1));
% % %         elseif strcmpi('Fs', varargin{1}(index)) || strcmpi('Fs', varargin{1}(index))
% % %             handles.Fs.String = char(varargin{1}(index+1));
% % %         elseif strcmpi('duty', varargin{1}(index)) || strcmpi('duty', varargin{1}(index))
% % %             handles.duty.String = char(varargin{1}(index+1));   
% % %         elseif strcmpi('y', varargin{1}(index)) || strcmpi('y', varargin{1}(index))
% % %             handles.y.String = char(varargin{1}(index+1));            
% % %         else
% % %             error('Unrecognised parameter %s\n', char(varargin{1}(index)));
% % %         end
% % %     end
% % % end
% % % 

 KW = varargin{1};
 handles.KeyWords = KW;
 
 Fs =  varargin{4};
 handles.Fs = Fs;
  
 y = varargin{6};
 handles.y = y;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DigitStreamDualTask wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ASLNew2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.response;
varargout{2} = handles.SentenceResponse_edit;
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
   handles.TotalBox_edit.String = sprintf('%d', ...
      handles.KW1_tb.Value...
      + handles.KW2_tb.Value...
      + handles.KW3_tb.Value);


% --- Executes on button press in OKButton_pb.
function OKButton_pb_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% strip out the required number of keywords, given by varargin{1}, from the concatenated string varargin{2}

KW =  handles.KeyWords;
Fs =  handles.Fs;
y =  handles.y;


KeyWords = cell(3,1);
remnant = char(KW);
for i=1:3
  [KeyWords{i}, remnant]=strtok(remnant);
end

% % % % get info for text boxes   
% % % if (varargin{5}==0)
% % % set(handles.WAVfile, 'String', varargin{6});
% % % else 
% % % set(handles.WAVfile, 'String', num2str(varargin{6},'%5.2f'));
% % % end
% % % set(handles.ListSentence, 'String', sprintf('List %d   Sentence %d', varargin{3},varargin{4}));

% % % handles.WAVfile.Visible = 'Off';
% % % handles.ListSentence.Visible = 'Off';

handles.OKButton_pb.Visible = 'Off';
handles.text1.Visible = 'Off';
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

% put sentence response box into focus
h = findobj('tag','SentenceResponse_edit');
uicontrol(h);

% play signal
if (Fs==0)
   [y,Fs] = audioread(y);
   playEm = audioplayer(y, Fs);
   play(playEm);
   %[y,Fs,bits] = wavread(varargin{6});
   %wavplay(y,Fs,'sync');
else
   % wavplay(varargin{7},varargin{5},'sync');
   playEm = audioplayer(y,Fs);
   play(playEm);       
end

 %% collect sentence response
 
sentence_submitted = 0;

% get marking
while ~sentence_submitted
    sentence_submitted = getappdata(gcf, 'sentence_submitted');
    pause(0.05);
end

typed_sentence = getappdata(gcf, 'typed_sentence');
handles.SentenceSubmit_pb.Visible = 'Off';
handles.SentenceResponse_edit.BackgroundColor = [0.6, 0.6, 0.6];
 
 %% check sentence response
handles.text2.String = 'Click on the words you got correct';

% put the key words onto the buttons - % really want to adjust
% according to number of KW, but assume only BEL sentences for now
handles.KW1_tb.String = KeyWords{1};
handles.KW2_tb.String = KeyWords{2};
handles.KW3_tb.String = KeyWords{3};
handles.KW1_tb.Visible = 'on';
handles.KW2_tb.Visible = 'on';
handles.KW3_tb.Visible = 'on';
handles.All_pb.Visible = 'on';
handles.Clear_pb.Visible = 'on';
handles.TotalBox_edit.Visible = 'on';
handles.SentenceResponse_pb.Visible = 'on'; 

%% collect sentence marks

correct = 0;
% get marking
while correct == 0
    correct = getappdata(gcf, 'correct');
    pause(0.05);
end 

set(handles.TotalBox_edit, 'Visible', 'Off');
handles.KW1_tb.Visible = 'Off';
handles.KW2_tb.Visible = 'Off';
handles.KW3_tb.Visible = 'Off';
handles.All_pb.Visible = 'Off';
handles.Clear_pb.Visible = 'Off';    
handles.text16.Visible = 'Off';
handles.SentenceResponse_edit.Visible = 'Off';
handles.SentenceResponse_pb.Visible = 'Off';

% responses for each individual KW
response(1) = getappdata(gcf, 'response1');
response(2) = getappdata(gcf, 'response2');
response(3) = getappdata(gcf, 'response3');

handles.response = response;


guidata(hObject, handles);
uiresume(handles.figure1);
