%%批量进行图像处理
clear;
global Predictor;

pt = 'G:\口腔项目\林雨晨代码 - 副本\test\测试图片\';
ext = '*.bmp';
dis = dir([pt ext]);
nms = {dis.name};

for k = 1:length(nms)
    nm = [pt nms{k}];
    Predictor.Mat=imread(nm);
    Predictor.STATE=0;
%     figure,imshow(Img);
   imwrite(Predictor.Mat,'G:\口腔项目\林雨晨代码 - 副本\Temporary\org.bmp');
   imgCanny = edge_canny(Predictor.Mat,[5,5],1.4,0.9,0.65);
   imwrite(imgCanny,'G:\口腔项目\林雨晨代码 - 副本\Temporary\imgCanny.bmp');
   pic_1=imread('G:\口腔项目\林雨晨代码 - 副本\Temporary\org.bmp');
pic_2=imread('G:\口腔项目\林雨晨代码 - 副本\Temporary\imgCanny.bmp');
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
imwrite(DrawMat,'G:\口腔项目\林雨晨代码 - 副本\Temporary\imgCannySpp.bmp');
load myRCNN_canny.mat
img=imread('G:\口腔项目\林雨晨代码 - 副本\Temporary\imgCannySpp.bmp');
DrawMat=draw(img,myRCNN_canny);
imwrite(DrawMat,'G:\口腔项目\林雨晨代码 - 副本\picture_save\边缘提取图像的区块建议.bmp');
imwrite(DrawMat,strcat('G:\口腔项目\林雨晨代码 - 副本\gui\picture_save\',dis(k).name));
end
