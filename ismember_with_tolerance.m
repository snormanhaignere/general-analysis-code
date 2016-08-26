function z = ismember_with_tolerance(x, y, tol)

if nargin < 3
    tol = 1e-10;
end

z = false(size(x));

for i = 1:length(x)
    z(i) = any(abs(x(i) - y) < tol);
end