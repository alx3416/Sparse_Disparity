%ENTROPY_BIN Find the entropy value from a binary 3d array across the third
% dimension
function E=entropy_bin(a)

[~,~,k]=size(a);
p(:,:,1)=sum(a,3);
p(:,:,2)=abs(p(:,:,1)-k);
p=(p./k)+0.00001;
E=-sum(p.*log2(p),3);

