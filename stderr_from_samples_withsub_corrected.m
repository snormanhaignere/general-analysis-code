function E = stderr_from_samples_withsub_corrected(X, varargin)
% function stderr_from_samples_withsub_corrected(X)
% 
% Computes standard errors from a vector of samples, using
% the CDF of the samples. If X is a matrix, standard errors
% are computed for every column.
% 
% The rows of the matrix are demeaned before computing standard errors
% and a correction factor is included to account for the loss of variance
% inevitable. See stderr_withsub_corrected.m for details.
% 
% Example
% X = randn(10000,2) + randn(10000,1)*ones(1,2) + ones(10000,1)*[1 2];
% analytic_within_subject_stderr = [[0 2]', [1 3]']
% across_subject_stderr = stderr_from_samples(X)
% within_subject_stderr = stderr_from_samples_withsub_corrected(X)

I.NaN_frac = 0.01;
I = parse_optInputs_keyvalue(varargin, I);

% dimension of input matrix
dims = size(X);
% ndims = length(dims);

% reshape to 2D matrix
X = reshape(X, [dims(1),prod(dims(2:end))]);

% number of conditions
N = size(X,2);

% correction factor to make estimates unbiased
correction_factor = sqrt(N/(N-1));

% row means
row_means = nanmean(X,2);
col_medians = nanmedian(X,1);

% data with zero-mean rows
X_zeromean_rows = bsxfun(@minus, X, row_means);
X_zeromedian_cols = bsxfun(@minus, X_zeromean_rows, nanmedian(X_zeromean_rows));

% central interval
central_frac = diff(normcdf([-1 1],0,1));
tail_frac = 1-central_frac;
E_biased = central_interval_from_samples(X_zeromedian_cols,tail_frac,'NaN_frac',I.NaN_frac);

% correction factor
E_corrected = correction_factor*E_biased;

% add back in column medians
E = bsxfun(@plus, E_corrected, col_medians);

% reshape back to original dimensions
E = reshape(E, [2,dims(2:end)]);