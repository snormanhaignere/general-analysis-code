function rerr = r2rerr(r,n)
% function rerr = r2rerr(r,n)
% 
% Computes an estimate of the standard error of the pearson correlation
% given a measured correlation value (r) and the number of samples
% used to compute that value (n).
% 
% Based on an approximation of the Z-transformed, pearson correlation
% for Gaussian-distributed variables.
% http://en.wikipedia.org/wiki/Fisher_transformation
% 
% Example:
% n = 100;
% x = randn(n,1);
% y = randn(n,1) + x;
% r = corr(x,y);
% r_stderr = r2rerr(r,n)
% 
% Last modified by Sam Norman-Haignere on 12/16/2014

% check if a valid correlation value
if abs(r) > 1
    rerr = [];
    return;
end

% estimate of standard error for a given r value and number of data points, n
z = atanh(r);
zerr = 1./sqrt(n-3);
rerr = tanh([z-zerr;z+zerr]);