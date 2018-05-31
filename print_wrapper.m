function print_wrapper(fname, varargin)

% Simple wrapper for the print function with intuitive defaults.

% 2018-05-04: Created Sam NH

I.figh = matlab.ui.Figure.empty;
I.dims = [];
I.margin = 0.25;
I.res = 100;
I = parse_optInputs_keyvalue(varargin, I);

% get current figure if not specified
if isempty(I.figh)
    I.figh = gcf;
end

% set dimensions
if isempty(I.dims)
    x = get(I.figh, 'Position');
    I.dims = x(3:4)/max(x(3:4)) * 8;
end

% turn off box (ugly!), set dimensions
box off;
set(I.figh, 'PaperSize', I.dims);
set(I.figh, 'PaperPosition', [I.margin, I.margin, I.dims(1)-I.margin, I.dims(2)-I.margin]);

% save
[~,~,ext] = fileparts(fname);
print(fname, ['-d' ext(2:end)], ['-r' num2str(I.res)]);