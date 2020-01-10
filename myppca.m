function [U,S,V] = myppca(X, K, varargin)

clear I;
I.flip = false;
I.display = 'off';
I.maxiter = 1000;
I.tolfun = 1e-6;
I.finalsvd = true;
I = parse_optInputs_keyvalue(varargin, I);

if I.flip
    X = X';
end
[N,~] = size(X);

% calculate and remove mean
mu = nanmean(X,1);
Xd = bsxfun(@minus, X, mu);

% perform ppca analysis
opt = statset('ppca');
opt.TolFun = I.tolfun;
opt.MaxIter = I.maxiter;
opt.Display = I.display;
[Vp,USp] = ppca(Xd,K-1,'Options',opt);

% incorporate mean
% recon USp_ones * Vp_mean'
USp_ones = [ones(N,1), USp];
Vp_mean = [mu', Vp];
clear Usp Vp;

% format as svd
if I.finalsvd
    [U,S,V] = svd(USp_ones * Vp_mean', 'econ');
else
    s = sqrt(sum(USp_ones.^2));
    U = bsxfun(@times, USp_ones, 1./s);
    V = Vp_mean;
    S = diag(s);
    clear USp_ones Vp_mean s;
end

% now flip
if I.flip
    Vsave = V;
    V = U;
    U = Vsave;
    clear Vsave;
end