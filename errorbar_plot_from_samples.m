function [line_handles, M, E, EL, EU] = ...
    errorbar_plot_from_samples(Y, xvals, varargin)

% line_handles = errorbar_plot_from_samples(Y, xvals)
% 
% Plots the median and standard error of the columns of Y as a line with
% errorbars. Rows of Y reflect samples of the variables in each column. If the
% matrix has more than two dimensions, all of the columns from all dimensions
% are plotted as separate lines. The optional argument xvals specifies the
% value of the x-axis for each column.
% 
% Returns handles to each plotted line.
% 
% -- Example: Matrix input --
% 
% Y = randn(1000,10) + repmat((1:10), 1000, 1);
% xvals = 0.1:0.1:1;
% errorbar_plot_from_samples(Y, xvals);
% 
% -- Example: 3D array --
% 
% A = repmat((1:10), [1000, 1, 3]);
% B = repmat(reshape((1:3), [1,1,3]), [1000, 10, 1]);
% Y = randn([1000,10,3]) + A + B;
% xvals = 0.1:0.1:1;
% errorbar_plot_from_samples(Y, xvals);

if nargin < 2
    xvals = 1:size(Y,2);
end

% dimension of Y
dims = [size(Y),1];

% median across samples
M = median(Y,1);
M = reshape(M, dims(2:end));

% standard error across samples
E = stderr_from_samples(Y);

% separate out lower and upper error bounds for ease of plotting
EL = M - reshape(E(1,:,:), dims(2:end));
EU = reshape(E(2,:,:), dims(2:end)) - M;

% width of the errorbar ticks
% width = plot_width / tick_width
tick_width = 50;
if optInputs(varargin, 'tick-width');
    tick_width = varargin{optInputs(varargin, 'tick-width')+1};
end

load('colormap-default-line-colors.mat', 'cmap');

% plot
figure(gcf);
hold on;
line_handles = nan(dims(3:end));
for j = 1:prod(dims(3:end));
    indices = cell(1,length(dims(3:end)));
    [indices{:}] = ind2sub(dims(3:end), j);
    line_handles(indices{:}) = errorbar(...
        xvals(:), M(:,indices{:}), EL(:,indices{:}), EU(:,indices{:}), ...
        'LineWidth', 2, 'Color', cmap(mod(j-1,6)+1,:) );
    set(line_handles(indices{:}), 'Marker', 'none');
    errorbar_tick(line_handles(indices{:}), tick_width);
end
% xlim([min(xvals(:)), max(xvals(:))]);

% set the bounds
bounds = [min(M(:)-EL(:)), max(M(:)+EU(:))];
bounds(1) = bounds(1) - 0.1 * diff(bounds);
bounds(2) = bounds(2) + 0.1 * diff(bounds);
bounds(1) = min(bounds(1),0);
ylim(bounds);
xvals_sorted = sort(xvals, 'ascend');
xlim([xvals_sorted(1) - diff(xvals_sorted(1:2)), xvals_sorted(end) + diff(xvals_sorted(end-1:end))]);


