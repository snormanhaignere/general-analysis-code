function cmap = cmap_from_name(cname)

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
switch cname
    case 'lightblue-to-yellow1';
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
    case {'cbrewer-Reds'}
        cmap = cbrewer('seq', 'Reds', 128);
    otherwise
        error('No matching colormap');
end
