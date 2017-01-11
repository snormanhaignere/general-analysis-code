function C = rankcorr(A,B,corresponding_columns)

% Computes spearman's rank correlation between all columns of A and B, or
% between all columns of A if B is absent. If corresponding_columns is true
% (default is false), then only corresponding columns of A and B are correlated
% (assumes) A and B have the same number of columns
% 
% 2016-12-21 - Created, Sam NH
% 
% 2016-01-05 - Optional argument that makes it possible to correlated
% corresponding columns of A and B for matrices of equal size, rather all
% possible pairs.

if nargin < 2
    B = A;
end

if nargin < 3
    corresponding_columns = false;
end

if corresponding_columns
    assert(size(A,2) == size(B,2));
    C = nan(1,size(A,2));
    for i = 1:size(A,2)
        C(i) = corr(ranks(A(:,i)), ranks(B(:,i)));
    end
else
    C = nan(size(A,2),size(B,2));
    for i = 1:size(A,2)
        for j = 1:size(B,2)
            C(i,j) = corr(ranks(A(:,i)), ranks(B(:,j)));
        end
    end
end

function Y = ranks(X)

[~,xi] = sort(X,'ascend');
Y = nan(size(X));
for i = 1:size(X,2)
    Y(xi(:,i),i) = 1:size(X,1);
end