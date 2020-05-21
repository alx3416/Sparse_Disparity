# Sparse_Disparity
 Sparse disparity map estimation
MATLAB functions to estimate Sparse Disparity Map from a stereo-pair images previously rectified, DEMO.m contains examples with some stereo pairs from Middlebury Stereo Evaluation, and KITTI 2015 disparity challenge

Occlusions and missing disparities are labeled as NAN values, to add the posibility generate a dense disparity map with another frameworks

For a RGB or grayscale stereo pair images, first the magnitude gradient is obtained, then a Census transform is performed according to the selected method, for SAD and NCC, Census transform generates an image with a range of 2^24 possible values, for Hamming, Jaccard and Mutual Information a binary Census Transform generates a volume with binary vectors for each pixel

Then a matching stage is performed with the selected method and finally a match and disparity consistency check is performed

The function uses GPU when is available

