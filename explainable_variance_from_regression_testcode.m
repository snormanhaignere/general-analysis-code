N = 100;
P = 10;

% create a signal that is a linear function of a set of features with some
% additional un-predictable variance
[U,S,V] = svd(randn(N,N ), 'econ');
S = diag(1./(1:N));
X = U*S*V';

b = randn(P,1);
predicted = U(:,1:P) * b;
non_predicted = sqrt(var(predicted)/4) * randn(N,1);
signal = predicted + non_predicted;

% measure the true variance explained
true_r = corr(predicted, signal);
true_r2 = sign(true_r) .* true_r.^2

%%

% construct basis functions with decaying eigenvalues
N = 100;
[U,~,V] = svd(randn(N,N), 'econ');
S = diag(1./(1:N));
X = U*S*V';

% create a signal that is a mixture of the first P components plus noise
P = 10;
b = randn(P,1);
sig = U(:,1:P) * b;
noise = sqrt(var(sig)/4) * randn(N,1);
data = sig + noise;

% first half for training
% second half for testing
train_inds = 1:N/2;
test_inds = N/2+1:N;

V*S*U'

% predict responses using U
bh = pinv(U(train_inds,:)) * data(train_inds);
rU = corr(data(test_inds), U(test_inds,:) * bh)

% predict responses using X
bh = pinv(X(train_inds,:)) * data(train_inds);
rX = corr(data(test_inds), X(test_inds,:) * bh)

%%

b = randn(P,1);
predicted = U(:,1:P) * b;
non_predicted = sqrt(var(predicted)/4) * randn(N,1);
signal = predicted + non_predicted;

% measure the true variance explained
true_r = corr(predicted, signal);
true_r2 = sign(true_r) .* true_r.^2

%%

n_folds = 10;
method = 'ridge';
K = 2.^(-30:30);
% Yh = regress_weights_from_2way_crossval([X, randn(N,10)], signal, n_folds, 'ridge');
% corr(bh(2:end), b)
% Yh = regress_predictions_from_3way_crossval(U, signal, n_folds, 'least-squares');
Yh = U * pinv(U(51:end)) * signal;

est1_r = corr(Yh, signal);
est1_r2 = sign(est1_r) .* est1_r.^2

%%
% estimate true variance explained with regression
n_folds = 10;
method = 'ridge';
K = 2.^(-30:30);
% Yh = regress_weights_from_2way_crossval([X, randn(N,10)], signal, n_folds, 'ridge');
% corr(bh(2:end), b)
Yh = regress_predictions_from_3way_crossval([X, 0.01*randn(N,100)], signal, n_folds, 'least-squares');

est1_r = corr(Yh, signal);
est1_r2 = sign(est1_r) .* est1_r.^2

%%
% corrupt signal with noise
noise = 0.5 * sqrt(P) * randn(N,1);
signal_plus_noise = signal + noise;

% estimate