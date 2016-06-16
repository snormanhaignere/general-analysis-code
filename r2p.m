function p_signed_log10 = r2p(r, N, tail)

% Transforms a pearson correlation (r) to a p-value given that the number of
% samples used to compute the correlation. This function is a slightly modified
% version of the built-in function pvalPearson, which is contained with the
% built-in script for corr. The p-value is transformed to a signed -log10[p]
% value.

if nargin < 3
    tail = 'both';
end

% Tail probability for Pearson's linear correlation.
t = r.*sqrt((N-2)./(1-r.^2)); % +/- Inf where r == 1

switch tail
    case 'both' % 'both or 'ne'
        p = 2*tcdf(-abs(t),N-2);
    case 'right' % 'right' or 'gt'
        p = tcdf(-t,N-2);
    case 'left' % 'left' or 'lt'
        p = tcdf(t,N-2);
end

p_signed_log10 = -log10(p) .* sign(r);