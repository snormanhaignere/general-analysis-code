function dfun_dx0_dx0 = hessian_finite_differences(fun,x0,eps)
% dfun_dx0_dx0 = hessian_finite_differences(fun,x0,eps)
% simple function for approximating the Hessian from finite differences
%
% fun is a function handle
% x0 is the value at which to compute the derivative
% eps is a small delta used to compute the derivative value, default is 1e-4
% 
% Example:
% A = rand(10);
% A = A + A';
% fun = @(x)(x' * A * x);
% x = rand(10,1);
% hessian_analytic = 2*A
% hessian_numeric = hessian_finite_differences(fun,x,1e-4)
% corr(hessian_analytic(:), hessian_numeric(:))
%
% Last edited by Sam Norman-Haignere on 12/28/14

if nargin < 3
    eps = 1e-4;
end

eps1 = eps;
eps2 = eps;

L = length(x0);
dfun_dx0_dx0 = nan(L,L);
for m = 1:L
    for n = 1:L
        % derivative with respect to m at x0(n)+eps2/2
        xp = x0;
        xp(m) = xp(m)+eps1/2;
        xp(n) = xp(n)+eps2/2;
        xn = x0;
        xn(m) = xn(m)-eps1/2;
        xn(n) = xn(n)+eps2/2;
        d1 = (fun(xp)-fun(xn))/eps1;
        
        % derivative with respect to m at x0(n)-eps2/2
        xp = x0;
        xp(m) = xp(m)+eps1/2;
        xp(n) = xp(n)-eps2/2;
        xn = x0;
        xn(m) = xn(m)-eps1/2;
        xn(n) = xn(n)-eps2/2;
        d2 = (fun(xp)-fun(xn))/eps1;
        
        % change in estimated derivatives with respect to n
        dfun_dx0_dx0(m,n) = (d1-d2)/eps2;
    end
end