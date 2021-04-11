%% ͼ��ָ��
function imgf = fenge(rgb)
%% ��ͼ��ת��Ϊ�Ҷ�ͼ
if ndims(rgb) == 3
    I = rgb2gray(rgb);
else
    I = rgb;
end

%% ʹ��Sobel��Ե���Ӷ�ͼ�����ˮƽ�ʹ�ֱ������˲�
hy = fspecial('sobel'); %ʹ��Ԥ������
hx = hy';
Iy = imfilter(double(I), hy, 'replicate'); %�˲�
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2); 

%% ���ǰ������
se = strel('disk', 20);%����ָ��ͼ��

%% ͨ����ʴ���ؽ��������ڿ����ؽ�
Ie = imerode(I, se); %��ʴ
Iobr = imreconstruct(Ie, I);%�ؽ�

%% ���бղ������Ƴ��ϰ��İߵ��֦�ɱ�ǡ�
%ͼ�����ź��ؽ�
Iobrd = imdilate(Iobr, se);%����
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));%�ؽ�
Iobrcbr = imcomplement(Iobrcbr);%ȡ��

fgm = imregionalmax(Iobrcbr);

%ͨ���ղ����͸�ʴ���������ǰߵ�ı�Ե������
se2 = strel(ones(5,5)); 
fgm2 = imclose(fgm, se2);%��
fgm3 = imerode(fgm2, se2);%��ʴ

%% �Ƴ���������
fgm4 = bwareaopen(fgm3, 20);%ɾ��С��20�Ĳ���

%% ����ֵ������ʼ��Ǳ���
bw = im2bw(Iobrcbr, graythresh(Iobrcbr));

D = bwdist(bw);
DL = watershed(D);

bgm = DL == 0;

%% ����ָ���ķ�ˮ��任��ǿ����Сֵ��
gradmag2 = imimposemin(gradmag, bgm | fgm4);

%% ���з�ˮ��任
L = watershed(gradmag2);

%%
imgf = label2rgb(L, 'jet', 'w', 'shuffle');
end