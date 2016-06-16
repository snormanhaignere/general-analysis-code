function [r,r_std_err,r_smps] = bootstrapped_correlation(x,y,nsmps)
% function [r,r_std_err,r_smps] = bootstrapped_correlation(x,y,nsmps)
% 
% Computes the pearson correlation cofficient between two vectors x and y.
% The standard error of the correlation is computed via bootstrapping.
% Uses the function "fastcorr.m" to quickly compute correlation coefficients
% between corresponding vectors of two different matrices.
% 
% x = randn(100,1);
% y = randn(100,1) + x;
% [r,r_std_err] = bootstrapped_correlation(x,y,1000)
% 
% Last modified by Sam Norman-Haignere on 12/28/14

% pearson correlation
r = fastcorr(x,y);

% number of samples
n = size(x,1);
xi = randi(n, [n, nsmps]);
r_smps = fastcorr(x(xi), y(xi));
r_smps = sort(r_smps,'ascend');

% standard error calculated by interpolating the CDF of bootstrapped samples
r_std_err = interp1(linspace(0,1,nsmps), r_smps, normcdf([-1 1],0,1));