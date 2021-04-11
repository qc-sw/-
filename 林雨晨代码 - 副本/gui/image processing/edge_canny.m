%% 图像边缘提取函数
%   方向梯度矩阵
%               3   2   1
%               0   P   0
%               1   2   3
%   P为当前点
%               NW  N  NE
%               W   P   E
%               SW  S  SE
%   参数:
%   percentOfPixelsNotEdges: 阈值选择.
%   thresholdRatio: 低阈值和高阈值的比例.
% -------------------------------------------------------------------------
function imgCanny = edge_canny(I,gaussDim,sigma,percentOfPixelsNotEdges,thresholdRatio)
%% 高斯平滑滤波器
m = gaussDim(1);
n = gaussDim(2);
if mod(m,2) == 0 || mod(n,2) == 0
    error('The dimensionality of Gaussian must be odd!');
end
% 生成高斯卷积核
gaussKernel = fspecial('gaussian', [m,n], sigma);
% 复制图像边缘
[m,n] = size(gaussKernel);
[row,col,dim] = size(I);
if dim > 1
    imgGray = rgb2gray(I);
else
    imgGray = I;
end
imgCopy = imgReplicate(imgGray,(m-1)/2,(n-1)/2);
% 高斯平滑滤波
imgData = zeros(row,col);
for ii = 1:row
    for jj = 1:col
        window = imgCopy(ii:ii+m-1,jj:jj+n-1);
        GSF = window.*gaussKernel;
        imgData(ii,jj) = sum(GSF(:));
    end
end
%% 计算像素角度信息
% Sobel operator.
dgau2Dx = [-1 0 1;-2 0 2;-1 0 1];
dgau2Dy = [1 2 1;0 0 0;-1 -2 -1];
[m,n] = size(dgau2Dx);
% 复制图像边缘.
imgCopy = imgReplicate(imgData,(m-1)/2,(n-1)/2);
% 储存图像边缘方向梯度信息.
gradx = zeros(row,col);
grady = zeros(row,col);
gradm = zeros(row,col);
dir = zeros(row,col); % 方向
% 计算每个像素的梯度值
for ii = 1:row
    for jj = 1:col
        window = imgCopy(ii:ii+m-1,jj:jj+n-1);
        dx = window.*dgau2Dx;
        dy = window.*dgau2Dy;
        dx = dx'; % 精确化总和
        dx = sum(dx(:));
        dy = sum(dy(:));
        gradx(ii,jj) = dx;
        grady(ii,jj) = dy;
        gradm(ii,jj) = sqrt(dx^2 + dy^2);
        % 计算变化角度
        theta = atand(dy/dx) + 90; % 0~180.
        % 确定变化方向
        if (theta >= 0 && theta < 45)
            dir(ii,jj) = 2;
        elseif (theta >= 45 && theta < 90)
            dir(ii,jj) = 3;
        elseif (theta >= 90 && theta < 135)
            dir(ii,jj) = 0;
        else
            dir(ii,jj) = 1;
        end
    end
end
%% 标准化阈值选择
magMax = max(gradm(:));
if magMax ~= 0
    gradm = gradm / magMax;
