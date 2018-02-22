function signed_log10p = sig_via_null_counts(test_stat, null_samples, varargin)

% Computes a measure of significance for a sample statistic using samples from
% the null (e.g. computed via a permutation test). P-values are computed by
% counting the fraction of samples from the null that exceed the test statistic
% in magnitude. Signed -log10[p] values are returned
% 
% -- Inputs -- 
% 
% test_stat: N1 x N2 ... array
% 
% null_samples: samples x N1 x N2 ... array
% 
% -- Optional Arguments -- 
% 
% Optional arguments are specified as name-value pairs, e.g:
% normalized_correlation_v2(X, Y, 'NAME', 'VALUE', ...) 
% 
% tail: 'left', 'right', or 'both' (default)
% 
% % -- Guassian example -- 
% N = 100e3;
% variances = [1 2 3];
% null_smps = normrnd(0,1,[N,1]) * sqrt(variances);
% 
% estimated_signed_log10p = sig_via_null_counts([3 3 3], null_smps)
% analytic_log10p = -log10(2*normcdf(-[3 3 3], [0 0 0], sqrt(variances)))
% estimated_signed_log10p = sig_via_null_counts([3 3 3], null_smps, 'tail', 'right')
% analytic_log10p = -log10(normcdf(-[3 3 3], [0 0 0], sqrt(variances)))
% 
% 2017-03-17: Added some additional error checks

I.tail = 'both';
I = parse_optInputs_keyvalue(varargin, I);

% dimensions of the input statistics
stat_dims = size(test_stat);

% convert vector to column vector
if isvector(test_stat) && ismatrix(null_samples)
    test_stat = test_stat(:);
end

% check correspondence of dimensions between stat and null_stat
for i = 2:ndims(null_samples)
    if ~(size(null_samples,i) == size(test_stat,i-1));
        error('Dimensions of test statistic don''t match with those of the null');
    end
end

% dimensions
n_null_smps = size(null_samples,1);
if n_null_smps < 10
    error('Should be more than 10 samples.');
end

% replicate stat over the dimension
stat_rep = repmat( shiftdim(test_stat, -1),  [n_null_smps, ones(1,ndims(test_stat))]);

% calculate two-tailed p-value
switch I.tail
    case 'both' % 'two-tailed'
        p = min(mean(null_samples >= stat_rep, 1), mean(null_samples <= stat_rep, 1)) * 2;
        
    case 'right'
        p = mean(null_samples >= stat_rep, 1);
        
    case 'left'
        p = mean(null_samples <= stat_rep, 1);
        
    otherwise
        error('No matching case for I.tail value %s', I.tail);
end

% remove first dimension
p = squeeze_dims(p, 1);

% set p-values of zero to the smallest possible p-value
p(p==0) = 1/n_null_smps;

% convert to signed -log10[p]
above_or_below_null = sign(test_stat - squeeze_dims(median(null_samples),1));
signed_log10p = above_or_below_null .* -log10(p);

% reshape back to dimensions of stat
signed_log10p = reshape(signed_log10p, stat_dims);
