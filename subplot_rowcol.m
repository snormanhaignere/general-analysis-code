function subplot_rowcol(n_rows, n_cols, row, col, varargin)

I.tight = false;
I.margins = [0.01,0.01];
I = parse_optInputs_keyvalue(varargin, I);

if I.tight
    subplot_tight(n_rows, n_cols, col + (row-1)*n_cols, I.margins);
else
    subplot(n_rows, n_cols, col + (row-1)*n_cols);
end