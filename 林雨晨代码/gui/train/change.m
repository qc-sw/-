%%��������ͼ����
clear;
global Predictor;

pt = 'G:\��ǻ��Ŀ\���곿���� - ����\test\����ͼƬ\';
ext = '*.bmp';
dis = dir([pt ext]);
nms = {dis.name};

for k = 1:length(nms)
    nm = [pt nms{k}];
    Predictor.Mat=imread(nm);
    Predictor.STATE=0;
%     figure,imshow(Img);
   imwrite(Predictor.Mat,'G:\��ǻ��Ŀ\���곿���� - ����\Temporary\org.bmp');
   imgCanny = edge_canny(Predictor.Mat,[5,5],1.4,0.9,0.65);
   imwrite(imgCanny,'G:\��ǻ��Ŀ\���곿���� - ����\Temporary\imgCanny.bmp');
   pic_1=imread('G:\��ǻ��Ŀ\���곿���� - ����\Temporary\org.bmp');
pic_2=imread('G:\��ǻ��Ŀ\���곿���� - ����\Temporary\imgCanny.bmp');
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
imwrite(DrawMat,'G:\��ǻ��Ŀ\���곿���� - ����\Temporary\imgCannySpp.bmp');
load myRCNN_canny.mat
img=imread('G:\��ǻ��Ŀ\���곿���� - ����\Temporary\imgCannySpp.bmp');
DrawMat=draw(img,myRCNN_canny);
imwrite(DrawMat,'G:\��ǻ��Ŀ\���곿���� - ����\picture_save\��Ե��ȡͼ������齨��.bmp');
imwrite(DrawMat,strcat('G:\��ǻ��Ŀ\���곿���� - ����\gui\picture_save\',dis(k).name));
end
