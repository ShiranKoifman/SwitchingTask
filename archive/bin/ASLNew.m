function varargout = ASLNew(varargin)
% ASLNEW MATLAB code for ASLNew.fig
%      ASLNEW, by itself, creates a new ASLNEW or raises the existing
%      singleton*.
%
%      H = ASLNEW returns the handle to a new ASLNEW or the handle to
%      the existing singleton*.
%
%      ASLNEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASLNEW.M with the given input arguments.
%
%      ASLNEW('Property','Value',...) creates a new ASLNEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ASLNew_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ASLNew_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ASLNew

% Last Modified by GUIDE v2.5 02-Sep-2017 11:52:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ASLNew_OpeningFcn, ...
                   'gui_OutputFcn',  @ASLNew_OutputFcn, ...
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


% --- Executes just before ASLNew is made visible.
function ASLNew_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ASLNew (see VARARGIN)

% Choose default command line output for ASLNew
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

handles.response = [];

% UIWAIT makes DigitStreamDualTask wait for user response (see UIRESUME)
uiwait(handles.figure1);

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


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
