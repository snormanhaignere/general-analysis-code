function y = outlier_metric(x, logbounds)

if nargin < 2
    logbounds = [2 3];
end

standardization_factor = ...
    diff(quantile(x(~isnan(x)), [0.4 0.6])) / norminv(0.6, 0, 1);
x_standardized = (x-nanmedian(x)) / standardization_factor;
y = sigmf(abs(x_standardized), logbounds);


