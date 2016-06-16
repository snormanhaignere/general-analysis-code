function E = confidence_intervals_from_samples(X)
% function confidence_intervals_from_samples(X)
% 
% Computes confidence intervals from a vector of samples, using
% the CDF of the samples. If X is a matrix, standard errors
% are computed for every column.
% 
% Example
% X = randn(10000,4);
% confidence_intervals_from_samples(X)

% dimension of input matrix
dims = size(X);

% reshape to 2D matrix
X = reshape(X, [dims(1),prod(dims(2:end))]);
[M, N] = size(X);

% errors for each column
E = nan(2,N);
for i = 1:N
    xsort = sort(X(:,i),'ascend');
    E(:,i) = interp1(linspace(0,1,M)', xsort, [0.025 0.975]); % standard errors
end

% reshape back to original dimensions
E = reshape(E, [2,dims(2:end)]);