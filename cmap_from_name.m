function cmap = cmap_from_name(cname)

% Reads in a N x 3 colormap matrix from a color map name
% 
% 2017-03-17: Created, Sam NH

% make sure auxilliary color maps are in path
addpath([fileparts(which(mfilename)) '/python-maps']);
addpath([fileparts(which(mfilename)) '/cmaps']);
addpath([fileparts(which(mfilename)) '/cbrewer']);
addpath([fileparts(which(mfilename)) '/pmkmp']);

% color map and range of values to plot
switch cname
    case 'lightblue-to-yellow1';
        load(['colormap-custom-' cname '.mat']);
    case {'parula', 'jet'}
        cmap = colormap(cname);
    case {'parula-inverted', 'jet-inverted'}
        cmap = colormap(strrep(cname, '-inverted', ''));
        cmap = flipud(cmap);
    case {'plasma'}
        cmap = plasma;
    case {'magma'}
        cmap = magma;
    case {'inferno'}
        cmap = inferno;
    case {'viridis'}
        cmap = viridis;
    otherwise
        error('No matching colormap');
end
