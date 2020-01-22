function [cc, lag] = xcorr_valid(x, h)

% Cross correlation as computed by xcorr but only returns the results for
% the valid portions of the convolution. So the first sample is the result
% of correlating h with the front the signal x.

assert(isvector(x) && isvector(h));
assert(length(x)>length(h));

n_valid = length(x)-length(h)+1;
[cc,lag] = xcorr(x, h);
xi = find(lag>=0);
xi = xi(1:n_valid);
cc = cc(xi);
lag = lag(xi);
