function varargout = Logistic(varargin)
% LOGISTIC M-file for Logistic.fig
%
% Copyright 2011 Varuna De Silva
% I-Lab, CVSSP, University of Surrey
% Guildford
% GU2-7XH
% UK
%
% Email: varunax@gmail.com
%
%
% This work is based on the excellent tutorial by David Arnold
% http://online.redwoods.cc.ca.us/instruct/darnold/diffeq/logistic/logistic
% .pdf
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Logistic_OpeningFcn, ...
                   'gui_OutputFcn',  @Logistic_OutputFcn, ...
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


% --- Executes just before Logistic is made visible.
function Logistic_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Logistic (see VARARGIN)

% Choose default command line output for Logistic
handles.output = hObject;
handles.numFrames = 14;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Logistic wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Logistic_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function C_INP1_Path_Callback(hObject, eventdata, handles)
% hObject    handle to C_INP1_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C_INP1_Path as text
%        str2double(get(hObject,'String')) returns contents of C_INP1_Path as a double


% --- Executes during object creation, after setting all properties.
function C_INP1_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C_INP1_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function C_INP2_Path_Callback(hObject, eventdata, handles)
% hObject    handle to C_INP2_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C_INP2_Path as text
%        str2double(get(hObject,'String')) returns contents of C_INP2_Path as a double


% --- Executes during object creation, after setting all properties.
function C_INP2_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C_INP2_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in C_INP1_Browse.
function C_INP1_Browse_Callback(hObject, eventdata, handles)
% hObject    handle to C_INP1_Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.txt','Select the MOS File');
handles.C_INP1 = fullfile(PathName,FileName);
set(handles.C_INP1_Path,'String',handles.C_INP1);
handles.MOS = dlmread(handles.C_INP1)
guidata(hObject, handles);


% --- Executes on button press in C_INP2_Browse.
function C_INP2_Browse_Callback(hObject, eventdata, handles)
% hObject    handle to C_INP2_Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.txt','Select the METRIC File');
handles.C_INP2 = fullfile(PathName,FileName);
set(handles.C_INP2_Path,'String',handles.C_INP2);
handles.METRIC = dlmread(handles.C_INP2)
guidata(hObject, handles);



% --- Executes on button press in resetBut.
function resetBut_Callback(hObject, eventdata, handles)
% hObject    handle to resetBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes1,'reset');
set(handles.final_params,'String','');
set(handles.final_params2,'String','');
set(handles.min_r,'String','0');
set(handles.max_r,'String','0');
set(handles.est_r,'String','0');
set(handles.est_t0,'String','0');
guidata(hObject, handles); %updates the handles


% --- Executes on button press in plotBut.
function plotBut_Callback(hObject, eventdata, handles)
% hObject    handle to plotBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
 
plot(handles.METRIC,handles.MOS,'o')
%adds a title, x-axis description, and y-axis description


est_t0 = median(handles.METRIC);
xx = handles.METRIC-est_t0;
title('MOS Vs. METRIC')
ylabel('MOS')
xlabel('METRIC')

[max_xx down_idx]= min(xx); 
for idx = 1:size(xx)
    if(xx(idx)<0)
        if(xx(idx)>max_xx)
            max_xx=xx(idx); down_idx = idx;
        end
    end
end
[min_xx up_idx]= max(xx); for idx = 1:size(xx)
    if(xx(idx)>0)
        if(xx(idx)<min_xx)
            min_xx=xx(idx); up_idx = idx;
        end
    end
end

mt0 = (handles.MOS(up_idx)-handles.MOS(down_idx))/(handles.METRIC(up_idx)-handles.METRIC(down_idx));

est_r = 4*mt0;

min_r = est_r/10;
max_r = est_r*10;

set(handles.min_r,'String',num2str(min_r));
set(handles.max_r,'String',num2str(max_r));
set(handles.est_r,'String',num2str(est_r));
set(handles.est_t0,'String',num2str(est_t0));

%Calculate the estimates
guidata(hObject, handles); %updates the handles




function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function est_t0_Callback(hObject, eventdata, handles)
% hObject    handle to est_t0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of est_t0 as text
%        str2double(get(hObject,'String')) returns contents of est_t0 as a double


% --- Executes during object creation, after setting all properties.
function est_t0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to est_t0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function est_r_Callback(hObject, eventdata, handles)
% hObject    handle to est_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of est_r as text
%        str2double(get(hObject,'String')) returns contents of est_r as a double


% --- Executes during object creation, after setting all properties.
function est_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to est_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function min_r_Callback(hObject, eventdata, handles)
% hObject    handle to min_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_r as text
%        str2double(get(hObject,'String')) returns contents of min_r as a double


% --- Executes during object creation, after setting all properties.
function min_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function max_r_Callback(hObject, eventdata, handles)
% hObject    handle to max_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_r as text
%        str2double(get(hObject,'String')) returns contents of max_r as a double


% --- Executes during object creation, after setting all properties.
function max_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in FindFit.
function FindFit_Callback(hObject, eventdata, handles)
% hObject    handle to FindFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

est_r = str2num(get(handles.est_r,'String'));
est_t0 = str2num(get(handles.est_t0,'String'));

min_x = min(handles.METRIC);
max_x = max(handles.METRIC);

min_r = est_r/10;
max_r = est_r*10;

r=linspace(min_r,max_r,40);
t0=linspace(min_x,max_x,40);
[r,t0]=meshgrid(r,t0);

[m,n]=size(r);
e=zeros(size(r));

for i=1:m
for j=1:n
e(i,j)=myerror([r(i,j);t0(i,j)],handles.METRIC,handles.MOS);
end
end

[row col] = find(min(min(e)));


min2=fminsearch(@myerror,[r(col);t0(row)],[],handles.METRIC,handles.MOS);

r=min2(1);
t0=min2(2);

H=1./(1+exp(-r*(handles.METRIC-t0)));

K=(H'*handles.MOS)/(H'*H)

t=linspace(min(handles.METRIC),max(handles.METRIC));
y=K./(1+exp(-r*(t-t0)));
plot(handles.METRIC,handles.MOS,'o',t,y)

s_sq_e = sum_sq_e([r; t0; K;],handles.METRIC,handles.MOS)
y1 = K./(1+exp(-r*(handles.METRIC-t0)));
R = corrcoef(handles.MOS,y1);
C_cof = R(1,2);
RMSE = sqrt(s_sq_e/size(handles.METRIC,1));
finalparams = ['K = ',num2str(K), '  G = ', num2str(r), '  Dm = ', num2str(t0)];
set(handles.final_params,'String',finalparams);
finalparams = ['C = ',num2str(C_cof), '  SSE = ', num2str(s_sq_e), '  RMSE = ', num2str(RMSE)];
set(handles.final_params2,'String',finalparams);

title('Y Vs. X')
ylabel('Y - Values')
xlabel('X - Values')


guidata(hObject, handles); %updates the handles


