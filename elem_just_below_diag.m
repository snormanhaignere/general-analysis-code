function y = elem_just_below_diag(X)

% function y = elem_just_below_diag(X)
% 
% Returns the elements of a matrix just below
% the diagonal. 
% 
% -- Example --
% 
% X = rand(4)
% elem_just_below_diag(X)

[M,N] = size(X);
subscripts = {2:M,1:N-1};
y = X(sub2ind([M,N], subscripts{:}));