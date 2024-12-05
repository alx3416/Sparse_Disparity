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
L = imread('stereoimages/imgRecIzq15.png');
R = imread('stereoimages/imgRecDer15.png');
DisparityRange = [0 64];
WindowSize = 9;
Method = 'SAD';
DisparityCheck=[12,4];
D=sparse_disparity(L,R,DisparityRange,WindowSize,Method,DisparityCheck);
figure,
imshow(D,DisparityRange);
title(['Disparity map - ' Method]);
colormap jet; colorbar;
%% Example 2
L = imread('stereoimages/imgRecIzq15.png');
R = imread('stereoimages/imgRecDer15.png');
DisparityRange = [0 40];
WindowSize = 33;
Method = 'Jaccard';
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
