function [B, best_K] = deconv1D_weights_from_2way_crossval(F, Y, n_delays, folds, method, K, MAT_file)

% feature MAT file
if ischar(F)
    load(F, 'F');
end

% data MAT file
if ischar(Y)
    load(Y, 'Y');
end

% number of folds
if nargin < 4
    folds = 10;
end

% ridge is the default method
if nargin < 5
    method = 'ridge';
end

% file to save predictions to
if nargin < 7
    MAT_file = [];
end

% default range of regularization parameters
if nargin < 6
    switch method
        case 'least-squares'
            K = [];
        case 'ridge'
            K = 2.^(-30:30);
        case 'pls'
            K = 1:round(P/3);
        case 'lasso'
            K = 2.^(-20:20);
        otherwise
            error('No valid method for %s\n', method);
    end
end

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
B = nan(n_features * n_delays+1, size(Y,2));
best_K = nan(1,size(Y,2));
for i = 1:size(Y,2)
    [B(:,i), best_K] = ...
        regress_weights_from_2way_crossval(F_shifted, ...
        Y(:,i), folds, method, K);
end

% reshape betas
B = reshape(B(2:end), [dims(2:end), n_delays, size(Y,2)]);


% save results
if ~isempty(MAT_file)
    save(MAT_file, 'B', 'best_K');
end