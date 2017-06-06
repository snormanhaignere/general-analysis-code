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
I.pad_value = 0;

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

% unwrap so there a single predictor per delayed regressor
% time * stim x features * delays
n_delays = length(delays);
F_shifted = reshape(F_shifted, F_dims(1)*F_dims(2), F_dims(3)*n_delays);
assert(size(F_shifted,1) == size(Y,1));

% unwrap data matrix
Y = reshape(Y, Y_dims(1)*Y_dims(2), Y_dims(3));
assert(size(Y,1) == size(F_shifted,1));

%% Regression analyses

% prediction using 3-fold cross-validation
if I.prediction
    [Yh, pred_stats.mse, pred_stats.r, pred_stats.test_fold_indices] = ...
        regress_predictions_from_3way_crossval(F_shifted, Y, ...
        'test_folds', I.test_folds, 'train_folds', I.train_folds, ...
        'method', I.regression_method, 'K', I.K, ...
        'std_feats', I.std_feats, 'demean_feats', I.demean_feats);
else
    Yh = [];
    pred_stats = [];
end

% weights using 2-fold cross-validation
if I.weights
    [B, weight_stats.best_K, weight_stats.mse, ...
        weight_stats.r, weight_stats.norm_mse] = ...
        regress_weights_from_2way_crossval(F_shifted, Y, 'folds', I.test_folds, ...
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


