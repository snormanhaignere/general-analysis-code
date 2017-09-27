function [Yh, B, pred_stats, weight_stats] = ...
    deconv1D_crossval(F, Y, delays, varargin)

% Implements 1D convolution by shifting a set of feature vectors by a set of
% delays and then performing regularized linear regression with
% cross-validation. By default the code both predicts responses in left out data
% (using 3-fold cross-validation) and estimates weights for the prediction
% (using 2-fold cross-validation). The analysis depends heavily on custom
% regression scripts. See:
% 
% regress_predictions_from_3way_crossval.m
% regress_weights_from_2way_crossval.m
% 
% -- Inputs -- 
% 
% Y: Data array formatted as [n_timepoints x n_stimuli x n_data_matrices]. The
% row dimension should represent time, i.e. the dimension over which convolution
% is performed. The column dimension can be used to represent multiple
% timeseries from the same data-generative process (e.g. responses from the same
% neuron/electrode to different stimuli). The third dimension is used to store
% data matrices for multiple data-generating processes. The analysis is
% performed separately for each matrix indexed by the third dimension. However,
% there are computational savings to implementing the analysis jointly for
% multiple data matrices (e.g. only need to compute SVD of the feature matrix
% once). 
% 
% F: Feature array formatted as [n_timepoints x n_stimuli x n_features].
% Same format as the data array except the third dimensions contains different
% features instead of different data generating processes. 
% 
% -- Outputs -- 
% 
% Yh: Predicted response, same dimensionality as Y
% 
% B: Estimated weights for the impulse response, [n_features x n_delays x
% n_data_matrices]
% 
% pred_stats: useful stats related to the prediction of Yh
% 
% weight_stats: useful stats related to the computation of B
% 
% -- Example --
% 
% % Two feature timecourses
% N = 100;
% M = 2;
% F = randn(N,M);
% 
% % Impulse response function for each timecourse
% % based on 5 delays
% n_delays = 5;
% h = randn(M,n_delays);
% 
% % Shifted copies of the features
% F_shifted = add_delays(F, 0:n_delays-1);
% 
% % Convolve with impulse response
% Y = reshape(F_shifted, N, M*n_delays) * h(:);
% 
% % Add noise
% Y_noisy = Y + randn(N,1)*2;
% 
% % Deconvolve
% [Yh, B] = deconv1D_crossval(reshape(F, [N,1,M]), reshape(Y_noisy, [N,1,1]), 0:n_delays-1);
% 
% % Show results
% figure;
% subplot(2,1,1);
% plot([Yh, Y]); legend('True', 'Predicted');
% title('Timecourses');
% subplot(2,1,2);
% plot(h', 'b-');
% hold on;
% plot(B', 'r-');
% title('Weights');
% 
% 2017-06-04/06: Created, Sam NH

%% Parameters

% whether or not to compute predictions and weights
I.prediction = true;
I.weights = true;

% value to pad feature matrix with
I.pad_value = 0;

% whether to perform cross validation over time dimension or the second (e.g.
% stimulus) dimension when present, default is to do the cross-validation with
% respect to the "stimulus" dimension when there are at least 3 stimuli present
if size(Y,2) >= 3
    I.crossval_dimension = 2;
else
    I.crossval_dimension = 1;
end

% default regression parameters, see regress_predictions_from_3way_crossval
I.test_folds = 2;
I.train_folds = 2;
I.regression_method = 'ridge';
I.demean_feats = true;
I.std_feats = false;
switch I.regression_method
    case 'least-squares'
        I.K = [];
    case 'ridge'
        I.K = 2.^(-1000:1000);
    case 'pls'
        I.K = 1:round(P/3);
    case 'lasso'
        I.K = 2.^(-20:20);
    otherwise
        error('No valid method for %s\n', method);
end

% parameters specifically for batching / using SLURM
% see regress_predictions_wrapper.m
I.slurm = false;
I.batch_size = 100;
I.overwrite = false;
I.max_num_process = 25;
I.output_directory = pwd;

% modify parameters based on user input
I = parse_optInputs_keyvalue(varargin, I);

% check parameters
assert(any(I.crossval_dimension == [1 2]));

%% Add delays and format the feature and data matrix

% dimensionality of features and data
F_dims = size(F);
Y_dims = size(Y);
assert(length(F_dims)<=3 && length(Y_dims)<=3);
assert(all(F_dims(1:2) == Y_dims(1:2)));

% make sure there are three dimensions
F_dims = [F_dims, 1];
Y_dims = [Y_dims, 1];
F_dims = F_dims(1:3);
Y_dims = Y_dims(1:3);

% create array with delays
F_shifted = add_delays(F, delays);
assert(size(F_shifted,1) == size(Y,1));

% unwrap so there a single predictor per delayed regressor
% time * stim x features * delays
n_delays = length(delays);
F_shifted = reshape(F_shifted, F_dims(1)*F_dims(2), F_dims(3)*n_delays);

% unwrap data matrix
Y = reshape(Y, Y_dims(1)*Y_dims(2), Y_dims(3));
assert(size(Y,1) == size(F_shifted,1));

%% Determine folds for cross-validation

% testing fold indices for specified dimension
if isscalar(I.test_folds)
    test_fold_indices = subdivide(Y_dims(I.crossval_dimension), I.test_folds);
else
    test_fold_indices = I.test_folds;
    assert(length(test_fold_indices) == Y_dims(I.crossval_dimension));
end

% train fold indices for specified dimension
if isscalar(I.train_folds)
    train_fold_indices = nan(1, Y_dims(I.crossval_dimension));
    unique_test_indices = unique(test_fold_indices);
    for i = 1:length(unique_test_indices)
        xi = test_fold_indices == unique_test_indices(i);
        train_fold_indices(xi) = subdivide(sum(xi), I.train_folds);
    end
else
    train_fold_indices = I.train_folds;
    assert(length(train_fold_indices) == Y_dims(I.crossval_dimension));
end

% copy over other dimension
if I.crossval_dimension == 2
    test_fold_indices = repmat(test_fold_indices(:)', Y_dims(1), 1);
    train_fold_indices = repmat(train_fold_indices(:)', Y_dims(1), 1);
elseif I.crossval_dimension == 1
    test_fold_indices = repmat(test_fold_indices(:), 1, Y_dims(2));
    train_fold_indices = repmat(train_fold_indices(:), 1, Y_dims(2));
else
    error('Cross-validation dimension should be 1 or 2');
end

% check size of the indices
assert(all(size(test_fold_indices) == Y_dims(1:2)));

% unwrap
test_fold_indices = test_fold_indices(:);
train_fold_indices = train_fold_indices(:);

%% Regression analyses

% prediction using 3-fold cross-validation
if I.prediction
    
    if I.slurm
        [Yh, pred_stats.test_fold_indices] = ...
            regress_predictions_wrapper(F_shifted, Y, ...
            'test_folds', test_fold_indices, 'train_folds', train_fold_indices, ...
            'method', I.regression_method, 'K', I.K, ...
            'std_feats', I.std_feats, 'demean_feats', I.demean_feats, ...
            'slurm', I.slurm, 'batch_size', I.batch_size, 'overwrite', I.overwrite, ...
            'output_directory', I.output_directory, ...
            'max_num_process', I.max_num_process);
    else
        [Yh, pred_stats.mse, pred_stats.r, ...
            pred_stats.test_fold_indices, X] = ...
            regress_predictions_from_3way_crossval(F_shifted, Y, ...
            'test_folds', test_fold_indices, 'train_folds', train_fold_indices, ...
            'method', I.regression_method, 'K', I.K, ...
            'std_feats', I.std_feats, 'demean_feats', I.demean_feats);
    end
    
    % re-wrap to match original dimensions of Y
    Yh = reshape(Yh, Y_dims);
    pred_stats.test_fold_indices = reshape(pred_stats.test_fold_indices, Y_dims(1:2));
    
else
    Yh = [];
    pred_stats = [];
end

% weights using 2-fold cross-validation
if I.weights
    [B, weight_stats.best_K, weight_stats.mse, ...
        weight_stats.r, weight_stats.norm_mse] = ...
        regress_weights_from_2way_crossval(F_shifted, Y, 'folds', I.test_folds(:), ...
        'method', I.regression_method, 'K', I.K, ...
        'std_feats', I.std_feats, 'demean_feats', I.demean_feats);
    
    % save offset separately
    weight_stats.offset = B(1,:);
    
    % format the weights to be delay x feature x data vector
    assert(size(B,1)-1 == F_dims(end) * n_delays);
    assert(size(B,2) == size(Y,2));
    B = reshape(B(2:end, :), [F_dims(end), n_delays, size(Y,2)]);
    
else
    
    B = [];
    weight_stats = [];
    
end


