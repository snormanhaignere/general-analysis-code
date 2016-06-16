function E = stderr_from_samples(X)
% function stderr_from_samples(X)
% 
% Computes standard errors from a vector of samples, using
% the CDF of the samples. If X is a matrix, standard errors
% are computed for every column.
% 
% Example
% X = randn(10000,4);
% stderr_from_samples(X)

% dimension of input matrix
dims = size(X);

% reshape to 2D matrix
X = reshape(X, [dims(1),prod(dims(2:end))]);
[M, N] = size(X);

% errors for each column
E = nan(2,N);
for i = 1:N
    xsort = sort(X(:,i),'ascend');
    if mean(isnan(xsort)) < 0.01 % allow 1% of samples to be discard
        xsort(isnan(xsort)) = [];
        E(:,i) = interp1(linspace(0,1,length(xsort))', xsort, normcdf([-1 1]',0,1)); % standard errors
    end
end

% reshape back to original dimensions
E = reshape(E, [2,dims(2:end)]);