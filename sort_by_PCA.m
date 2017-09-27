function [Y,xi] = sort_by_PCA(X, direction, PC)

% Sorts columns of X by projection onto first principal component

if nargin < 2
    direction = 'descend';
end

if nargin < 3
    PC = 1;
end

% PCA via svd
[U,~,V] = svd(X, 'econ');

% select PC
U = U(:,PC);
V = V(:,PC);

% orient
if mean(U)<0
    U = -U; %#ok<NASGU>
    V = -V;
end

% order
[~,xi] = sort(V, direction);
Y = X(:,xi);