function r_smps = ...
    bootstrapped_normalized_correlation_within_folds(X,Y,folds,n_smps)

% Boostrapped version of the noise-corrected correlation, calculated within
% folds. 
% 
% see normalized_correlation_within_folds.m
% 
% Example with a perfectly correlated signal and independent noise.
% Normalized correlation should equal 1.
% nd = 10000;
% sig = randn(nd,1);
% X = randn(nd,3) + sig*ones(1,3);
% Y = randn(nd,4)*2 + sig*ones(1,4);
% folds = ones(1000,1) * (1:10);
% folds = folds(:);
% r_smps = bootstrapped_normalized_correlation_within_folds(X,Y,folds,100);
% hist(r_smps)
% 
% 2016-11-18: Created by Sam NH

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

% boostrapped samples
smps = nan(size(X,1), n_smps);
for i = 1:n_folds
    xi = find(i == folds);
    smps(xi,:) = xi(randi(length(xi), [length(xi), n_smps]));    
end
clear xi;

% calculate normalized correlation
r_smps = nan(n_smps,1);
for i = 1:n_smps
    r_smps(i) = normalized_correlation_within_folds(...
        X(smps(:,i),:), Y(smps(:,i),:), folds);
end

if any(isnan(r_smps(:)))
    fprintf('Unable to calculate r2 due to unreliable measures for %.1f%% of samples\n', mean(isnan(r_smps(:)))*100);
end
