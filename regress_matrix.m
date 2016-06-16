function [b,se,p,e] = regress_matrix(X,Y)
% function [b,se,p,e] = regress_matrix(X,Y)
% 
% Variant of the built-in matlab function regress, that allows matrix
% observation variables (Y), so that the regress function does not need to be
% embedded in a loop over many entries. 
% 
% For details see regress.m.
% 
% Last modified by Sam Norman-Haignere on 5/6/2015.

n = size(X,1);
p = size(X,2);
df = n-p;

% compute betas, equivalent to pinv(X)*Y
[Q,R] = qr(X,0);
b = R \ (Q'*Y);

% errors
e = Y - X*b;
rmse = sqrt(sum(e.^2)) ./ sqrt(df);

% inverse of regressor standard deviation
Xstd = sqrt(sum(abs(R\eye(p)).^2,2)); % equivalent to sqrt(diag(inv(X'*X)))
se = Xstd*rmse;

% -log10 p-values
t = abs(b)./se;
p = sign(b) .* -log10(2*tpvalue_copy(-t,df));

function p = tpvalue_copy(x,v)
%TPVALUE Compute p-value for t statistic.

normcutoff = 1e7;
if length(x)~=1 && length(v)==1
   v = repmat(v,size(x));
end

% Initialize P.
p = NaN(size(x));
nans = (isnan(x) | ~(0<v)); % v == NaN ==> (0<v) == false

% First compute F(-|x|).
%
% Cauchy distribution.  See Devroye pages 29 and 450.
cauchy = (v == 1);
p(cauchy) = .5 + atan(x(cauchy))/pi;

% Normal Approximation.
normal = (v > normcutoff);
p(normal) = 0.5 * erfc(-x(normal) ./ sqrt(2));

% See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1.
gen = ~(cauchy | normal | nans);
p(gen) = betainc(v(gen) ./ (v(gen) + x(gen).^2), v(gen)/2, 0.5)/2;

% Adjust for x>0.  Right now p<0.5, so this is numerically safe.
reflect = gen & (x > 0);
p(reflect) = 1 - p(reflect);

% Make the result exact for the median.
p(x == 0 & ~nans) = 0.5;
