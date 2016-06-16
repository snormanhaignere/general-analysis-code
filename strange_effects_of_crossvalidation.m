% construct basis functions with decaying eigenvalues
N = 100;
T = 50;
[U,~,V] = svd(randn(N,T), 'econ');
S = diag(1./(1:min(N,T)));
% S = diag(ones(1,N));
X = U*S*V';

% create a signal that is a mixture of the first P principal components plus noise
P = 10;
b = randn(P,1);
sig = U(:,1:10) * b;
noise = sqrt(var(sig)/4) * randn(N,1);
data = sig + noise;

% first half for training
% second half for testing
train_inds = 1:N/2;
test_inds = N/2+1:N;

% predict responses using U
% predictions are poor
bh = pinv(U(train_inds,:)) * data(train_inds);
rU = corr(data(test_inds), U(test_inds,:) * bh)


% predict responses using X
% predictions are much better, why?
bh = pinv(X(train_inds,:)) * data(train_inds);
rX = corr(data(test_inds), X(test_inds,:) * bh)