end
%% 选择阈值.
counts = imhist(gradm, 64);
highThresh = find(cumsum(counts) > percentOfPixelsNotEdges*row*col,1,'first') / 64;
lowThresh = thresholdRatio*highThresh;
%% 使用线性差值进行非极值抑制（NMS）
gradmCopy = zeros(row,col);
imgBW = zeros(row,col);
for ii = 2:row-1
    for jj = 2:col-1
        E =  gradm(ii,jj+1);
        S =  gradm(ii+1,jj);
        W =  gradm(ii,jj-1);
        N =  gradm(ii-1,jj);
        NE = gradm(ii-1,jj+1);
        NW = gradm(ii-1,jj-1);
        SW = gradm(ii+1,jj-1);
        SE = gradm(ii+1,jj+1);
        gradValue = gradm(ii,jj);
        if dir(ii,jj) == 0
            d = abs(grady(ii,jj)/gradx(ii,jj));
            gradm1 = E*(1-d) + NE*d;
            gradm2 = W*(1-d) + SW*d;
        elseif dir(ii,jj) == 1
            d = abs(gradx(ii,jj)/grady(ii,jj));
            gradm1 = N*(1-d) + NE*d;
            gradm2 = S*(1-d) + SW*d;
        elseif dir(ii,jj) == 2
            d = abs(gradx(ii,jj)/grady(ii,jj));
            gradm1 = N*(1-d) + NW*d;
            gradm2 = S*(1-d) + SE*d;
        elseif dir(ii,jj) == 3
            d = abs(grady(ii,jj)/gradx(ii,jj));
            gradm1 = W*(1-d) + NW*d;
            gradm2 = E*(1-d) + SE*d;
        else
            gradm1 = highThresh;
            gradm2 = highThresh;
        end
        % 非极值抑制
        if gradValue >= gradm1 && gradValue >= gradm2
            if gradValue >= highThresh
                imgBW(ii,jj) = 1;
                gradmCopy(ii,jj) = highThresh;
            elseif gradValue >= lowThresh
                gradmCopy(ii,jj) = lowThresh;
            else
                gradmCopy(ii,jj) = 0;
            end
        else
            gradmCopy(ii,jj) = 0;
        end
    end
end

%% 用双阈值进行双阈值检测.
% 保留周围8个像素点有强边缘点的弱边缘点
for ii = 2:row-1
    for jj = 2:col-1
        if gradmCopy(ii,jj) == lowThresh
            neighbors = [...
                gradmCopy(ii-1,jj-1),   gradmCopy(ii-1,jj), gradmCopy(ii-1,jj+1),...
                gradmCopy(ii,  jj-1),                       gradmCopy(ii,  jj+1),...
                gradmCopy(ii+1,jj-1),   gradmCopy(ii+1,jj), gradmCopy(ii+1,jj+1)...
                ];
            if ~isempty(find(neighbors) == highThresh)
                imgBW(ii,jj) = 1;
            end
        end
    end
end
imgCanny = logical(imgBW);
end
%% 图像复制
function imgRep = imgReplicate(I,rExt,cExt)
[row,col] = size(I);
imgCopy = zeros(row+2*rExt,col+2*cExt);
% 四条边和四个角
top = I(1,:);
bottom = I(row,:);
left = I(:,1);
right = I(:,col);
topLeftCorner = I(1,1);
topRightCorner = I(1,col);
bottomLeftCorner = I(row,1);
bottomRightCorner = I(row,col);
% 新图中扩展后原始图像的坐标。
topLeftR = rExt+1;
topLeftC = cExt+1;
bottomLeftR = topLeftR+row-1;
bottomLeftC = topLeftC;
topRightR = topLeftR;
topRightC = topLeftC+col-1;
bottomRightR = topLeftR+row-1;
bottomRightC = topLeftC+col-1;
% 复制原始图像和4条边缘。
imgCopy(topLeftR:bottomLeftR,topLeftC:topRightC) = I;
imgCopy(1:rExt,topLeftC:topRightC) = repmat(top,[rExt,1]);
imgCopy(bottomLeftR+1:end,bottomLeftC:bottomRightC) = repmat(bottom,[rExt,1]);
imgCopy(topLeftR:bottomLeftR,1:cExt) = repmat(left,[1,cExt]);
imgCopy(topRightR:bottomRightR,topRightC+1:end) = repmat(right,[1,cExt]);
% 复制4个角。
for ii = 1:rExt
    for jj = 1:cExt
        imgCopy(ii,jj) = topLeftCorner;
        imgCopy(ii,jj+topRightC) = topRightCorner;
        imgCopy(ii+bottomLeftR,jj) = bottomLeftCorner;
        imgCopy(ii+bottomRightR,jj+bottomRightC) = bottomRightCorner;
    end
end
imgRep = imgCopy;
end