function Y = interpNaN_ndarray(x,Y,interp_type,DIM)

% Wrapper for interpNaN that allows this function to work on an arbitrary
% dimension of an N-dimensional array. See interpNaN for details.
% 
% 2016-11-04: Created, Sam NH

if nargin < 3
    interp_type = 'pchip';
end

if nargin < 4
    DIM = 1;
end

% ensure x is a column vector
assert(isvector(x))
x = x(:);

% ensure x and Y are matched in size
assert(length(x) == size(Y,DIM));

% move desired dimention to the first dimension
if DIM ~= 1
    permute_order = [DIM, setdiff(1:ndims(Y), DIM)];
    Y = permute(Y, permute_order);
end

% unwrap to row by column matrix
dims = size(Y);
Y = reshape(Y, dims(1), prod(dims(2:end)));

% interpolate NaNs for each columne
for i = 1:size(Y,2)
    if ~all(isnan(Y(:,i)))
        Y(:,i) = interpNaN(x, Y(:,i), interp_type);
    end
end

% rewrap the higher-order dimensions
Y = reshape(Y, dims);

% move interpolated dimension back to its original position
if DIM ~= 1    
    Y = ipermute(Y, permute_order);
end
