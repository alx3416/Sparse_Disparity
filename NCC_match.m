%NCC_MATCH(I1,I2,v,h,h_w,v_w) Performs Normalized Cross-Correlation from
%two 2d arrays with separable convolution
function [A]=NCC_match(a,b,h,v,h_w,v_w)

mu1=conv2(h,v,a,'same');
mu2=conv2(h,v,b,'same');
sum_12=conv2(h_w,v_w,(a.*b),'same');
mu1_sq = mu1.*mu1;
mu2_sq = mu2.*mu2;
sigma1_sq = conv2(h_w,v_w,a.*a,'same') - mu1_sq;
sigma2_sq = conv2(h_w,v_w,b.*b,'same') - mu2_sq;
A=(sum_12-mu1.*mu2)./(sqrt((sigma1_sq.*sigma2_sq)));
