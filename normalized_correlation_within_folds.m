function r = normalized_correlation_within_folds(...
    X, Y, folds, varargin)

% Calculates the noise-corrected correlation but within folds. Useful in
% combination with regression scripts.
%
% see regress_predictions_from_3way_crossval.m
%
% Example with a perfectly correlated signal and independent noise.
% Normalized correlation should equal 1.
% nd = 10000;
% sig = randn(nd,1);
% X = randn(nd,3) + sig*ones(1,3);
% Y = randn(nd,4)*2 + sig*ones(1,4);
% folds = subdivide(nd, 10);
% r = normalized_correlation_within_folds(X,Y,folds)
%
% 2016-11-18: Created by Sam NH
%
% 2016-12-20: Made it possible to calculate rank correlation in addition to
% pearson (default)
% 
% 2017-03-15: Streamlined code, added a new correlation_type (variance-sensitive)
% 
% 2017-03-31: Further streamlined, made z-averaging an option, and also made it
% an option as to whether to average correlation metrics before combining them
% 
% 2017-08-25: Made it possible to only compute cross column correlations when
% computing the numeratore of the normalized correlation

I.metric = 'pearson';
I.z_averaging = true;
I.average_before_combining_terms = true;
I.only_cross_column_corr = false;
I = parse_optInputs_keyvalue(varargin, I);

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

% whether or not to use z-averaging
if I.z_averaging
    averaging_func = @(a)tanh(mean(atanh(a(:))));
else
    averaging_func = @(a)mean(a(:));
end

% three correlation metrics for each fold
rXX = nan(n_folds,1);
rYY = nan(n_folds,1);
rXY = nan(n_folds,1);
for i = 1:n_folds
    
    switch I.metric
        case {'pearson', 'r2'}
            similarity_func = @nancorr;
        case {'rank', 'rank-r2'}
            similarity_func = @nanrankcorr;
        otherwise
            error('No matching case');
    end
    
    xi = i == folds;
    
    R = similarity_func(X(xi,:), X(xi,:));
    rXX(i) = averaging_func(R(~eye(size(R))));
    
    R = similarity_func(Y(xi,:), Y(xi,:));
    rYY(i) = averaging_func(R(~eye(size(R))));
    
    R = similarity_func(X(xi,:), Y(xi,:));
    if I.only_cross_column_corr
        rXY(i) = averaging_func(R(:));
    else
        rXY(i) = averaging_func(R(~eye(size(R))));
    end
    
end

if I.average_before_combining_terms
    rXX = averaging_func(rXX);
    rYY = averaging_func(rYY);
    rXY = averaging_func(rXY);
    if rXX <= 0 || rYY <=0
        r = NaN;
    else
        r = rXY / (sqrt(rXX) * sqrt(rYY));
    end
else
    if any(rXX <= 0) || any(rYY <=0)
        r = NaN;
    else
        r = mean(rXY ./ (sqrt(rXX) .* sqrt(rYY)));
    end
end

if any(strcmp(I.metric, {'r2', 'rank-r2'}))
    r = sign_and_square(r);
end