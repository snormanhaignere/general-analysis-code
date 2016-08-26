function X = index(X, dims, indices)

% Alternative function for indexing a matrix. Can be useful when the dimension
% your indexing over changes in a regular way. 
% 
% -- Example -- 
% 
% X = reshape(1:12,3,4)
% X(:,[2 3])
% index(X, 2, [2 3])
% X(1:2,2:3)
% index(X, [1 2], {1:2,2:3})
% 
% 2016-08-07: Created, Sam NH

if length(dims)>1
    assert(iscell(indices));
end

if length(dims) == 1 && ~iscell(indices)
    indices = {indices};
end

xi = cell(1,ndims(X));
for i = 1:ndims(X)
    xi{i} = 1:size(X,i);
end

for j = 1:length(dims)
    xi{dims(j)} = indices{j};
end

X = X(xi{:});