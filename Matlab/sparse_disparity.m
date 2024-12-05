%SPARSE_DISPARITY Find the sparse disparity map from a stereo pair.
% [SparseDisparityMap] = sparse_disparity(L,R,DisparityRange,WindowSize,Method,DisparityCheck);
% takes two images from a stereo pair, rgb or grayscale, with parameters
% for estimation as: DisparityRange, composed from [dmin dmax] vector,
% WindowSize is the Blocksize for matching or Binary Census Transform (see methods)
% Method (optional) is te similarity measure selected for matching and 
% DisparityCheck is a vector [minGroup maxRange] to perform a Disparity
% consistency check (default [9 12])
%
% Methods:
% 'SAD'              : Sum of Absolute Differences (default)
% 'NCC'              : Normalized Cross-Correlation
% 'Hamming'          : Hamming distance from Binary Census Transform
% 'Jaccard'          : Jaccard measure from Binary Census Transform
% 'MutualInformation': Entropy based measure from Binary Census Transform
% See DEMO for examples
% 
% If this work is helpful to you, please cite this work
% V. Gonzalez-Huitron, V. Ponomaryov, E. Ramos-Diaz, and S. Sadovnychiy,
% “Parallel framework for dense disparity map estimation using Hamming 
% distance,” Signal, Image Video Process., vol. 12, no. 2, pp. 231–238,
% Feb. 2018. doi.org/10.1007/s11760-017-1150-3

function D=sparse_disparity(varargin)

narginchk(4,6);
[Left, Right, Disparityrange, Windowsize, method, DisparityCheck] = parse_inputs(varargin{:});

try
   gpuArray(1);
   canUseGPU=true;
catch
 canUseGPU=false;
end

[m,n,dims]=size(Left);
if dims==3
    Left=double(rgb2gray(Left));
    Right=double(rgb2gray(Right));
else
    Left=double(Left);
    Right=double(Right);
end

[Left,~] = imgradient(Left);
[Right,~] = imgradient(Right);

if isequal(method,'Hamming') || isequal(method,'Jaccard') || isequal(method,'MutualInformation')
    Left=Census_Trn_cw_bin(Left,Windowsize);
    Right=Census_Trn_cw_bin(Right,Windowsize);
else
    Left=Census_Trn_cw(Left,5);
    Right=Census_Trn_cw(Right,5);
end

