function [pair_values, pair_counts, bounds, figh] = myscatter(X, varargin)

% Custom script for scatter plotting. One key difference is that if a pair
% of values is repeated this plot produces a larger marker indicating the
% repetition.
% 
% 2019-11-27: Created, Sam NH

% parameters
clear I;
I.quant = [0,1];
I.buf = 0.1;
I.bounds = [];
I.tick = [];
I.ticklabel = [];
I.slopes = 1;
I.intercepts = 0;
I.plot = true;
I.figh = matlab.ui.Figure.empty;
I.figdims = [];
[I,C] = parse_optInputs_keyvalue(varargin, I, 'empty_means_unspecified', true);
assert(length(I.slopes)==length(I.intercepts));

% number of data points
N = size(X,1);

% calculate all unique pairs
pair_values = X(1,:);
pair_counts = 1;
for i = 2:N
    matching_pair = pair_values(:,1)==X(i,1) & pair_values(:,2)==X(i,2);
    if any(matching_pair)
        assert(sum(matching_pair)==1);
        pair_counts(matching_pair) = pair_counts(matching_pair)+1; %#ok<AGROW>
    else
        pair_values = [pair_values; X(i,:)]; %#ok<AGROW>
        pair_counts = [pair_counts; 1]; %#ok<AGROW>
    end
end

% set bounds based on quantile or user-supplied inpu
if ~C.bounds
    bounds = quantile(X(:), I.quant);
    bounds = bounds + diff(bounds)*[-1,1]*I.buf;
else
    bounds = I.bounds;
end

if I.plot
    
    % open a figure or use an already opened handle
    if isempty(I.figh)
        figh = figure;
    else
        figh = I.figh;
    end
    clf(figh);
    if ~isempty(I.figdims)
        set(figh, 'Position', I.figdims);
    end
    hold on;
    
    % plot background lines
    for i = 1:length(I.slopes)
        plot(bounds, bounds*I.slopes(i) + I.intercepts(i), 'r--', 'LineWidth', 2); hold on;
    end
    
    % plot the pairs of values
    n_pairs = size(pair_values,1);
    for i = 1:n_pairs
        plot(pair_values(i,1), pair_values(i,2), 'k.', 'LineWidth', 2, 'MarkerSize', pair_counts(i).^(0.5)*30);
    end
    
    % axes, ticks
    xlim(bounds);
    ylim(bounds);
    if ~isempty(I.tick)
        if ~isempty(I.ticklabel)
            ticklabel = I.ticklabel;
        else
            ticklabel = I.tick;
        end
        set(gca, 'XTick', I.tick, 'XTickLabel', ticklabel);
        set(gca, 'YTick', I.tick, 'YTickLabel', ticklabel);
    end
end