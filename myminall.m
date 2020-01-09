function [minX, ind, sub] = myminall(X)

% -- Example --
% X = ones(2,3,4);
% X(2,1,3) = 0;
% [minX, ind, sub] = myminall(X);
% minX
% X(ind)
% X(sub{:})

[minX,ind] = min(X(:));
sub = cell(1, ndims(X));
[sub{:}] = ind2sub(size(X), ind);