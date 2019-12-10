function h = grouped_barplot_witherr(D, E, varargin)

% Created grouped bar plots with errorbars, the built-in function bar can
% create grouped bar plots if you give it multiple columns, but there is no
% corresponding errorbar script.
% 
% D: number of groups x number of bars per group matrix
% 
% E: errors, either a matrix of the same size as D or a matrix with the
% same size and an extra dimension appended to the front (first dimension)
% with two element specifying the upper and lower errorbar in absolute
% terms
% 
% 2019-12-09: Created, Sam NH

%% Default / optional parameters

ngroups = size(D, 1);
nbars_per_group = size(D, 2);

%% Setup

if ismatrix(E)
    eU = E;
    eL = E;
elseif ndims(E)==3 && size(E,1)==1
    eU = squeeze_dims(D,1);
    eL = squeeze_dims(D,1);
elseif ndims(E)==3 && size(E,1)==2
    eU = squeeze_dims(E(2,:,:),1) - D;
    eL = D - squeeze_dims(E(1,:,:),1);
else
    error('E is not formatted propertly')
end

%% Plot

% plot bars
figure;
h = bar(1:ngroups, D);
hold on;

% error bars
groupwidth = min(0.8, nbars_per_group/(nbars_per_group + 1.5));
for i = 1:nbars_per_group
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars_per_group);
    errorbar(x, D(:,i), eL(:,i), eU(:,i), 'k.', 'LineWidth', 2);
end
hold off