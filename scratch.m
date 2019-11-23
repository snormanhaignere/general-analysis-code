



%%

X = randn(100,1);
X_phasescram = phasescram(X);
figure;
subplot(1,2,1);
fftplot2(X,1);
subplot(1,2,2);
fftplot2(X_phasescram,1);



%%

clc;
N = 1000;
P = 10000;

X = randn(N,P);
Y = randn(N,P);

xi = randi(N*P, 10);
X(xi) = NaN;

% tic;
% r1 = fastcorr(X,Y);
% toc;


tic;
r3 = nanfastcorr2(X,Y);
toc;

tic;
r2 = nanfastcorr(X,Y);
toc;


% tic;
% for i = 1:1000
%     r2 = corr(X,Y);
% end
% toc;

%%

intper_sec = 0.1;
delay_sec = 0.1;
distr = 'gamma';
shape_param_for_gamma = 10; % [1, inf], lower -> more exponential, higher -> more gaussian
[h,t_sec,causal] = modelwin(distr, intper_sec, delay_sec, ...
    'plot', true, 'shape', shape_param_for_gamma, 'sr', 1000);

%%

% close all;
segdur_sec = 0.125;
distr = 'gamma';
intper_sec = 0.125;
delay_sec = 0.1;
shape = 1;
[h_relpower, t_sec, h, causal] = win_power_ratio(...
    segdur_sec, distr, intper_sec, delay_sec, ...
    'shape', shape, 'plot', true, 'centralinterval', 0.75, 'delaypoint', 'median');

%%
clc;
N = 1000;
s = randn(N,1);
w = rand(N,1)*5;
x = s + randn(N,1).*w;
y = s + randn(N,1).*w;
1-normalized_squared_error(x,y)
weighted_nse(x,y,ones(size(x)))
weighted_nse(x,y,1./w)


%%

x = randn(100,1);
y = randn(100,1);

mx = mean(x);
my = mean(y);

vx = var(x);
vy = var(y);

cxy = cov([x,y]);

r = cxy / sqrt(vx*vy)

corr(x,y)


%%
for cnt1 = [1 2 4 6 9]
    wav(round((cnt1-1)*(0.25*sr)+1+sr*.1:(cnt1-1)*(0.25*sr)+sr*0.2),2) = 1;
end


I.a = 'TCI';
I.b = [1,2,3];
I.c = {'hello','world'};
varargin = {'a', 'quilting', 'c', {'goodbye','world'}};
[I, ~, C_value] = parse_optInputs_keyvalue(varargin, I);
always_include = {'b'};
always_exclude = {'a'};
str = optInputs_to_string(I, C_value, always_include, always_exclude)


%%

clc;
for i = 1:10
    
    xi = find(M.si == i,1);
    fprintf('%s\n', M.all_subjid{i});
    sum(~isnan(X(:,:,xi)))
    
end

%%
% information about the onset of stimuli in each run
% NULL periods are removed
root_directory = my_root_directory;
exp = 'spectrotemporal-synthesis-ecog';
subjid = 'AMC056';
r = 1;
para_file = [root_directory '/' exp '/data/para/' subjid '/r' num2str(r) '.par'];
t = stim_timing_from_para(para_file);

x = t.dur_in_sec(t.ids==0)
x = x(x<5);
min(x)
max(x)


%%
clear S;
S.a = '1';
S.b = [2,3,4];
struct2string(S, 'maxlen', 2, 'delimiter', '/')




switch group_or_individ
    case 'group'
        
        load([root_directory '/spectrotemporal-synthesis-fMRI/analysis/tonotopy-centroids/all-centroids.mat'], ...
            'lowfreq_voxels_group_XY');
        
        % x and y position of low-frequency centroid
        mask_dims = lowfreq_voxels_group_XY(q,:); %#ok<NODEF>
        clear lowfreq_voxels_group_XY;
        
    case 'individ'
        
load([root_directory '/spectrotemporal-synthesis-fMRI/analysis/tonotopy-centroids/all-centroids.mat'], ...
    'lowfreq_voxels_individ_XY');

% select relevant voxel
xi = ...
    I.usubs(k) == lowfreq_voxels_individ_XY(:,1) & ...
    q == lowfreq_voxels_individ_XY(:,2); %#ok<NODEF>
assert(sum(xi)==1);
mask_dims = lowfreq_voxels_individ_XY(xi, 3:4);
clear xi lowfreq_voxels_individ_XY;
end

spatial_dims = size(G.grid_data{q});
distance_maps{k,q} = nan(spatial_dims);
for i = 1:spatial_dims(1)
    for j = 1:spatial_dims(2)
        if ~isnan(G.grid_data{q}(i,j))
            
            % distance to the nearest voxel in the mask
            X = bsxfun(@minus, [G.grid_x{q}(i,j), G.grid_y{q}(i,j)], mask_dims);
            distance_maps{k,q}(i,j) = min(sqrt(sum(X.^2,2)));
            
        end
    end
end