function varargout = GUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes6

%% 载入图像
% --- Executes on button press in loadpicture.
function loadpicture_Callback(hObject, eventdata, handles)

global Predictor;
[filename, pathname] = uigetfile({'*.bmp';'*.jpg'},'读取图片文件'); %选择图片文件
if isequal(filename,0)   %判断是否选择
   msgbox('没有选择任何图片');
else
   pathfile=fullfile(pathname, filename);  %获得图片路径
%    Mat_=imread(pathfile);
%    Predictor.Mat=imresize(Mat_,[240 320]);
   Predictor.Mat=imread(pathfile);
   Predictor.STATE=0;
   axes(handles.src_picture);
   imshow(Predictor.Mat);
end
imwrite(Predictor.Mat,'Temporary\org.bmp');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over loadpicture.
function loadpicture_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to loadpicture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% cnn区域建议
% --- Executes on button press in cnn_region_proposal.
function cnn_region_proposal_Callback(hObject, eventdata, handles)

global Predictor;
load myRCNN.mat
DrawMat=draw(Predictor.Mat,myRCNN);
axes(handles.selective_search);
imshow(DrawMat);
imwrite(DrawMat,'picture_save\cnn区域建议.bmp');

%% 边缘提取
% --- Executes on button press in canny.
function canny_Callback(hObject, eventdata, handles)
% hObject    handle to canny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Predictor;
imgCanny = edge_canny(Predictor.Mat,[5,5],1.4,0.9,0.65); % my function.
axes(handles.canny_edge);
imshow(imgCanny);
imwrite(imgCanny,'Temporary\imgCanny.bmp');

%% 图像分割
% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Predictor;
imgf = fenge(Predictor.Mat); %图像分割函数
axes(handles.fege);
imshow(imgf);
imwrite(imgf,'Temporary\imgSeg.jpg');
pic_1=imread('Temporary\org.bmp');
pic_2=imread('Temporary\imgSeg.jpg');
if ndims(pic_1) == 3
    pic1 = rgb2gray(pic_1);
else
    pic1 = pic_1;
end
if ndims(pic_2) == 3
    pic2 = rgb2gray(pic_2);
else
    pic2 = pic_2;
end
DrawMat=diejia(pic1,pic2);
imwrite(DrawMat,'Temporary\imgSegSpp.bmp');

%% 载入手工标记的图像
function pushbutton11_Callback(hObject, eventdata, handles)
global Pr;
[filename, pathname] = uigetfile({'*.bmp';'*.jpg';'*.png'},'读取图片文件'); %选择图片文件
if isequal(filename,0)   %判断是否选择
   msgbox('没有选择任何图片');
else
   pathfile=fullfile(pathname, filename);  %获得图片路径
   Pr.Mat=imread(pathfile);
   Pr.STATE=0;
   axes(handles.true);
   imshow(Pr.Mat);
end

%% 基于图像分割的区域建议
function fenge_suggest_Callback(hObject, eventdata, handles)
global Predictor;
load myRCNN_fenge.mat
img=imread('Temporary\imgSegSpp.bmp');
DrawMat=draw(img,myRCNN_fenge);
axes(handles.denge_suggest);
imshow(DrawMat);
imwrite(DrawMat,'picture_save\图像分割的区域建议.bmp');

%% 基于边缘提取的区域建议
function canny_suggest_Callback(hObject, eventdata, handles)
global Predictor;
load myRCNN_canny.mat
img=imread('Temporary\imgCannySpp.bmp');
DrawMat=draw(img,myRCNN_canny);
axes(handles.axes30);
imshow(DrawMat);
imwrite(DrawMat,'picture_save\边缘提取图像的区块建议.bmp');
 
%% 获得边缘提取图像与原图像的叠加图像
function canny_diejia_Callback(hObject, eventdata, handles)
global Predictor;
pic_1=imread('Temporary\org.bmp');
pic_2=imread('Temporary\imgCanny.bmp');
if ndims(pic_1) == 3
    pic1 = rgb2gray(pic_1);
else
    pic1 = pic_1;
end
if ndims(pic_2) == 3
    pic2 = rgb2gray(pic_2);
else
    pic2 = pic_2;
end
pic2=pic2*255;
DrawMat=diejia(pic1,pic2);
axes(handles.axes29);
imshow(DrawMat);
imwrite(DrawMat,'Temporary\imgCannySpp.bmp');

%% 将彩色的jpg 修改为黑白的bmp
% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rgb;
[filename, pathname] = uigetfile({'*.jpg'},'读取图片文件'); %选择图片文件
if isequal(filename,0)   %判断是否选择
   msgbox('没有选择任何图片');
else
   pathfile=fullfile(pathname, filename);  %获得图片路径
   rgb.Mat=imread(pathfile);
   rgb.STATE=0;
   pic=rgb2gray(rgb.Mat);
    imwrite(pic,'gray.bmp');
    msgbox('格式修改成功，已另存为gray.bmp，请读入');
end
