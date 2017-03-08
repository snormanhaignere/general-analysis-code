function Y_detrended = detrend_poly(Y, order, varargin)

% Detrend data with a polynomial of chosen order. 
% order 0 -> mean, 1 -> mean + linear trend, 2 => mean + linear + quadratic etc.
% 
% -- Example --
% X = poly_regressors(100,2);
% trend = X*[1 1 1]';
% signal = randn(100,1)*0.3;
% Y = trend + signal;
% Y_detrend = detrend_poly(Y, 2);
% plot([trend, Y, Y_detrend]); 
% legend('Trend', 'Trend + Signal', 'Detrended Signal');

I.restore_mean = false;
I = parse_optInputs_keyvalue(varargin, I);

X = poly_regressors(size(Y,1), order);
Y_detrended = Y - X * (pinv(X) * Y);

if I.restore_mean
    Y_detrended = bsxfun(@plus, Y_detrended, mean(Y));
end