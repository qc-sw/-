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
% �ı�������������
x=cifar10Net.Layers(1:end-3);
 %�޸��������
lastlayers = [
fullyConnectedLayer(2,'Name','fc8');%,'WeightLearnRateFactor',1, 'BiasLearnRateFactor',1)
softmaxLayer('Name','softmax')
classificationLayer('Name','classification')
];

mylayers=[x;lastlayers];

%% ѵ������
options = trainingOptions('sgdm', ...
    'Momentum', 0.99, ...%����
    'InitialLearnRate', 1e-4, ...%��ʼѧϰ��
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...%ѧϰ���½�����
    'LearnRateDropPeriod',128, ...%ѧϰ���½���
    'L2Regularization',0.01, ...%L2�淶��
    'MaxEpochs', 400, ...%����������
    'MiniBatchSize', 32, ...%С���������С
    'Verbose', true);
 
myRCNN = trainRCNNObjectDetector(Unnamed, mylayers, options, ...
    'NegativeOverlapRange', [0 0.3]);
save('myRCNN','myRCNN');

toc;
