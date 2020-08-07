function [r_pearson, lags] = xcorr_pearson(x, h)

% Uses the xcorr function, but normalizes things so that
% the results would be the same as computing the pearson correlation
% between the signal x and the template h.
% 
% Note h should be a vector equal to or shorter than x.
% 
% Only samples that do not require padding are returned. So the first
% sample is the result of correlating h with the front the signal x.
% 
% -- Example --
% 
% % create signal
% N = 100;
% x = randn(N,1)+10;
% M = 10;
% h = randn(M,1)+10;
% 
% % compute pearson correlation
% r_pearson = xcorr_pearson(x, h);
% 
% % should be the same as if done in a loop
% n_valid = N-M+1;
% r_pearson_loop = nan(n_valid, 1);
% for i = 1:n_valid
%     xw = x((1:M)+i-1);
%     r_pearson_loop(i) = corr(xw, h);
% end
% figure;
% plot([r_pearson, r_pearson_loop]);
% 
% 2019-01-21: Created, Sam NH

assert(isvector(x) && isvector(h));
N = length(x);
M = length(h);
assert(N>M);

% means
[mu_x, lags] = xcorr_valid(x, ones(size(h))/M);
mu_h = mean(h);

% power
p_x = xcorr_valid(x.^2, ones(size(h))/M);
p_h = mean(h.^2);

% un-normalized standard deviation
s_x = M*p_x - M*mu_x.^2;
s_x(s_x<0) = 1;
s_x = sqrt(s_x);
s_h = M*p_h - M*mu_h.^2; 
s_h(s_h<0) = 0;
s_h = sqrt(s_h);

% cross product
r_xh = xcorr_valid(x, h);

% pearson
r_pearson = (1/s_h) * (1./s_x) .* (r_xh - M*mu_x*mu_h);