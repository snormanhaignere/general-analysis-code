function [r2_noise_corrected, r_noise_corrected] = ...
    regress_varexplained_noisecorr_nfold(F, y, varargin)

% predictions
yh = nan(size(y));
for i = 1:size(y,2)
    yh(:,i) = regress_predictions_from_3way_crossval(F, y(:,i), varargin{:});
end

% noise-corrected r2
[r_noise_corrected, r2_noise_corrected] = normalized_correlation(y,yh);