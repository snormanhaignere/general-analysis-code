function signed_log10p = sig_via_bootstrap_counts(smps, varargin)

% Estimate significance (-log10[p]) via bootstrapped samples. Counts fraction of
% bootstrapped samples that fall below or above the null test value (zero by
% default).
% 
% -- Inputs -- 
% 
% smps: samples x N1 x N2 ... array
% 
% -- Optional Arguments -- 
% 
% Optional arguments are specified as name-value pairs, e.g:
% normalized_correlation_v2(X, Y, 'NAME', 'VALUE', ...) 
% 
% null_value: N1 x N2 ... array, default: zeros(1, N1, N2, ...)
% 
% tail: 'left', 'right', or 'both' (default)
% 
%  -- Example --
% smps = randn(100e3,1)-norminv(0.01);
% est_p = sig_via_bootstrap_counts(smps, 'tail', 'right')
% analytic_p = -log10(0.01)
% est_p = sig_via_bootstrap_counts(smps, 'tail', 'both')
% analytic_p = -log10(0.02)
% 
% 2017-03-17: Created, Sam NH

dims = size(smps);
I.null_value = zeros([dims(2:end),1]);
I.tail = 'both';
I = parse_optInputs_keyvalue(varargin, I);

signed_log10p = sig_via_null_counts(I.null_value, -smps, 'tail', I.tail);