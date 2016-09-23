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
%
% 2016-08-26: Changed code so that the returned vector/matrix is of the same
% dimesions as the input statistic. Also added an error check.
%
% 2016-09-10: Made it possible to specify which tail of the null to use for
% computing significance
%
% 2016-09-11: Fix a bug in the computation of right- and left-tailed
% significance

I.tail = 'both';
I = parse_optInputs_keyvalue(varargin, I);

% dimensions of the input statistics
stat_dims = size(stat);

% convert all vectors to column vectors
if isvector(stat) && ismatrix(null_stat)
    stat = stat(:);
end

% number of samples
n_samples = size(null_stat,1);
if n_samples < 10
    error('Should be more than 10 samples.');
end

% check correspondence of dimensions between stat and null_stat
for i = 2:ndims(null_stat)
    assert(size(null_stat,i) == size(stat,i-1));
end

% mean and standard deviation of the null
m = squeeze_dims(mean(null_stat,1),1);
sd = squeeze_dims(std(null_stat,[],1),1);

% z-value of test statistic
z = (stat - m)./sd;

switch I.tail
    case 'both' % 'two-tailed'
        signed_log10p = -log10(2*normcdf(-abs(z), 0, 1));
        assert(all(signed_log10p(~isnan(signed_log10p)) >= 0));
        signed_log10p = sign(z) .* signed_log10p;
        
    case 'right'
        signed_log10p = -log10(normcdf(-z, 0, 1));
        assert(all(signed_log10p(~isnan(signed_log10p)) >= 0));
        
    case 'left'
        signed_log10p = -log10(normcdf(z, 0, 1));
        assert(all(signed_log10p(~isnan(signed_log10p)) >= 0));
        
    otherwise
        error('No matching case for I.tail value %s', I.tail);
end

% reshape back to dimensions of stat
signed_log10p = reshape(signed_log10p, stat_dims);