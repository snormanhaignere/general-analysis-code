function E = stderr_from_samples_withsub_corrected(X)
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

% dimension of input matrix
dims = size(X);
% ndims = length(dims);

% reshape to 2D matrix
X = reshape(X, [dims(1),prod(dims(2:end))]);
[M, N] = size(X);

% number of columns
nconds = prod(dims(2:end));

% correction factor to make estimates unbiased
correction_factor = sqrt(1/(nconds*(nconds-1)/(nconds^2)));

% row means
row_means = mean(X,2);
col_medians = mean(X,1);

% data with zero-mean rows
X_zeromean_rows = X - repmat(row_means, [1 prod(dims(2:end))]);

% errors for each column
E = nan(2,N);
for i = 1:N
    x = X_zeromean_rows(:,i);
    xsort = sort(x-median(x),'ascend');
    E(:,i) = correction_factor * interp1(linspace(0,1,M)', xsort, normcdf([-1 1]',0,1)) + col_medians(i); % standard errors
end

% reshape back to original dimensions
E = reshape(E, [2,dims(2:end)]);

function outMat = sumdims(inMat, dim)
% sums matrix inMat across dimensions in vector dim

for xx = 1:length(dim)
    %     curDim = dim(xx)
    %     outMat = mean(inMat, curDim)
    %     dim = setdiff(dim, curDim);
    %     dim(dim>curDim) = dim(dim>curDim)-1;
    inMat = nansum(inMat, dim(xx));
end
outMat = inMat;