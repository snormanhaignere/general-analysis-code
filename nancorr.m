function C = nancorr(A,B)

% Wrapper for corr but excludes NaN values
%
% 2016-10-28: Created, Sam NH

if nargin < 2
    B = A;
end

if all(~isnan(A(:))) && all(~isnan(B(:)))
    C = corr(A,B);
    return;
end

C = nan(size(A,2),size(B,2));
for i = 1:size(A,2)
    for j = 1:size(B,2)
        xi = ~isnan(A(:,i)) & ~isnan(B(:,j));
        C(i,j) = corr(A(xi,i), B(xi,j));
    end
end