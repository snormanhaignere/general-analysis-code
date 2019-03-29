function selectivity = selectivity_measure(X, DIM, NEG_DENOM_BEHAV, ABS, RECT)

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

% 2018-05-04: Fixed how negative denominators are handled: added
% functionality (optionally return NaNs instead of always throwing an
% error). Fixed a bug: any(sum_score(:)) < 0 should have been
% any(sum_score(:) < 0)

if nargin < 2 || isempty(DIM)
    DIM = 1;
end

if nargin < 3 || isempty(NEG_DENOM_BEHAV)
    NEG_DENOM_BEHAV = 'error';
end

if nargin < 4 || isempty(ABS)
    ABS = false;
end

if nargin < 5 || isempty(RECT)
    RECT = false;
end

% check there are only two condition sets
if size(X,DIM) ~= 2
    error(...
        ['Dimension %d should have size 2' ...
        '\nSelectivity only defined for pairs of values'], ...
        DIM);
end

% dimensionality of input
dimsX = [size(X),1];

if RECT
    X = max(X, 0);
end

% selectivity measure
% check denominator is positive
diff_score = reshape( -diff(X,[],DIM), dimsX([1:DIM-1,DIM+1:end]) );
if ABS
    error('Absolute value denominator seems dicey');
    sum_score = reshape( sum(abs(X),DIM), dimsX([1:DIM-1,DIM+1:end]) );
else
    sum_score = reshape( sum(X,DIM), dimsX([1:DIM-1,DIM+1:end]) );
end

if any(sum_score(:) < 0)
    switch NEG_DENOM_BEHAV
        case 'error'
            error('Denominator of selectivity measure is negative');
        case 'NaN'
            xi = sum_score < 0;
            sum_score(xi) = NaN;
            diff_score(xi) = NaN;
        otherwise
            error('Switch fell through');
    end
end

% divide after
selectivity = diff_score ./ sum_score;