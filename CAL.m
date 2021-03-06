function correct = CAL(varargin)
% call with total number of key words, followed by key words in a single string separated by white space
% Then a list and sentence number, and then the full name of the file being played (including directory)
% The number of key words is not used in this implementation (could be used to allow a varying number)
% but simply to indicate the GUI needs launching.
% Returns a vector of zeros and ones to indicate which key words were correctly perceived

%
% varargin   1      2        3     4      5          6                               7
% y=CAL(4,KeyWords{2},list,sentence,Fs,['supremes.wav' or level of difficulty], y])
% if Fs=0, the name of a wavfile follows
% if Fs>0, this is the sampling frequency for the vector specified last to play
% In this case, varargin{6} specifies a level of dicciculty numerically

% CAL Application M-file for CAL.fig
%    FIG = CAL launch CAL GUI.
%    CAL('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 26-Apr-2013 18:29:56

if nargin == 0 | isnumeric(varargin{1}) % LAUNCH GUI

   % strip out the required number of keywords, given by varargin{1}, from the concatenated string varargin{2}
   KeyWords = cell(4,1);
   remnant = char(varargin{2});
   for i=1:varargin{1}
      [KeyWords{i}, remnant]=strtok(remnant);
   end
         
   fig = openfig(mfilename,'reuse');
    % Move the GUI to the center of the screen.
    movegui(fig,'center')

    % Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

   % set the strings onto the appropriate toggle button
   set(handles.togglebutton1, 'String', KeyWords{1});
   set(handles.togglebutton2, 'String', KeyWords{2});
   set(handles.togglebutton3, 'String', KeyWords{3});
   set(handles.togglebutton4, 'String', KeyWords{4});
   if (varargin{5}==0)
      set(handles.WAVfile, 'String', varargin{6});
   else 
      set(handles.WAVfile, 'String', num2str(varargin{6},'%5.2f'));
   end
   set(handles.ListSentence, 'String', sprintf('List %d   Sentence %d', varargin{3},varargin{4}));
   % reset all the font controls and total number of correct
   set(handles.togglebutton1, 'ForegroundColor', [1 0 0]);
   set(handles.togglebutton1, 'FontWeight', 'light');
   set(handles.togglebutton1, 'Value', 0);
   set(handles.togglebutton2, 'ForegroundColor', [1 0 0]);
   set(handles.togglebutton2, 'FontWeight', 'light');   
   set(handles.togglebutton2, 'Value', 0);
   set(handles.togglebutton3, 'ForegroundColor', [1 0 0]);
   set(handles.togglebutton3, 'FontWeight', 'light');
   set(handles.togglebutton3, 'Value', 0);
   set(handles.togglebutton4, 'ForegroundColor', [1 0 0]);
   set(handles.togglebutton4, 'FontWeight', 'light');
   set(handles.togglebutton4, 'Value', 0);

   AddUpButtons(handles);
   pause(0.3)
   if (varargin{5}==0)
      [y,Fs,bits] = wavread(varargin{6});
      wavplay(y,Fs,'sync');
   else
      wavplay(varargin{7},varargin{5},'sync');
   end
 
   
   % Wait for callbacks to run and window to be dismissed:
   uiwait(fig);

   % UIWAIT might have returned because the window was deleted using
   % the close box - in that case, return 'quit' as the answer, and
   % don't bother deleting the window!
   if ~ishandle(fig)
	   correct = 'quit';
   else
  	   % otherwise, we got here because the user pushed the 'OK' button.
	   % retrieve the latest copy of the 'handles' struct, and return the answers.
	   % Also, we need to delete the window (maybe).
	   handles = guidata(fig);
      correct(1) = get(handles.togglebutton1, 'Value');
      correct(2) = get(handles.togglebutton2, 'Value');
      correct(3) = get(handles.togglebutton3, 'Value');
      correct(4) = get(handles.togglebutton4, 'Value');

%	   delete(fig);
   end
  
  
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

% --------------------------------------------------------------------
function varargout = togglebutton1_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.togglebutton1.
if (get(handles.togglebutton1, 'Value'))
   set(handles.togglebutton1, 'ForegroundColor', [0 0 0]);
   set(handles.togglebutton1, 'FontWeight', 'bold');
else 
   set(handles.togglebutton1, 'ForegroundColor', [1 0 0]);
   set(handles.togglebutton1, 'FontWeight', 'light');
end
AddUpButtons(handles);

% --------------------------------------------------------------------
function varargout = togglebutton2_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.togglebutton2.
if (get(handles.togglebutton2, 'Value'))
   set(handles.togglebutton2, 'ForegroundColor', [0 0 0]);
   set(handles.togglebutton2, 'FontWeight', 'bold');
else 
   set(handles.togglebutton2, 'ForegroundColor', [1 0 0]);
   set(handles.togglebutton2, 'FontWeight', 'light');
end
AddUpButtons(handles);

% --------------------------------------------------------------------
function varargout = togglebutton3_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.togglebutton3.
if (get(handles.togglebutton3, 'Value'))
   set(handles.togglebutton3, 'ForegroundColor', [0 0 0]);
   set(handles.togglebutton3, 'FontWeight', 'bold');
else 
   set(handles.togglebutton3, 'ForegroundColor', [1 0 0]);
   set(handles.togglebutton3, 'FontWeight', 'light');
end
AddUpButtons(handles);

% --------------------------------------------------------------------
function varargout = togglebutton4_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.togglebutton4.
if (get(handles.togglebutton4, 'Value'))
   set(handles.togglebutton4, 'ForegroundColor', [0 0 0]);
   set(handles.togglebutton4, 'FontWeight', 'bold');
else 
   set(handles.togglebutton4, 'ForegroundColor', [1 0 0]);
   set(handles.togglebutton4, 'FontWeight', 'light');
end
AddUpButtons(handles);



% --------------------------------------------------------------------
function varargout = Allbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.Allbutton.
set(handles.togglebutton1, 'ForegroundColor', [0 0 0]);
set(handles.togglebutton1, 'FontWeight', 'bold');
set(handles.togglebutton1, 'Value', 1.0);
set(handles.togglebutton2, 'ForegroundColor', [0 0 0]);
set(handles.togglebutton2, 'FontWeight', 'bold');   
set(handles.togglebutton2, 'Value', 1.0);
set(handles.togglebutton3, 'ForegroundColor', [0 0 0]);
set(handles.togglebutton3, 'FontWeight', 'bold');
set(handles.togglebutton3, 'Value', 1.0);
set(handles.togglebutton4, 'ForegroundColor', [0 0 0]);
set(handles.togglebutton4, 'FontWeight', 'bold');
set(handles.togglebutton4, 'Value', 1.0);

AddUpButtons(handles);

% --------------------------------------------------------------------
function varargout = Nonebutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.Nonebutton.
set(handles.togglebutton1, 'ForegroundColor', [1 0 0]);
set(handles.togglebutton1, 'FontWeight', 'light');
set(handles.togglebutton1, 'Value', 0);
set(handles.togglebutton2, 'ForegroundColor', [1 0 0]);
set(handles.togglebutton2, 'FontWeight', 'light');   
set(handles.togglebutton2, 'Value', 0);
set(handles.togglebutton3, 'ForegroundColor', [1 0 0]);
set(handles.togglebutton3, 'FontWeight', 'light');
set(handles.togglebutton3, 'Value', 0);
set(handles.togglebutton4, 'ForegroundColor', [1 0 0]);
set(handles.togglebutton4, 'FontWeight', 'light');
set(handles.togglebutton4, 'Value', 0);
AddUpButtons(handles);

% --------------------------------------------------------------------
function varargout = OKbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.OKbutton.
uiresume(handles.figure2);


function AddUpButtons(handles)
   set(handles.TotalBox, 'String', sprintf('Total= %d', ...
      get(handles.togglebutton1, 'Value')...
      +get(handles.togglebutton2, 'Value')...
      +get(handles.togglebutton3, 'Value')...
      +get(handles.togglebutton4, 'Value')...
  ));
