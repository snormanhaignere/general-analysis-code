% Simple toy data-set to test flda.m
% 
%  2019-08-07: Created, Sam NH

% parameters
ResetRandStream2(0);
clc; close all;
D = 10; % data dimensionality
L = 2; % dimensionality of classes
C = 5; % total number of classes
cn = 0.1; % spread of classes, smaller->tighter
dn = 0.1; % magnitude of data noise
sn = 2; % magnitude of structured noise, useful to distinguish from PCA
N = 300; % number of data points

% create the labels
labels = repmat(1:C,1,ceil(N/C));
labels = labels(1:N);

% sample class means
class_means = randn(L, C)+3;

% sample latent values given class means
latent_values = nan(L, N);
for i = 1:C
    xi = labels==i;
    latent_values(:, xi) = bsxfun(@plus, class_means(:,i), cn*randn(2, sum(xi)));
end

% transform to data space
A = randn(D,L); % generative matrix
X = A*latent_values + sn*randn(D,L)*randn(L,N) + dn*randn(D,N);

% solve
[Z,W,S,S_opt] = flda(X, labels, L, 'demean', true);
Z_opt = pinv(A) * X;
[~,~,V] = svd(X,'econ');

% plot results
figure;
cols = colormap(['jet(' num2str(C) ')']);
for j = 1:2
    subplot(1,4,1);
    hold on;
    for i = 1:N
        plot(latent_values(1,i), latent_values(2,i), 'o', 'Color', cols(labels(i),:))
    end
    title('True');
    subplot(1,4,2);
    hold on;
    for i = 1:N
        plot(Z(1,i), Z(2,i), 'o', 'Color', cols(labels(i),:))
    end
    title('FLDA');
    subplot(1,4,3);
    hold on;
    for i = 1:N
        plot(V(i,1), V(i,2), 'o', 'Color', cols(labels(i),:))
    end
    title('PCA');
    subplot(1,4,4);
    hold on;
    for i = 1:N
        plot(Z_opt(1,i), Z_opt(2,i), 'o', 'Color', cols(labels(i),:))
    end
    title('inv(A)');
end

