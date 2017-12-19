function varargout = AnnotationTool(varargin)
% ANNOTATIONTOOL MATLAB code for AnnotationTool.fig
%      ANNOTATIONTOOL, by itself, creates a new ANNOTATIONTOOL or raises the existing
%      singleton*.
%
%      H = ANNOTATIONTOOL returns the handle to a new ANNOTATIONTOOL or the handle to
%      the existing singleton*.
%
%      ANNOTATIONTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATIONTOOL.M with the given input arguments.
%
%      ANNOTATIONTOOL('Property','Value',...) creates a new ANNOTATIONTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnnotationTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnnotationTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnnotationTool

% Last Modified by GUIDE v2.5 19-Dec-2017 09:22:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnnotationTool_OpeningFcn, ...
                   'gui_OutputFcn',  @AnnotationTool_OutputFcn, ...
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


% --- Executes just before AnnotationTool is made visible.
function AnnotationTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AnnotationTool (see VARARGIN)

% Choose default command line output for AnnotationTool
handles.output = hObject;
%set(handles.ax_image,'Units','pixels');

handles.fileNames = [];
handles.idxImage = 1;
handles.annotations = struct('filename',{},'folder',{}, 'polygon', {});

set(handles.pb_addPolygon,'Enable','off') 
set(handles.pb_updatePolygons,'Enable','off') 
set(handles.pb_nextImage,'Enable','off') 
set(handles.pb_prevImage,'Enable','off') 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AnnotationTool wait for user response (see UIRESUME)
% uiwait(handles.fig1_AnnotationTool);


% --- Outputs from this function are returned to the command line.
function varargout = AnnotationTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pb_loadFolder.
function pb_loadFolder_Callback(hObject, eventdata, handles)
% hObject    handle to pb_loadFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dirInput = uigetdir;
if dirInput == 0
    return
end

fileNames = dir([dirInput, '/**/*.png']);
if isempty(fileNames)
    h = errordlg('The selected folder does not contain any PNG images','Invalid folder')
else
    handles.fileNames = fileNames;
    handles.idxImage = 1;
    
    set(handles.pb_addPolygon,'Enable','on') 
    set(handles.pb_updatePolygons,'Enable','on') 
    set(handles.pb_nextImage,'Enable','on') 
    set(handles.pb_prevImage,'Enable','on')

    guidata(hObject,handles)
    displayImage(handles)
end


% --- Executes on button press in pb_loadAnnotations.
function pb_loadAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to pb_loadAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%uiopen('load');
[filename, pathname] = uigetfile('*.mat','File Selector');
if filename == 0
    return
end
load(fullfile(pathname,filename));

if ~exist('annotations','var')
    h = errordlg('The selected file does not contain a variable named: annotations','No annotation variable')
else
    
    if ~all(isfield(annotations,{'filename','folder', 'polygon'}))
        h = errordlg({'The selected annotations have an invalid format',...
            'Must be a struct containing the fields: filename, folder, polygon'},'Invalid Annotation format')
    else
        handles.annotations = annotations;
        if exist('idxLatestImage','var')
            if idxLatestImage <= length(handles.fileNames)
                handles.idxImage = idxLatestImage;
            end
        end
    end
end
guidata(hObject,handles)
displayImage(handles)


% --- Executes on button press in pb_saveAnnotations.
function pb_saveAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to pb_saveAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

annotations = handles.annotations;
idxLatestImage = handles.idxImage;

[filename, pathname] = uiputfile('annotation.mat','Save  As');
if filename == 0
    return
end
save(fullfile(pathname,filename),'annotations','idxLatestImage')
% uisave({'annotations','idxLatestImage'},'annotation.mat')


% --- Executes on button press in pb_addPolygon.
function pb_addPolygon_Callback(hObject, eventdata, handles)
% hObject    handle to pb_addPolygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.ax_image);
handlePolygon = impoly(gca);
if isempty(handlePolygon )
    return
end
pos = getPosition(handlePolygon);

file = handles.fileNames(handles.idxImage);
idxMatch = strcmp({handles.annotations.filename}, file.name);
if any(idxMatch)
    handles.annotations(idxMatch).polygon(end+1) = {pos};
else
    annotation.filename = file.name;
    annotation.folder = file.folder;
    annotation.polygon(1) = {pos};
    handles.annotations(end+1) = annotation;
