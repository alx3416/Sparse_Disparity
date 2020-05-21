% Demo for disparitysparse.m
% Usage
% [SparseDisparityMap] = sparse_disparity(Left_image,Right_image,DisparityRange,WindowSize,Method,DisparityCheck);

% DisparityRange = [dmin, dmax]; must be vector with 2 values
% WindowSize = [positive odd number] must be odd scalar
% DisparityCheck = [minGroup, maxRange]; must be vector with 2 values
% minGroup --> minimum disparity values to form a group
% maxRange --> range of values to form a group
% if a group doesn't pass disparity check is labeled as NaN


% Available Methods (Default SAD):
% SAD --> Sum of Absolute Differences
% NCC --> Normalized Cross Correlation
% Hamming --> Hamming distance
% Jaccard --> Jaccard measure
% MutualInformation --> Entropy-based measure

% Occlusions are labeled as NaN values
% To visualize D, imshow(D,[DisparityRange])
%% Example 1
L = imread('stereoimages/TsukubaL.png');
R = imread('stereoimages/TsukubaR.png');
DisparityRange = [0 16];
WindowSize = 9;
Method = 'MutualInformation';
DisparityCheck=[12,4];
D=sparse_disparity(L,R,DisparityRange,WindowSize,Method,DisparityCheck);
figure,
imshow(D,DisparityRange);
title(['Disparity map - ' Method]);
colormap jet; colorbar;
%% Example 2
L = imread('stereoimages/MotorcycleL.png');
R = imread('stereoimages/MotorcycleR.png');
DisparityRange = [0 70];
WindowSize = 13;
Method = 'Hamming';
D=sparse_disparity(L,R,DisparityRange,WindowSize,Method);
figure,
imshow(D,DisparityRange);
title(['Disparity map - ' Method]);
colormap jet; colorbar;
%% Example 3
L = imread('stereoimages/KITTI06_L.png');
R = imread('stereoimages/KITTI06_R.png');
DisparityRange = [0 128];
WindowSize = 11;
D=sparse_disparity(L,R,DisparityRange,WindowSize);
figure,
imshow(D,DisparityRange);
title('Disparity map - SAD');
colormap jet; colorbar;
