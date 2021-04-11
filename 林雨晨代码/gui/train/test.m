%单张测试
clear;
tic;
jj='29';
d=imread(strcat('.\picture\',jj,'.jpg'));
figure;
subplot(2,2,1);
imshow(d);
title('手工标记');

load myRCNN.mat;
detectedImg = imread(strcat('caries11\',jj,'.bmp'));
[bbox, score, label] = detect(myRCNN, detectedImg, 'MiniBatchSize', 20);
idx=find(score>0.1);
bbox = bbox(idx, :);
n=size(idx,1);
for i=1:n
    annotation = sprintf('%s: (Confidence = %f)', label(idx(i)), score(idx(i)));
    detectedImg = insertObjectAnnotation(detectedImg, 'rectangle', bbox(i,:), annotation);
end
subplot(2,2,2);
imshow(detectedImg);
title('cnn区域建议');

load myRCNN.mat;
detectedImg1 = imread(strcat('G:\口腔项目\林雨晨代码\gui\caries\',jj,'.bmp'));
[bbox, score, label] = detect(myRCNN, detectedImg1, 'MiniBatchSize', 20);
idx=find(score>0.1);
bbox = bbox(idx, :);
n=size(idx,1);
for i=1:n
    annotation = sprintf('%s: (Confidence = %f)', label(idx(i)), score(idx(i)));
    detectedImg1 = insertObjectAnnotation(detectedImg1, 'rectangle', bbox(i,:), annotation);
end
subplot(2,2,3);
imshow(detectedImg1);
title('图片分割叠加');

load myRCNN_canny.mat;
detectedImg2 = imread(strcat('G:\口腔项目\林雨晨代码\gui\caries\',jj,'.bmp'));
[bbox, score, label] = detect(myRCNN, detectedImg2, 'MiniBatchSize', 20);
idx=find(score>0.1);
bbox = bbox(idx, :);
n=size(idx,1);
for i=1:n
    annotation = sprintf('%s: (Confidence = %f)', label(idx(i)), score(idx(i)));
    detectedImg2 = insertObjectAnnotation(detectedImg2, 'rectangle', bbox(i,:), annotation);
end
subplot(2,2,4);
imshow(detectedImg2);
title('边缘提取叠加');
toc;
