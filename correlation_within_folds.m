function r = correlation_within_folds(x,y,folds,metric)

% 2017-10-05: Updated with normalized squared error

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

r_folds = nan(n_folds, 1);
for i = 1:n_folds
    xi = i == folds;
    switch metric
        case 'pearson'
            r_folds(i) = corr(x(xi,:), y(xi,:));
        case 'demeaned-squared-error'
            r_folds(i) = corr_variance_sensitive_symmetric(x(xi,:), y(xi,:));
        case 'normalized-squared-error'
            r_folds(i) = normalized_squared_error(x(xi,:), y(xi,:));
        otherwise
            error('Switch statement fell through');
    end
end

r = mean(r_folds);