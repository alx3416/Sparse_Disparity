%CENSUS_TRN_CW_BIN Find the Binary Census Transform from a 2D-Array
% C = CENSUS_TRN_CW_BIN(I,BlockSize) takes a 2D array and performs local
% Census transform, each Block is saved as a logical binary vector across
% a 3rd dimension from C, the census transform is performed clockwise direction
% for each Block and only horizontal, vertical an diagonals pixels related
% to the center are taken into consideration to reduce memory usage
% 
function C=Census_Trn_cw_bin(a,p)
[x,y]=clockwise_cord(3);
for k=5:2:p
% x=x+1; y=y+1;
[x1,y1]=clockwise_cord(k);
x=vertcat(x,x1);
y=vertcat(y,y1);
end
z=(p*p)-1;
lbps=(3*(p-1))+(p-1);
a=a+0.001;
[m,n]=size(a);
C=false(m,n,lbps);
dd=0;
for k=1:z
    
    if (abs(x(k))==abs(y(k)) || ((x(k)==0 || y(k)==0)))
        dd=dd+1; 
        C(:,:,dd)=logical(floor((circshift(a,[y(k) x(k)]))./a));
    end
end
