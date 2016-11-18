function c = nanfastcorr(A,B)

% Wrapper for fastcorr but excludes NaN values
% 
% 2016-10-28: Created, Sam NH

assert(all(size(A) == size(B)));
c = nan(1,size(A,2));
for i = 1:size(A,2)
    xi = ~isnan(A(:,i)) & ~isnan(B(:,i));
    c(i) = fastcorr(A(xi,i), B(xi,i));
end