end
guidata(hObject,handles)


% --- Executes on button press in pb_updatePolygons.
function pb_updatePolygons_Callback(hObject, eventdata, handles)
% hObject    handle to pb_updatePolygons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

file = handles.fileNames(handles.idxImage);
idxMatch = strcmp({handles.annotations.filename}, file.name);

if any(idxMatch)
    dataObjs = get(handles.ax_image, 'Children');
    tagObjs = get(dataObjs,'Tag');
    dataObjs = dataObjs(strcmp(tagObjs,'impoly'));
    
    handles.annotations(idxMatch).polygon = {};
    
    for i=1:length(dataObjs)
        api = iptgetapi(dataObjs(i));
        pos = api.getPosition();
        
        handles.annotations(idxMatch).polygon(i) = {pos};
    end
end
guidata(hObject,handles)


% --- Executes on button press in pb_nextImage.
function pb_nextImage_Callback(hObject, eventdata, handles)
% hObject    handle to pb_nextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pb_updatePolygons_Callback(hObject, eventdata, handles)

newIdx = handles.idxImage +1;
if newIdx > length(handles.fileNames)
    h = errordlg('The image index exceeded the number of images in the selected folder','Image index out of range')
else
    handles.idxImage = newIdx;
    guidata(hObject,handles)
    displayImage(handles)
end


% --- Executes on button press in pb_prevImage.
function pb_prevImage_Callback(hObject, eventdata, handles)
% hObject    handle to pb_prevImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pb_updatePolygons_Callback(hObject, eventdata, handles)

newIdx = handles.idxImage - 1;
if newIdx < 1
    h = errordlg('You are already inspecting the first image','Image index out of range')
else
    handles.idxImage = newIdx;
    guidata(hObject,handles)
    displayImage(handles)
end


function displayImage(handles)
if isempty(handles.fileNames)
    h = errordlg('There is not selected an image folder or the selected folder does not contain any PNG images','Invalid image folder')
else
    cla(handles.ax_image)
    file = handles.fileNames(handles.idxImage);
    try
        image = imread([file.folder,'/',file.name]);
    catch ME
        image = zeros(30,40);
    end
    axes(handles.ax_image);
    imshow(image);
    hold on;
    
    textLabel = sprintf('Image number:\r\n %d / %d', handles.idxImage, length(handles.fileNames));
    set(handles.lbl_imageCount, 'String', textLabel);
    
    idxMatch = strcmp({handles.annotations.filename}, file.name);
    if any(idxMatch)
        for i = 1: length(handles.annotations(idxMatch).polygon)
            handlePolygon = impoly(gca, handles.annotations(idxMatch).polygon{i});
        end
    end
    
%     set(gcf,'WindowButtonDownFcn',@ButtonDownFcn)
%     
%     % nest the callback
%     function ButtonDown(hObject, eventdata)
%     % make use of handles
%         get(handles.hFig);  % or whatever
%     end
    
end

% function writePolygon(hObject, pos, handles)
% file = handles.fileNames(handles.idxImage);
% annotation.filename = file.name;
% annotation.folder = file.folder;
% annotation.polygon = pos;       %%%%%%%%%%%%%%%%%%%%%%%% extend here to support multi poly
% 
% idxMatch = strcmp({handles.annotations.filename}, file.name)
% if any(idxMatch)
%     handles.annotations(idxMatch) = annotation;
% else
%     handles.annotations(end+1) = annotation;
% end
% guidata(hObject,handles)
% 
% 
% function getpos(pos, handles)
% %x = getPosition(handle)
% disp(pos)
% %x=x;


% --- Executes on key press with focus on fig1_AnnotationTool and none of its controls.
function fig1_AnnotationTool_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to fig1_AnnotationTool (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

switch eventdata.Key
    case 'rightarrow'
        pb_nextImage_Callback(hObject, eventdata, handles)   
    case 'leftarrow'
        pb_prevImage_Callback(hObject, eventdata, handles)
    case '0'
        pb_addPolygon_Callback(hObject, eventdata, handles)
        
    case 'd'
        pb_nextImage_Callback(hObject, eventdata, handles)
    case 'a'
        pb_prevImage_Callback(hObject, eventdata, handles)
    case 'space'
        pb_addPolygon_Callback(hObject, eventdata, handles)
        
end
