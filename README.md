# Sparse_Disparity
 Sparse disparity map estimation
MATLAB functions to estimate Sparse Disparity Map from a stereo-pair images previously rectified, DEMO.m contains examples with some stereo pairs from Middlebury Stereo Evaluation, and KITTI 2015 disparity challenge

Occlusions and missing disparities are labeled as NAN values, to add the posibility generate a dense disparity map with another frameworks

For a RGB or grayscale stereo pair images, first the magnitude gradient is obtained, then a Census transform is performed according to the selected method, for SAD and NCC, Census transform generates an image with a range of 2^24 possible values, for Hamming, Jaccard and Mutual Information a binary Census Transform generates a volume with binary vectors for each pixel

![Flow diagram](https://raw.githubusercontent.com/alx3416/Sparse_Disparity/master/Sparse_diagram.png)

Then a matching stage is performed with the selected method and finally a match and disparity consistency check is performed

The function uses GPU when is available

See DEMO.m for examples
 
If this work is helpful to you, please cite this work
V. Gonzalez-Huitron, V. Ponomaryov, E. Ramos-Diaz, and S. Sadovnychiy, “Parallel framework for dense disparity map estimation using Hamming 
distance,” Signal, Image Video Process., vol. 12, no. 2, pp. 231–238, Feb. 2018. doi.org/10.1007/s11760-017-1150-3
