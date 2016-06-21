

N = 1e3;
sample_size = 10;
P = 5;
X = randn(N, P) + ones(N,1)*randn(1,P)*2;
anova_from_bootstrap_1way(X, median(var(X,[],2)))