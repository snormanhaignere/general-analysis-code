function [normalized_r, normalized_r2, rx, ry, rxy] = normalized_correlation(X,Y,varargin)
% Computes the correlation between two random variables normalized by the reliability of the two variables. 
% The normalized correlation is equal to corr(x,y) / sqrt(corr(x,x) * corr(y,y));
% 
% X and Y are [M x N1] and [M x N2] matrices with the same number of rows. Each column is assumed to be an i.i.d. sample of the random variable. 
% The correlation between column vectors of the same matrix is used as a measure of the reliability of each random variable. 
% 
% Assumes that the test-retest correlation of each variable is greater than 0. An error is thrown if the average test-retest correlation is below 0.
% 
% Example with a perfectly correlated signal and independent noise.
% Normalized correlation should equal 1.
% nd = 10000;
% sig = randn(nd,1);
% X = randn(nd,3) + sig*ones(1,3);
% Y = randn(nd,4)*2 + sig*ones(1,4);
% normalized_correlation(X,Y)
% 
% 2014-12-26: Created by Sam Norman-Haignere
% 
% 2016-03-04: The original function calculated standard errors based on a parametric Gaussian
% approximation, and these errors were returned as the third and fourth argument of the function.
% This approximation only applies to raw not noise-corrected values, and thus I removed these
% additional outputs.
% 
% 2016-10-28: corr to nancorr to allow for NaN inputs

I.z_average = true;
I.warning = true;
I = parse_optInputs_keyvalue(varargin, I);

% dimensions of input matrices
nx = size(X,2);
ny = size(Y,2);

% test-retest correlation
if ny > 1
    ry = nancorr(Y);
    if I.z_average
        ry = tanh(mean(atanh(ry(~eye(ny))))); % z-average off-diagonal elements
    else
        ry = mean(ry(~eye(ny))); % z-average off-diagonal elements
    end
else
    ry = 1;
end

if nx > 1
    rx = nancorr(X);
    if I.z_average
        rx = tanh(mean(atanh(rx(~eye(nx))))); % z-average off-diagonal elements
    else
        rx = mean(rx(~eye(nx))); % z-average off-diagonal elements
    end
else
    rx = 1;
end

% correlation between measures
rxy = nancorr(X,Y);
if I.z_average
    rxy = tanh(mean(atanh(rxy(:)))); % z-average all pairs
else
    rxy = mean(rxy(:)); % z-average all pairs
end

if rx <= 0 || ry <=0
    if I.warning
        warning('Average test-retest r < 0');
    end
    normalized_r = NaN;
    normalized_r2 = NaN;
    return;
end


% normalized correlation
normalized_r = rxy / sqrt(rx*ry);
normalized_r2 = sign(normalized_r) .* normalized_r.^2;