function bc = bhat_coef(X,Y,varargin)

% Calculates the Bhattacharyya coefficient between two vectors, or corresponding
% columns of two matrices. Each column is assumed to contain samples from an
% underlying distribution, which is approximated using a histogram. 
% 
% see https://en.wikipedia.org/wiki/Bhattacharyya_distance#Bhattacharyya_coefficient
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
I = parse_optInputs_keyvalue(varargin, I);

bc = nan(1,n_cols);
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
    
    % Calculate Jensen-Shannon divergence
    bc(i) = sum(sqrt(p.*q));
    
end


