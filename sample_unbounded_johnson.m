function smps = sample_unbounded_johnson(msab, dims)
% function smps = sample_unbounded_johnson(msab, dims)
% 
% Samples from the Unbounded Johnson Distribution with parameter vector
% msab. Generates a matrix of samples with dimensionality given by the
% second input argument (dims).
% 
% See log_unbounded_johnson for details.
% 
% Last modified by Sam Norman-Haignere on 4/2/2015

mu = msab(1);
sig = msab(2);
a = msab(3);
b = msab(4);

z = (randn(dims) + a)/b;
smps = b*sig*sinh(z) + mu;