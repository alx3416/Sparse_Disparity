%JOINTENTROPY_BIN Find the joint entropy value from two binary 3d arrays, 
% the results are obtained across the third dimension
function JE = jointentropy_bin(a,b)
[~,~,k]=size(a);
p(:,:,1)=sum(a&b,3); % AND 1-1
p(:,:,2)=sum(~(a|b),3); % NOR 0-0
p(:,:,3)=sum((~a&b),3); % (NOT A) AND B 0-1
p(:,:,4)=sum((a&~b),3); % A AND (NOT B) 1-0
p=p./k;
p(p==0)=NaN;
JE=-nansum(p.*log2(p),3);
