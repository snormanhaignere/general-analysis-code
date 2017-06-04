function Yh = deconv1D_predictions_from_3way_crossval(F, Y, n_delays, folds, method, K, MAT_file, std_feats, demean_feats)

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

% default range of regularization parameters
if nargin < 6
    switch method
        case 'least-squares'
            K = [];
        case 'ridge'
            K = 2.^(-100:100);
        case 'pls'
            K = 1:round(P/3);
        case 'lasso'
            K = 2.^(-20:20);
        otherwise
            error('No valid method for %s\n', method);
    end
end

% file to save predictions to
if nargin < 7
    MAT_file = [];
end

if nargin < 8
    std_feats = true;
end

if nargin < 9
    demean_feats = true;
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
Yh = nan(size(Y));
for i = 1:size(Y,2)
    Yh(:,i) = regress_predictions_from_3way_crossval(F_shifted, Y(:,i), ...
        'test_folds', folds, 'train_folds', folds, 'method', method, 'K', K, ...
        'std_feats', std_feats, 'demean_feats', demean_feats);
end

% save results
if ~isempty(MAT_file)
    save(MAT_file, 'Yh');
end