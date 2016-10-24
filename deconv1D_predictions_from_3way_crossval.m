function Yh = deconv1D_predictions_from_3way_crossval(F, Y, n_delays, folds, method, K, varargin)

% unwrap different features
dims = size(F);
F = reshape(F, dims(1), prod(dims(2:end)));
[n_smps, n_features] = size(F);

% create shifted copies
F_shifted = zeros([n_smps, n_features, n_delays]);
for i = 1:n_delays
    F_shifted( (i:n_smps), :, i ) = F( 1:n_smps-i+1, : );
end

% unwrap
F_shifted = reshape(F_shifted, [n_smps, n_features * n_delays]);

% betas
Yh = nan(size(Y));
for i = 1:size(Y,2)
    Yh(:,i) = regress_predictions_from_3way_crossval(F_shifted, ...
        Y(:,i), folds, method, K, varargin);
end