function C = rankcorr(A,B)

% Computes spearman's rank correlation between all columns of A and B, or
% between all columns of A if B is absent.
% 
% 2016-12-21 - Created, Sam NH

if nargin < 2
    B = A;
end

C = nan(size(A,2),size(B,2));
for i = 1:size(A,2)
    for j = 1:size(B,2)
        C(i,j) = corr(ranks(A(:,i)), ranks(B(:,j)));
    end
end

function Y = ranks(X)

[~,xi] = sort(X,'ascend');
Y = nan(size(X));
for i = 1:size(X,2)
    Y(xi(:,i),i) = 1:size(X,1);
end