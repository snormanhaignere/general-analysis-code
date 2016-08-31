function d = jsdiv(X,Y,varargin)

% Calculates the jensen-shannon divergence between two vectors, or corresponding
% columns of two matrices. Each column is assumed to contain samples from an
% underlying distribution, which is approximated using a histogram. A constant
% epsilon is added to the histogram to avoid taking the log of zero. 
% 
% see https://en.wikipedia.org/wiki/Jensen%E2%80%93Shannon_divergence
% 
% 2016-08-30 - Created, Sam NH

% ensure size of the inputs is the same
% and that inputs are a 2D matrix or vector
assert(all(size(X)==size(Y)));
assert(ismatrix(X));

% dimensionality of input
[n_samples, n_cols] = size(X);

% optional input arguments
I.n_bins = n_samples/10;
I.eps_factor = 1e-6;
I = parse_optInputs_keyvalue(varargin, I);

% epsilon equals a factor divided by the number of bins
eps = I.eps_factor / I.n_bins;

d = nan(1,n_cols);
for i = 1:n_cols
    
    % bounds of the histogram
    bounds = [...
        min(min(X(:,i)), min(Y(:,i))), ...
        max(max(X(:,i)), max(Y(:,i)))];
    
    % calculate histogram
    bins = linspace(bounds(1), bounds(2), I.n_bins);
    p = hist(X(:,i), bins);
    q = hist(Y(:,i), bins);
    
    % normalize
    p = p / sum(p);
    q = q / sum(q);
    
    % add epsilon and renormalize
    p = p + eps;
    p = p / sum(p);
    q = q + eps;
    q = q / sum(q);
    
    % Calculate Jensen-Shannon divergence
    m = p/2 + q/2;
    d(i) = sum(p .* log2(p ./ m))/2 + sum(q .* log2(q ./ m))/2;
    
end


