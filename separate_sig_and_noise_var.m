function [sig_var, noise_var, total_var, error_var] = ...
    separate_sig_and_noise_var(X, varargin)

% Assumes each column of X was created by a fixed signal present throughout all
% columns plus uncorrelated noise, independently sampled for each column. Given
% this assumption, this function estimates the variance of the signal and noise
% separately.
% 
% Used by noisecorr_metrics.
% 
% 2017-03-16: Created, Sam NH
% 
% 2017-09-26: Made it possible to compute the power instead of the variance

% whether or not to compute the power instead of the variance
I.power = false;
I = parse_optInputs_keyvalue(varargin, I);

% function used to compute power or variance
if I.power
    f = @(a)mean(a.^2,1);
else
    f = @(a)var(a,[],1);
end

% total variance in the noisy signal
total_var = mean(f(X),2);

% return only the total variance if there is only one trial
if size(X,2) < 2
    sig_var = NaN;
    noise_var = NaN;
    error_var = NaN;
    return;
end

% estimate the error variance
count = 0;
error_var = 0;
for i = 1:size(X,2)
    e = bsxfun(@minus, X(:,i), X(:,i+1:end));
    error_var = error_var + sum(f(e));
    count = count + (size(X,2) - i);
end
error_var = error_var/count;
clear e count;

% noise variance is half of the error variance
noise_var = error_var/2;

% variance of the signal assuming uncorrelated noise
sig_var = total_var - noise_var;

% var(X1 - X2) = var(X1) + var(X2) - cov(X1, X2);
% var(X1 - X2) = 2*(var(X)+var(N)) - var(X)
% (var(X1) + var(X2)) - var(X1 - X2) = var(X)
