function [r,r_std_err,r_smps] = bootstrapped_normalized_correlation(x,y,nsmps)
% function [r,r_std_err,r_smps] = bootstrapped_normalized_correlation(x,y,nsmps)
% 
% Computes the correlation between two random variables normalized by the reliability of the two variables. 
% Bootstrapping is used to calculate standard errors.
% 
% See "normalized_correlation.m" for details of the normalization.
% 
% Example with a perfectly correlated signal and independent noise.
% Normalized correlation should equal 1.
% nd = 100;
% sig = randn(nd,1);
% X = randn(nd,3) + sig*ones(1,3);
% Y = randn(nd,4)*2 + sig*ones(1,4);
% [r,r_std_err] = bootstrapped_normalized_correlation(X,Y,1000)
% 
% Last modified by Sam Norman-Haignere on 12/26/14

% normalized correlation
r = normalized_correlation(x,y);

% bootstrapped normalized correlation
nd = size(x,1);
smps = randi(nd, [nd, nsmps]);
r_smps = nan(nsmps,1);
for i = 1:nsmps
    r_smps(i) = normalized_correlation(x(smps(:,i),:),y(smps(:,i),:));
end

if any(isnan(r_smps(:)))
    fprintf('Unable to calculate r2 due to unreliable measures for %.1f%% of samples\n', mean(isnan(r_smps(:)))*100);
end

if mean(isnan(r_smps(:))) > 0.1
    fprintf('Too many unreliable measures to calculate standard error\n');
    r_std_err = [NaN NaN];
else
    r_std_err = stderr_from_samples(r_smps(~isnan(r_smps)));
end
