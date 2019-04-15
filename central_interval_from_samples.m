function E = central_interval_from_samples(X, alpha, varargin)

% function central_interval_from_samples(X)
% 
% Computes central interval from a vector of samples, using the CDF of the
% samples. If X is a matrix, central intervals are computed for every
% column. Tail probability is specified by alpha.
% 
% -- Example -- 
% % Confidence interval for normal distribution is [-1.96, 1.96]
% X = randn(100000,4); 
% central_interval_from_samples(X, 0.05)

I.NaN_frac = 0.01;
I = parse_optInputs_keyvalue(varargin, I);

assert(isscalar(alpha));

% dimension of input matrix
dims = size(X);

% reshape to 2D matrix
X = reshape(X, [dims(1),prod(dims(2:end))]);
[~, N] = size(X);

% errors for each column
E = nan(2,N);
for i = 1:N
    xsort = sort(X(:,i),'ascend');
    if mean(isnan(xsort)) < I.NaN_frac % allow N% of samples to be discard
        xsort(isnan(xsort)) = [];
        E(:,i) = interp1(linspace(0,1,length(xsort))', xsort, [alpha/2, 1-alpha/2]); % standard errors
    end
end

% reshape back to original dimensions
E = reshape(E, [2,dims(2:end)]);