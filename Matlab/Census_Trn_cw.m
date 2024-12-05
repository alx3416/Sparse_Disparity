%CENSUS_TRN_CW Find the Census Transform from a 2D-Array
% C = CENSUS_TRN_CW(I,BlockSize) takes a 2D array and performs local
% Census transform, the census transform is performed clockwise direction
% only 3 or 5 Blocksizes are suggested, bigger values are irrelevant due to
% numeric precision limitations 
% 
function C=Census_Trn_cw(a,p)
[x,y]=clockwise_cord(3);
for k=5:2:p
% x=x+1; y=y+1;
[x1,y1]=clockwise_cord(k);
x=vertcat(x,x1);
y=vertcat(y,y1);
end

z=(p*p)-1;
a=a+0.001;
[m,n]=size(a);
C=zeros(m,n);

for k=1:z
        z=z-1;
        b = circshift(a,[y(k) x(k)]);
        b=logical(floor(b./a));
        b=b.*2^z;
        C=C+b;  
    
end