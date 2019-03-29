function cmap = cmap_from_name(cname, varargin)

% Reads in a N x 3 colormap matrix from a color map name
% 
% 2017-03-17: Created, Sam NH
% 
% 2017-10-05: Generalized the color inversion functionality
% 
% -- Example --
% 
% figure;
% imagesc(linspace(0,1,100));
% colormap(cmap_from_name('lightblue-to-yellow1'));
% figure;
% imagesc(linspace(0,1,100));
% colormap(cmap_from_name('lightblue-to-yellow1-inverted'));

I.N = [];
I = parse_optInputs_keyvalue(varargin, I);

if strfind(cname, '-inverted')
    cname = strrep(cname, '-inverted', '');
    cmap = flipud(cmap_from_name(cname));
    return;
end

% make sure auxilliary color maps are in path
addpath([fileparts(which(mfilename)) '/python-maps']);
addpath([fileparts(which(mfilename)) '/cmaps']);
addpath([fileparts(which(mfilename)) '/cbrewer']);
addpath([fileparts(which(mfilename)) '/pmkmp']);

% color map and range of values to plot
custom_color_maps = {...
    'lightblue-to-yellow1', 'black-blue-v1', ...
    'black-green-v1', 'black-red-v1'};
switch cname
    case custom_color_maps
        load(['colormap-custom-' cname '.mat'], 'cmap');
    case {'parula', 'jet'}
        cmap = colormap(cname);
    case {'plasma'}
        cmap = plasma;
    case {'magma'}
        cmap = magma;
    case {'inferno'}
        cmap = inferno;
    case {'viridis'}
        cmap = viridis;
    case {'cbrewer-reds'}
        cmap = cbrewer('seq', 'Reds', 128);
    case {'cbrewer-red-blue'}
        cmap = cbrewer('div', 'RdBu', 128);
    case {'cbrewer-blue-red'}
        cmap = flipud(cbrewer('div', 'RdBu', 128));
    case {'line-colors'}
        load('colormap-default-line-colors.mat','cmap');
    case {'black-blue-v1'}
        load(['colormap-custom-' cname '.mat'], 'cmap');
    case {'black-red-v1'}
        load(['colormap-custom-' cname '.mat'], 'cmap');
    case {'cbrewer-seq-yellow-red'}
        cmap = cbrewer('seq', 'YlOrRd', 128, 'pchip');
    case {'cbrewer-seq-blues'}
        cmap = cbrewer('seq', 'Blues', 128, 'pchip');
    otherwise
        error('No matching colormap');
end

if ~isempty(I.N)
    cmap = interp1(1:size(cmap,1), cmap, linspace(1, size(cmap,1), I.N));
end
