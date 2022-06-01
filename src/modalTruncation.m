function rsys = modalTruncation(sys,freqRange)

if(nargin~=2)
    error('Invalid number of arguments')
end
if (~isnumeric(freqRange) || numel(freqRange)~=2)
    error('Frequency range must be a numeric vector of length 2')
end

if(freqRange(1) == 0.0), freqRange(1) = -inf; end

rsys.type = 'modaltruncation';

opts.FrequencyRange = freqRange;
[V,lambda] = matlab.internal.math.lanczos(sys.A,sys.E,opts);
[V,~] = qr(V,0); % re-orthogonalize
rsys.V = V;
rsys.lambda = lambda;

rsys.A = V'*sys.A*V;
rsys.B = V'*sys.B  ;
rsys.C =    sys.C*V;
rsys.D =    sys.D  ;
rsys.E = V'*sys.E*V;

end