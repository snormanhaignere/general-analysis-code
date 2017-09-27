function r = normalized_squared_error(X, Y)

a = mean(X.^2) + mean(Y.^2) - 2 * mean(X.*Y);
b = mean(X.^2) + mean(Y.^2) - 2 * mean(X) .* mean(Y);
r = 1 - a./b;