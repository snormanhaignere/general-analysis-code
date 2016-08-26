function selectivity = selectivity_measure(X, DIM)

% selectivity = selectivity_measure(X, DIM)
% 
% Very simple function for computing the standard A-B / A+B selectivity measure.
% The main reason for wrapping this in a function is to put in a couple of error
% checks and to make other code, which relies on this function, cleaner. The
% second optional argument is the dimension over which to compute selectivity.
% Default is the first dimension.
% 
% -- Example --
% A = [2 1; 4 2];
% A
% selectivity_measure(A,2)
% selectivity_measure(A,1)
% selectivity_measure(A)

if nargin < 2
    DIM = 1;
end

% check there are only two condition sets
if size(X,DIM) ~= 2
    error(...se
        ['Dimension %d should have size 2' ...
        '\nSelectivity only defined for pairs of values'], ...
        DIM);
end

% dimensionality of input
dimsX = [size(X),1];

% selectivity measure
% check denominator is positive
diff_score = reshape( -diff(X,[],DIM), dimsX([1:DIM-1,DIM+1:end]) );
sum_score = reshape( sum(X,DIM), dimsX([1:DIM-1,DIM+1:end]) );
if any(sum_score(:)) < 0
    error('Denominator of selectivity measure is negative');
end

% divide after
selectivity = diff_score ./ sum_score;