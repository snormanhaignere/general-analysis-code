function y = interpNaN(x,y,interp_type)

% Wrapper for interp1, interpolates NaN values in a vector using the surrounding
% values. Boundary points are set to the first non-NaN value to avoid wild
% extrapolation.
% 
% -- Inputs -- 
% 
% x: inputs values to function f
% 
% y: output values f(x)
% 
% interp_type: type of interpolation to use, e.g. linear, cubic
% 
% 2016-11-04: Commented, Sam NH

assert(isvector(x) && isvector(y) && all(size(x) == size(y)));

if all(isnan(y));
    warning('y is all NaN');
    return;
end

if nargin < 3
    interp_type = 'pchip';
end

% fix endpoints
y(1) = y( find(~isnan(y),1,'first') );
y(end) = y( find(~isnan(y),1,'last') );

% interpolate
y(isnan(y)) = interp1(x(~isnan(y)),  y(~isnan(y)),  x(isnan(y)), interp_type, 'extrap');