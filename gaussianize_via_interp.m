function [y, f, finv] = gaussianize_via_interp(x)

% Gaussianize samples from 1-dimensional distribution by interpolating the
% empirical CDF
% 
% -- Inputs --
% 
% x: vector of samples from the data distribution
% 
% -- Outputs -- 
% 
% y: gaussianized samples
% 
% f: mapping function handle, y = f(x)
% 
% finv: approximate inverse mapping, a ~ finv(f(a))
% 
% -- Example --
% % kurtotic distribution
% x = randn(100,1);
% x = sign(x) .* abs(x).^4;
% x = x(:);
% 
% % gaussinized version
% [y, f, finv] = gaussianize_via_interp(x);
% 
% % plot
% figure;
% hold on;
% plot(x, y, 'o');
% z = linspace(min(x) - range(x)/4, max(x) + range(x)/4, 100);
% plot(z,f(z), '-');
% 
% % illustrate inverse
% x = randn(5,1)
% finv(f(x))

assert(isvector(x));
x_orig = x;

% remove NaNs and infs
x = x(~isnan(x) & ~isinf(x));

% use histogram trick to find corresponding points
N = length(x);
y = nan(size(x));
[~, xi] = sort(x);
y(xi) = norminv((1:N)'/N - 0.5/N, 0, 1);

% remove redundant variables
[~,xi] = unique(x);
x = x(xi);
y = y(xi);

% inverse functions
f = @(a)myinterp1(x, y, a, 'pchip');
finv = @(a)myinterp1(y, x, a, 'pchip');

% apply
y = f(x_orig);
