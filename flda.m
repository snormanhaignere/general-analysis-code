function [Z,W] = flda(X, labels, L, varargin)

% Implement Fisher's linear discriminant analysis as described in Murphy,
% 2006. 
% 
% X: data matrix, feature x sample
% 
% labels: list of integers specifying the label for each sample
% 
% L: desired dimensionality
% 
% see test_flda.m
% 
% 2019-08-07: Created, Sam NH

I.K = NaN;
I = parse_optInputs_keyvalue(varargin, I);

% reduce dimensionality
if ~isnan(I.K)
    X_orig = X;
    [Upca,~,~] = svd(X_orig, 'econ');
    Upca = Upca(:,1:I.K);
    X = Upca'*X_orig;
end

% data dimensionality
[D, N] = size(X);

% format labels
% determine numbef classes
[~,~,labels] = unique(labels);
C = max(labels);

% data mean
M = mean(X,2);

% class means
Mc = nan(D, C);
Nc = nan(1, C);
for i = 1:C
    xi = labels==i;
    Mc(:,i) = mean(X(:,xi),2);
    Nc(i) = sum(xi);
    clear xi;
end

% calculate between-class distance
Sb = zeros(D,D);
for i = 1:C
    Sb = Sb + (Nc(i)/N) * (Mc-M) * (Mc-M)';
end

% calculate within-class variance
Sw = zeros(D,D);
for i = 1:N
    Sw = Sw + (1/N) * (X(:,i) - Mc(:,labels(i)))*(X(:,i) - Mc(:,labels(i)))';
end

% solve eigen value problem
sqInvSw = sqrtm(inv(Sw));
[U,eigvals] = eig(sqInvSw*Sb*sqInvSw);
U = real(U);
eigvals = diag(real(eigvals));
[~,xi] = sort(eigvals,'descend');
U = U(:,xi);
eigvals = eigvals(xi); %#ok<NASGU>
clear xi;

if ~isnan(I.K)
    % projection matrix
    W = Upca*sqInvSw*U(:,1:L);
    
    % apply projection
    Z = W' * X_orig;
else
    % projection matrix
    W = sqInvSw*U(:,1:L);
    
    % apply projection
    Z = W' * X;
end