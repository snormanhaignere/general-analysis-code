function myimagesc(I, varargin)

% Wrapper around imagesc with defaults that better suit me
%
% 2019-10-11: Created, Sam NH

clear P;
P.percentile = 0.99;
P.cmap = 'cbrewer-blue-red';
P.colorbar = false;
P.notick = false;
P.bounds = [];
P = parse_optInputs_keyvalue(varargin,P);

% convert colormap string to color values
if ischar(P.cmap)
    P.cmap = cmap_from_name(P.cmap);
end
if isempty(P.bounds)
    bounds = quantile(I(:), 0.99)*[-1,1];
    if bounds(2)==0
        bounds = max(I(:))*[-1,1];
    end
else
    bounds = P.bounds;
end
imagesc(I, bounds);
colormap(P.cmap);
if P.notick
    set(gca, 'XTick', [], 'YTick', []);
end
if P.colorbar
    colorbar;
end
