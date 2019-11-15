function y = ceil_tol(x, varargin)

clear I;
I.tol = 1e-3;
I = parse_optInputs_keyvalue(varargin, I);

y = nan(size(x));
xi = (x - floor(x))<I.tol;
y(xi) = floor(x(xi));
y(~xi) = ceil(x(~xi));