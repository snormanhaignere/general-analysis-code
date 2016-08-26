function [Xmatched, xi] = matrix_matching_via_corrmatrix(Xref,X,plot_figure,ignore_correlation_sign)
% function [Xmatched, xi] = matrix_matching_via_corrmatrix(Xref,X,plot_figure)
% 
% Matches corresponding column vectors between two matrices using the correlation matrix
% of the two matrices (e.g. corr(Xref, X)). The matching is performed by the subfunction "Hungarian.m".
% 
% There are two input matrices Xref and X of the same dimension. Xmatched is a version of the input matrix, X,
% whose columns have been reordered to best match the reference matrix Xref. The reordering vector is returned
% in the second argument, xi: Xmatched = X(:,xi);
% 
% If ignore_correlation_sign is set to true (default is false), then the absolute value of the
% correlation values is used to perform the matching.
% 
% Example:
% Xref = randn(100,5);
% X = Xref(:,[2 3 4 1 5]);
% plot_figure = 1;
% [Xmatched, xi] = matrix_matching_via_corrmatrix(Xref,X,plot_figure);
% 
% Created 2014-12-29 by Sam NH
% 
% Updated 2015-07-21 by Sam NH - Added option to take the absolute value of the correlation matrix

% plot figure by default
if nargin < 3
    plot_figure = 1;
end

% do not ignore sign of the correlation by default
if nargin < 3
    ignore_correlation_sign = 0;
end

% correlation matrix
r_original = corr(X,Xref);

% optionally take absolute value of matrix
if ignore_correlation_sign
    r_original = abs(r_original);
end

% matching with hungarian algorithm
matching = Hungarian(-r_original);

% best match
[~,xi] = max(matching);

% reordered input matrix
Xmatched = X(:,xi);

% correlation matrix for new ordering
r_matched = corr(Xmatched,Xref);

% optionally take absolute value of matrix
if ignore_correlation_sign
    r_matched = abs(r_matched);
end

% plot correlation matrices
if nargin > 2 && plot_figure
    figure;
    subplot(1,2,1);
    imagesc(r_original);
    xlabel('Columns of Xref'); ylabel('Columns of X');
    title('Original Correlation Matrix');
    subplot(1,2,2);
    imagesc(r_matched);
    xlabel('Columns of Xref'); ylabel('Columns of Xmatched');
    title('Correlation Matrix after Matching');
end

