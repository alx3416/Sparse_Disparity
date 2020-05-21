%SINGULARDISPARITIESOFF Removes weak disparities values from a sparse
%disparity map.
% D = SINGULARDISPARITIESOFF(D,P,W,Inc) takes a disparity map and performs
% an evaluation for each INC range of values in disparity range W, where
% each group with less than P values must be labeled as a NaN, thus
% discarding disparity values that appears as noise witout affecting rest
% of the sparse map
function [D1]=SingularDisparitiesOff(D,p,w,Inc)
% D --> Imagen de disparidad Sparse
% p --> Número mínimo de pixeles para formar un grupo
% w --> Número de disparidades
% Inc --> rango de disparidades a probar (15 a 20, luego 16 y 21 son Inc=6
D1=NaN(size(D));
B=false(size(D));
    for dmin=1:w-Inc+1
        B=false(size(D));
        B(D>dmin & D<dmin+Inc)=true;
        B = bwareaopen(B,p);
        D1(B==1)=D(B==1);
    end
