function [Y, degrees] = poly_regressors(N, order, varargin)

% Returns a set of polynomial vectors: Y(:,i) = x.^(i-1), x = zscore(1:N)
% 
% -- Inputs -- 
% 
% N: number of data-points, or optionally a vector specifying the x-values from
% which the polynomials are computed. 
% 
% order: the maximum degree of the polynomial, e.g. if order is 2 then
% polynomials of degree 0, 1, and 2 are computed
% 
% -- Outputs --
% 
% Y: the polynomial vectors
% 
% degrees: returns the degree of each polynomial vector, by default just 0:N
% (mainly useful for keeping track of polynomial degrees when they are split
% into negative and positive parts, see "split_neg_pos" below)
% 
% -- Optional Inputs --
% 
% All optional inputs are specified as key value pairs i.e.:
% poly_regressors(..., 'name-optional-input', value, ...)
% 
% orthogonalize: if true (default is false), applies gram-schmidt
% orthogonalization to the matrix Y, such polynomials of degree N are partialed
% out of the contribution of polynomials of degree N+1.
% 
% normalization: type of normalization to apply to polynomials of degree >0,
% options are 'none', 'zscore' (default), 'std' (divide by standard deviation but don't
% demean), 'max' (set max value of each regressor to 1). Note that if the
% regressors are normalized by their max value, this is done prior to any
% orthogonalization. 
% 
% split_neg_pos: splits up each polynomial function into two, one of which
% operates on x-values less than zero and one that operates on x-values greater
% than zero. The value argument to split_neg_pos should be a vector indicating
% all of the degrees of all of the polynomials that should be split. Note that
% if orthogonalization is applied the negative and positive versions of each
% polynomial are not orthogonalized with respect to each other.
% 
% -- Example: Degrees 0-3 -- 
% plot(poly_regressors(11, 3));
% 
% -- Example: Different types of normalization -- 
% plot(poly_regressors(11, 3, 'normalization', 'max'));
% plot(poly_regressors(11, 3, 'normalization', 'std'));
% 
% -- Example: Off center -- 
% plot(-3:10, poly_regressors(-3:10, 3));
% xlim([-3, 10]);
% 
% -- Example: Orthogonalization --
% X = poly_regressors(11, 3, 'orthogonalize', true);
% plot(X);
% X' * X
% 
% -- Example: Splitting up negative and positive -- 
% X = poly_regressors(11, 3, 'split_neg_pos', 2:3, 'normalization', 'max');
% X
% plot(X);
% 
% 2016-01-27: Created, Sam NH
% 
% 2017-03-08: Added bells and whistles (splitting up negative and
% positive parts, specifying x-values)

I.normalization = 'zscore';
I.split_neg_pos = [];
I.orthogonalize = false;
I = parse_optInputs_keyvalue(varargin, I);

% check there's at least one valid form of normalization
assert(any(strcmp(I.normalization, {'none', 'zscore', 'std' , 'max'})));

% x-values
if isscalar(N)
    xvals = zscore(1:N)';
else
    assert(isvector(N));
    xvals = N(:);
    N = length(xvals);
end

% polynomials, Y = xvals .^ degree
Y = nan(N, order+1);
degrees = 0:order;
for z = 1:length(degrees)
    Y(:,z) = xvals.^degrees(z);
end

% normalization by max
if strcmp(I.normalization, 'max')
    for z = 1:length(degrees)
        if degrees(z) > 0
            Y(:,z) = Y(:,z) / max(Y(:,z));
        end
    end
end

% % orthogonalize
% if I.orthogonalize
%     for z = 1:size(Y,2)-1
%         Y(:,z+1) = Y(:,z+1) - Y(:,1:z) * pinv(Y(:,1:z)) * Y(:,z+1);
%     end
% end

% split up negative and positive parts
if ~isempty(I.split_neg_pos)
    assert(isempty(setdiff(I.split_neg_pos, degrees)));
    Y_new = zeros(N, order + 1 + length(I.split_neg_pos));
    count = 0;
    degrees_new = nan(1, size(Y_new,2));
    for i = 1:order+1
        if any(i-1 == I.split_neg_pos)
            count = count+1;
            Y_new(xvals > 0,count) = 0;
            Y_new(xvals < 0,count) = Y(xvals<0,i);
            degrees_new(count) = degrees(i);
            
            count = count+1;
            Y_new(xvals < 0,count) = 0;
            Y_new(xvals > 0,count) = Y(xvals > 0, i);
            degrees_new(count) = degrees(i);
        else
            count = count+1;
            Y_new(:,count) = Y(:,i);
            degrees_new(count) = degrees(i);
        end
    end
    Y = Y_new;
    degrees = degrees_new;
end

% orthogonalize
if I.orthogonalize
    for z = 1:size(Y,2)-1
        Y(:,z+1) = Y(:,z+1) - Y(:,1:z) * pinv(Y(:,1:z)) * Y(:,z+1);
    end
end

% % orthogonalize
% if I.orthogonalize
%     for z = 1:max(degrees)
%         xi1 = degrees == z;
%         xi2 = degrees < z;
%         Y(:,xi1) = Y(:,xi1) - Y(:,xi2) * pinv(Y(:,xi2)) * Y(:,xi1);
%     end
% end

% divide by standard deviation
if strcmp(I.normalization, 'std')
    Y(:,2:end) = bsxfun(@times, Y(:,2:end), 1./std(Y(:,2:end)));
end

% zscore
if strcmp(I.normalization, 'zscore')
    Y(:,2:end) = zscore(Y(:,2:end));
end



% % orthogonalize
% if I.orthogonalize
%     for z = 1:size(X,2)-1
%         xi = nonzero_entries(:,z+1);
%         X(xi,z+1) = X(xi,z+1) - X(xi,1:z) * pinv(X(xi,1:z)) * X(xi,z+1);
%     end
% end








% if nargin >= 3 && orthogonalize
%     for z = 1:order
%         X(:,z+1) = X(:,z+1) - X(:,1:z) * pinv(X(:,1:z)) * X(:,z+1);
%     end
% end

% whether or not to normalize the regressors
% if nargin < 4 || normalize
%     X(:,2:end) = zscore(X(:,2:end));
% end
