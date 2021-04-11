tic;
clear;
% clc;
load biaoji.mat;
load('rcnnStopSigns.mat','cifar10Net');
%% cifar10Net
% [height, width, numChannels, ~] = size(trainingImages);
% 
% imageSize = [height width numChannels];
% inputLayer = imageInputLayer(imageSize)
% 
% filterSize = [5 5];
% numFilters = 32;
% 
% middleLayers = [
% 
% convolution2dLayer(filterSize, numFilters, 'Padding', 2)
% 
% reluLayer()
% 
% maxPooling2dLayer(3, 'Stride', 2)
% 
% convolution2dLayer(filterSize, numFilters, 'Padding', 2)
% reluLayer()
% maxPooling2dLayer(3, 'Stride',2)
% 
% convolution2dLayer(filterSize, 2 * numFilters, 'Padding', 2)
% reluLayer()
% maxPooling2dLayer(3, 'Stride',2)
% 
% ]
% finalLayers = [
% fullyConnectedLayer(2)
% 
% reluLayer
% 
% fullyConnectedLayer(numImageCategories)
% softmaxLayer
% classificationLayer
% ]
% 
% layers = [
%     inputLayer
%     middleLayers
%     finalLayers
%     ]
%% 
% 改变输出层的类别个数
x=cifar10Net.Layers(1:end-3);
 %修改最后三层
lastlayers = [
fullyConnectedLayer(2,'Name','fc8');%,'WeightLearnRateFactor',1, 'BiasLearnRateFactor',1)
softmaxLayer('Name','softmax')
classificationLayer('Name','classification')
];

mylayers=[x;lastlayers];

%% 训练策略
options = trainingOptions('sgdm', ...
    'Momentum', 0.99, ...%动量
    'InitialLearnRate', 1e-4, ...%初始学习率
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...%学习率下降因子
    'LearnRateDropPeriod',128, ...%学习率下降期
    'L2Regularization',0.01, ...%L2规范化
    'MaxEpochs', 400, ...%最大迭代次数
    'MiniBatchSize', 32, ...%小型批处理大小
    'Verbose', true);
 
myRCNN = trainRCNNObjectDetector(Unnamed, mylayers, options, ...
    'NegativeOverlapRange', [0 0.3]);
save('myRCNN','myRCNN');

toc;
