function dfun_dx0 = gradient_finite_differences(fun,x0,eps)
% dfun_dx0 = gradient_finite_differences(fun,x0,eps)
% simple function for approximating a gradient from finite differences
% 
% fun is a function handle
% x0 is the value at which to compute the derivative
% eps is a small delta used to compute the derivative value, default is 1e-6
% 
% Example:
% A = rand(10);
% A = A + A';
% fun = @(x)(x' * A * x);
% x = rand(10,1);
% gradient_analytic = 2*A*x
% gradient_numeric = gradient_finite_differences(fun,x,1e-6)
% corr(gradient_analytic(:), gradient_numeric(:))
% 
% Last edited by Sam Norman-Haignere on 12/28/14

if nargin < 3
    eps = 1e-6;
end

L = length(x0);
dfun_dx0 = nan(L,1);
for i = 1:L
    xp = x0;
    xp(i) = xp(i)+eps/2;
    xn = x0;
    xn(i) = xn(i)-eps/2;
    dfun_dx0(i) = (fun(xp)-fun(xn))/eps;
end