if canUseGPU==true
    gpuArray(Left);
    gpuArray(Right);
    similarity=gpuArray.zeros(m,n,2);
    ddppL=gpuArray.zeros(m,n);
    similarity2=gpuArray.zeros(m,n,2);
    ddppR=gpuArray.zeros(m,n);
    switch method
        case 'SAD'
            W=ones(Windowsize);
            h=gpuArray(W(1,:).*-1);
            v=gpuArray(W(:,1).*-1);
        case 'NCC'
            W=ones(Windowsize);
            W = W/sum(sum(W));
            [U,S,V] = svd(W);
            v = gpuArray(U(:,1) * sqrt(S(1,1)));
            h = gpuArray(V(:,1)' * sqrt(S(1,1)));
            h_w=gpuArray.ones(1,Windowsize)*-1;
            v_w=gpuArray.ones(Windowsize,1)*-1;
        case 'MutualInformation'
            LEFT_e=entropy_bin(Left);
            RIGHT_e=entropy_bin(Right);
    end    
else
    similarity=zeros(m,n,2);
    ddppL=zeros(m,n);
    similarity2=zeros(m,n,2);
    ddppR=zeros(m,n);
    switch method
        case 'SAD'
            W=ones(Windowsize);
            h=W(1,:).*-1;
            v=W(:,1).*-1;
        case 'NCC'
            W=ones(Windowsize);
            W = W/sum(sum(W));
            [U,S,V] = svd(W);
            v = U(:,1) * sqrt(S(1,1));
            h = V(:,1)' * sqrt(S(1,1));
            h_w=ones(1,Windowsize)*-1;
            v_w=ones(Windowsize,1)*-1;
        case 'MutualInformation'
            LEFT_e=entropy_bin(Left);
            RIGHT_e=entropy_bin(Right);
    end 
    
end

if ~isequal(method,'NCC') && ~isequal(method,'MutualInformation')
    similarity(:,:,1)=Inf;
    similarity2(:,:,1)=Inf;
end

for k=Disparityrange(1):Disparityrange(2) % Falta generalizar, todos usan shifted
    [ SHIFTED ] = circshift(Right,[0 k]);
    [ SHIFTED2 ] = circshift(Left,[0 -k]);
    switch method
        case 'SAD'
            SHIFTED=abs(Left-SHIFTED);
            SHIFTED2=abs(Right-SHIFTED2);
            similarity(:,:,2)=conv2(h,v,SHIFTED,'same');
            similarity2(:,:,2)=conv2(h,v,SHIFTED2,'same');
            [similarity(:,:,1),D] = min(similarity,[],3);
            [similarity2(:,:,1),D2] = min(similarity2,[],3);
        case 'NCC'
            similarity(:,:,2)=NCC_match(Left,SHIFTED,h,v,h_w,v_w);
            similarity2(:,:,2)=NCC_match(Right,SHIFTED2,h,v,h_w,v_w);
            [similarity(:,:,1),D] = max(similarity,[],3);
            [similarity2(:,:,1),D2] = max(similarity2,[],3);
        case 'Hamming'
            similarity(:,:,2) = sum(SHIFTED ~= Left,3);
            similarity2(:,:,2) = sum(SHIFTED2 ~= Right,3);
            [similarity(:,:,1),D] = min(similarity,[],3);
            [similarity2(:,:,1),D2] = min(similarity2,[],3);
        case 'Jaccard'
            similarity(:,:,2) = 1 - sum(SHIFTED & Left,3)./sum(SHIFTED | Left,3);
            similarity2(:,:,2) = 1 - sum(SHIFTED2 & Right,3)./sum(SHIFTED2 | Right,3);
            [similarity(:,:,1),D] = min(similarity,[],3);
            [similarity2(:,:,1),D2] = min(similarity2,[],3);
        case 'MutualInformation'
            [ SHIFTED_e ] = circshift(RIGHT_e,[0 k]);
            [ SHIFTED2_e ] = circshift(LEFT_e,[0 -k]);
            similarity(:,:,2) = SHIFTED_e+LEFT_e-jointentropy_bin(SHIFTED,Left);
            similarity2(:,:,2) = SHIFTED2_e+RIGHT_e-jointentropy_bin(SHIFTED2,Right);
            [similarity(:,:,1),D] = max(similarity,[],3);
            [similarity2(:,:,1),D2] = max(similarity2,[],3);
    end
    ddppL(D==2)=k;
    ddppR(D2==2)=k;
end

if canUseGPU==true
ddppL=gather(ddppL);
ddppR=gather(ddppR);
end
[D]=match_check(ddppL,ddppR);
[D]=SingularDisparitiesOff(D,DisparityCheck(1),sum(abs(Disparityrange)),DisparityCheck(2));
end


function [L, R, w, p, method, SD] = parse_inputs(varargin)

methodstrings = {'SAD','NCC','Hamming','Jaccard', ...
            'MutualInformation'};
L = [];
R = [];
w = []; 
p = [];
method = 'SAD'; % Default method
SD = [9 12];

if (nargin == 4)
    L = varargin{1};
    R = varargin{2};
    w = varargin{3};
    p = varargin{4};
    validateattributes(L,{'numeric','logical'},{'nonsparse','real'}, ...
                       mfilename,'Left-Image',1);
    validateattributes(R,{'numeric','logical'},{'nonsparse','real'}, ...
                       mfilename,'Right-Image',2);
    if (~isequal(size(L),size(R)))
            error(message('images:validate:unequalSizeMatrices','L','R'));
    end
    if ~ndims(L)==2 || ~ndims(L)==3
       error('Left image must be 2D or 3D array') 
    end
    if ~ndims(R)==2 || ~ndims(R)==3
       error('right image must be 2D or 3D array') 
    end
    validateattributes(w,{'numeric'},{'2d','nonsparse','real','vector','size', [1,2]}, ...
                       mfilename,'DisparityRange',3);
    if (w(1)>=w(2))
        error('DisparityRange dispmin must be grater than dispmax');
    end
    validateattributes(p,{'numeric'},{'2d','nonsparse','real','scalar','positive','nonzero'}, ...
                       mfilename,'WindowSize',4);
    if (~mod(p,2))
        error('window size must be an odd number');
    end
elseif (nargin == 5)
    L = varargin{1};
    R = varargin{2};
    w = varargin{3};
    p = varargin{4};
    validateattributes(L,{'numeric','logical'},{'nonsparse','real'}, ...
                       mfilename,'Left-Image',1);
    validateattributes(R,{'numeric','logical'},{'nonsparse','real'}, ...
                       mfilename,'Right-Image',2);
    if (~isequal(size(L),size(R)))
            error(message('images:validate:unequalSizeMatrices','L','R'));
    end
    if ~ndims(L)==2 || ~ndims(L)==3
       error('Left image must be 2D or 3D array') 
    end
    if ~ndims(R)==2 || ~ndims(R)==3
       error('right image must be 2D or 3D array') 
    end
    validateattributes(w,{'numeric'},{'2d','nonsparse','real','vector','size', [1,2]}, ...
                       mfilename,'DisparityRange',3);
    if (w(1)>=w(2))
        error('DisparityRange dispmin must be grater than dispmax');
    end
    validateattributes(p,{'numeric'},{'2d','nonsparse','real','scalar','positive','nonzero'}, ...
                       mfilename,'WindowSize',4);
    if (~mod(p,2))
        error('window size must be an odd number');
    end
        method = validatestring(varargin{5}, methodstrings, ...
            mfilename, 'METHOD', 5);
        
else %(nargin == 6)
    L = varargin{1};
    R = varargin{2};
    w = varargin{3};
    p = varargin{4};
    SD = varargin{6};
    validateattributes(L,{'numeric','logical'},{'nonsparse','real'}, ...
                       mfilename,'Left-Image',1);
    validateattributes(R,{'numeric','logical'},{'nonsparse','real'}, ...
                       mfilename,'Right-Image',2);
    if (~isequal(size(L),size(R)))
            error(message('images:validate:unequalSizeMatrices','L','R'));
    end
    if ~ndims(L)==2 || ~ndims(L)==3
       error('Left image must be 2D or 3D array') 
    end
    if ~ndims(R)==2 || ~ndims(R)==3
       error('right image must be 2D or 3D array') 
    end
    validateattributes(w,{'numeric'},{'2d','nonsparse','real','vector','size', [1,2]}, ...
                       mfilename,'DisparityRange',3);
    if (w(1)>=w(2))
        error('DisparityRange dispmin must be grater than dispmax');
    end
    validateattributes(p,{'numeric'},{'2d','nonsparse','real','scalar','positive','nonzero'}, ...
                       mfilename,'WindowSize',4);
    if (~mod(p,2))
        error('window size must be an odd number');
    end
        method = validatestring(varargin{5}, methodstrings, ...
            mfilename, 'METHOD', 5);
    validateattributes(SD,{'numeric'},{'2d','nonsparse','real','vector','size', [1,2]}, ...
            mfilename,'DisparityCheck',6);
        
        

         
end

end