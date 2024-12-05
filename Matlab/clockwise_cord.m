%CLOCKWISE_CORD Generates subscripts (indexing by position) ordered in
%spiral way clockwise direction from the center to the edges for a 2d array
function [x,y]=clockwise_cord(p)

b=zeros(p);
b(1,:)=1;
b(p,:)=1;
b(:,1)=1;
b(:,p)=1; 
[x,y]=find(b==1); 
p=floor(p/2);
x=x-p-1;
y=y-p-1;
[t,r]=cart2pol(x,y);
t(r==0)=[];
r(r==0)=[];
[t,st]=sort(t);
r = r(st);
[x,y]=pol2cart(t,r);
x=round(x); y=round(y);
% p=p+1;
% x=x+p; y=y+p;