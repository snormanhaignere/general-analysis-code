function [log_px, dmsab, dx, dxdx] = log_unbounded_johnson(x, msab, nll)
% function [px, dmsab, dx, dxdx] = log_unbounded_johnson(x, msab, minfn)
% 
% Computes the log of the Unbounded Johnson Distribution:
% https://reference.wolfram.com/language/ref/JohnsonDistribution.html
% 
% The distribution corresponds to a Gaussian variable that has been
% transformed with the hyperbolic sinc function, which as unbounded
% logit-like function. The distribution is unimodal and uniquely
% specified by its first four moments.
% 
% There are two required inputs: a row vector x, of N i.i.d. samples, and a four
% element parameter vector msab. The four parameters have been modified
% from the standard parameterization to correspond approximately to the 
% mean (m), standard deviation (s), skew (a), and sparsity/kurtosis (b).
% If x is a matrix, the function will operate separately on each row.
% 
% The third optional argument (nll), specifies whether or not to return the 
% negative log-likelihood, in can be useful for fitting the distribution
% via gradient optimization.
% 
% The second output argument (dmasb) returns the derivative with respect to the
% parameters. The third and fourth output return the derivative (dx) and hessian (dxdx)
% of the function with respect to the data vector (probably less relevant/useful).
% The derivate with respect to the parameters can be used to fit the
% distribution to a data vector.
% 
% Example 1: Sample from skewed and symmetric johnson distribution
% msab = [0,1,1,1]; % skewed 
% smps = sample_unbounded_johnson(msab, [10000,1]);
% x = linspace(-5, 25, 100);
% [N,x] = hist(smps,x);
% px_hist = N/sum(N);
% log_px = log_unbounded_johnson(x', msab);
% px = exp(log_px)/sum(exp(log_px));
% plot(x', [px_hist', px]);
% yL = ylim;
% hold on;
% plot([0,0], yL, 'k--');
% legend('Samples', 'Parametric');
% 
% Last modified by Sam Norman-Haignere on 4/2/2015

if nargin < 3
    nll = false;
end

mu = msab(1);
sig = msab(2);
a = msab(3);
b = msab(4);

z = (x-mu)/(sig*b);
q = (-a + b * asinh(z));
log_px = sum(-0.5 * q.^2 - 0.5 * log(z.^2 + 1) - 0.5 * log(2*pi) - log(sig),2);

da = sum(q,2);
db = sum(q .* z ./ sqrt(1 + z.^2) - q .* asinh(z) + z.^2 ./ (b * (z.^2 + 1)),2);
dmu = sum(q ./ (sig * sqrt(1 + z.^2)) + z ./ (b * sig * (z.^2 +1)),2);
dsig = sum(q .* (x-mu) ./ (sig^2 * sqrt(1 + z.^2)) + z.^2 ./ (sig * (z.^2 + 1)) - 1/sig,2);
dmsab = [dmu; dsig; da; db];
dx = sum(-q ./ (sig * sqrt(1 + z.^2)) - z ./ (b * sig * (z.^2 +1)),2);
x1 = 1./(sig.^2 .* (z.^2 + 1));
x2 = (1 - z.^2) ./ (b.^2 .* (z.^2 +1)) - q.*z ./ (b .* sqrt(z.^2 + 1)) + 1;
dxdx =- x1 .* x2;

if nll
    log_px = -log_px;
    dmsab = -dmsab;
    dx = -dx;
    dxdx = -dxdx;
end



