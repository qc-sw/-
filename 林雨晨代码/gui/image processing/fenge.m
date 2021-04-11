%% 图像分割函数
function imgf = fenge(rgb)
%% 将图像转化为灰度图
if ndims(rgb) == 3
    I = rgb2gray(rgb);
else
    I = rgb;
end

%% 使用Sobel边缘算子对图像进行水平和垂直方向的滤波
hy = fspecial('sobel'); %使用预设算子
hx = hy';
Iy = imfilter(double(I), hy, 'replicate'); %滤波
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2); 

%% 标记前景对象
se = strel('disk', 20);%生成指定图像

%% 通过腐蚀后重建来做基于开的重建
Ie = imerode(I, se); %腐蚀
Iobr = imreconstruct(Ie, I);%重建

%% 进行闭操作，移除较暗的斑点和枝干标记。
%图像扩张和重建
Iobrd = imdilate(Iobr, se);%膨胀
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));%重建
Iobrcbr = imcomplement(Iobrcbr);%取反

fgm = imregionalmax(Iobrcbr);

%通过闭操作和腐蚀操作清理标记斑点的边缘并收缩
se2 = strel(ones(5,5)); 
fgm2 = imclose(fgm, se2);%闭
fgm3 = imerode(fgm2, se2);%腐蚀

%% 移除孤立像素
fgm4 = bwareaopen(fgm3, 20);%删除小于20的部分

%% 从阈值操作开始标记背景
bw = im2bw(Iobrcbr, graythresh(Iobrcbr));

D = bwdist(bw);
DL = watershed(D);

bgm = DL == 0;

%% 计算分割函数的分水岭变换（强调极小值）
gradmag2 = imimposemin(gradmag, bgm | fgm4);

%% 进行分水岭变换
L = watershed(gradmag2);

%%
imgf = label2rgb(L, 'jet', 'w', 'shuffle');
end