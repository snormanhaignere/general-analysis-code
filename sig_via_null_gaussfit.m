function signed_log10p = sig_via_null_gaussfit(stat, null_stat, varargin)

% Computes a measure of significance for a sample statistic using samples from
% the null (e.g. computed via a permutation test). P-values are computed by
% fitting a gaussian distribution to the null and estimating the tail
% probability given this fit. This function assumes the samples are in the first
% dimension of matrix null_stat (see example below). 
% 
% % -- Guassian example -- 
% N = 100e3;
% variances = [1 2 3];
% null_smps = normrnd(0,1,[N,1]) * sqrt(variances);
% 
% estimated_signed_log10p = sig_via_null_gaussfit([3 3 3], null_smps)
% analytic_log10p = -log10(2*normcdf(-[3 3 3], [0 0 0], sqrt(variances)))'

if isvector(stat)
    stat = stat(:);
end

% mean and standard deviation of the null
m = squeeze_dims(mean(null_stat),1);
sd = squeeze_dims(std(null_stat),1);

% z-value of test statistic
z = (stat - m)./sd;

% tail probability (two-tailed)
signed_log10p = sign(z) .* -log10(2*normcdf(-abs(z), 0, 1));