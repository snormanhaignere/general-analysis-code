function r = normalized_correlation_within_folds_v2(X, Y, folds, varargin)

% Calculates the noise-corrected correlation but within folds. Useful in
% combination with regression scripts (e.g.
% regress_predictions_from_3way_crossval.m)
% 
% Very similar to version 1, but relies on normalized_correlation_v2.m instead
% of normalized_correlation.m
%
% 2017-03-16: Created by Sam NH
% 
% 2017-03-17: Fixed small syntax bug

I.same_noise = false;
I.metric = 'pearson';
I = parse_optInputs_keyvalue(varargin, I);

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

r_folds = nan(n_folds,1);
for i = 1:n_folds
    xi = i == folds;
    r_folds(i) = normalized_correlation_v2(...
        X(xi,:), Y(xi,:), 'same_noise', I.same_noise, 'metric', I.metric);
end

r = mean(r_folds);