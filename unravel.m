function Xu = unravel(X, dims)

% Unravels all (dims=[] or dims=1:ndims(X)) or specified dimensions of a
% matrix into a single dimension.
% 
% -- Example --
% 
% X = reshape(1:12, [3,2,2])
% unravel(X, [])
% unravel(X, 1:3)
% unravel(X, 1:2)
% unravel(X, 2:3)

if isempty(dims)
    dims = 1:ndims(X);
end

assert(all(diff(dims)==1));
d = size(X);
du = [d(1:dims(1)-1), prod(d(dims)), d(dims(end)+1:end), 1];
Xu = reshape(X, du);
