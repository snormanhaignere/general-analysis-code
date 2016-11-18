% Example with a perfectly correlated signal and independent noise.
% Normalized correlation should equal 1.
nd = 10000;
sig = randn(nd,1);
X = randn(nd,3) + sig*ones(1,3);
Y = randn(nd,4)*2 + sig*ones(1,4);
folds = ones(1000,1) * (1:10);
folds = folds(:);
Z = bootstrapped_normalized_correlation_within_folds(X,Y,folds,100);

