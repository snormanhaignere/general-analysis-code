function signed_log10p = sig_via_null_counts(stat, null_stat, varargin)

% Computes a measure of significance for a sample statistic using samples from
% the null (e.g. computed via a permutation test). P-values are computed by
% counting the fraction of samples from the null that exceed the test statistic
% in magnitude. Signed -log10[p] values are returned
% 
% % -- Guassian example -- 
% N = 100e3;
% variances = [1 2 3];
% null_smps = normrnd(0,1,[N,1]) * sqrt(variances);
% 
% estimated_signed_log10p = sig_via_null_counts([3 3 3], null_smps)
% analytic_log10p = -log10(2*normcdf(-[3 3 3], [0 0 0], sqrt(variances)))'

if isvector(stat)
    stat = stat(:);
end

% dimensions
dims_stat = size(stat);
n_perms = size(null_stat,1);

% detect whether the statistics is above or below
% the median of the null
% above: 1
% below: -1
above_or_below_null = ...
    sign(stat - reshape(median(null_stat), dims_stat));

% replicate stat over the permuted dimension
stat_rep = repmat( shiftdim(stat, -1),  [n_perms, ones(1,ndims(stat))]);

% calculate two-tailed p-value
if above_or_below_null == 1
    p = 2 * mean(null_stat > stat_rep);
elseif above_or_below_null == -1
    p = 2 * mean(null_stat < stat_rep);
else
    error('above_or_below_null must be 1 or -1, not %d', above_or_below_null);
end
    
% remove singleton dimension
p = reshape(p, dims_stat);

% set p-values of zero to the smallest possible p-value
p(p==0) = 1/n_perms;

% convert to signed -log10[p]
signed_log10p = above_or_below_null .* -log10(p);

