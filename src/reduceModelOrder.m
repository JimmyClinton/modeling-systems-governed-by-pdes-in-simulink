function [Ar,Br,Cr,Dr,Er,V] = reduceModelOrder(A,B,C,D,E,freqRange,varargin)
%reduceModelOrder modal truncation of DSS system
%   Reduce order of DSS system using modal truncation and Galerkin
%   projection.
%   
%   [Ar,Br,Cr,Dr,Er,V] = reduceModelOrder(A,B,C,D,E,freqRange,freqRange,k)
%   
%   Ar,Br,Cr,Dr,Er,V = reduced order matrices and projection matrix
%   A,B,C,D,E = full order system matrices
%   freqRange = requested range of eigenvalues as [1x2] double
%   k = number of eigenvalues retained
if((nargin>7) || (nargin<6))
    error('Invalid number of arguments')
end

if(nargin>6)
    k = varargin{1};
    if (~isnumeric(k))
        error('Input argument k must be an integer')
    end
end

if (~isnumeric(freqRange) || numel(freqRange)~=2)
    error('Frequency range must be a numeric vector of length 2')
end
opts.FrequencyRange = freqRange;
[V,lambda] = matlab.internal.math.lanczos(A,E,opts);
[V,~] = qr(V,0); % re-orthogonalize

if exist('k','var')
    kact = min([k length(lambda)]);
    if (k~=kact)
        warning('k too large for given frequency range, using k=%d',kact)
    end
    V = V(:,1:kact);
end

Ar = V'*A*V;
Br = V'*B  ;
Cr =    C*V;
Dr =    D  ;
Er = V'*E*V;

end

