

%%

X = rand(10,4);
K = 4;

% [N,~] = size(X);
% 
% % calculate and remove mean
% mu = nanmean(X,1);
% Xd = bsxfun(@minus, X, mu);

% perform ppca analysis
opt = statset('ppca');
[Vp,USp] = ppca(X,K,'Options',opt);


%%
% incorporate mean
% recon USp_ones * Vp_mean'
% USp_ones = [ones(N,1), USp];
% Vp_mean = [mu', Vp];

USp_ones = [ones(N,1)];
Vp_mean = [mu'];


USp_ones * Vp_mean'
mean(X)


%%
intper_sec = 1;
delay_sec_start = 0;
shape = 2;
delaypoint = 'median';
converted_intper_sec = modelwin_convert_intper(intper_sec, shape, 0.75, 0.9)

% % plot delay point
% [h, t] = modelwin('gamma', intper_sec, delay_sec_start, 'shape', shape, 'delaypoint', 'start');
% plot(t, h, 'LineWidth', 2);
% hold on;
% [h, t] = modelwin('gamma', converted_intper_sec, delay_sec_start, 'shape', shape, 'delaypoint', 'start');
% plot(t, h, 'LineWidth', 2);

%%

% stats for h
mu_h = mean(h);
hd = h - mu_h;
s_h = sqrt(sum(hd.^2));
hn = h/s_h;

n_valid = N-M+1;
r_xy = nan(n_valid, 1);
r_pearson_true = nan(n_valid, 1);
r_pearson_attempt = nan(n_valid, 1);
mean_x = nan(n_valid, 1);
std_x = nan(n_valid, 1);
for i = 1:n_valid
    xw = x((1:M)+i-1);
    r_xy(i) = sum(xw .* h);
    r_pearson_true(i) = corr(xw, h);
    
    mean_x(i) = mean(xw);
    xd = xw - mean_x(i);
    std_x(i) = sqrt(sum(xd.^2,1));
    
    xn = xd / std_x(i);
    
    r_pearson_attempt(i) = sum(xn .* hn);
end

% r_pearson_attempt

%%

ResetRandStream2(1)

N = 100;
x = randn(N,1);
M = 10;
h = randn(M,1);


% stats for h
mu_h = mean(h);
hd = h - mu_h;
s_h = sqrt(sum(hd.^2));
hn = h/s_h;

n_valid = N-M+1;
r_xy = nan(n_valid, 1);
r_pearson_true = nan(n_valid, 1);
r_pearson_attempt = nan(n_valid, 1);
mean_x = nan(n_valid, 1);
std_x = nan(n_valid, 1);
for i = 1:n_valid
    xw = x((1:M)+i-1);
    r_xy(i) = sum(xw .* h);
    r_pearson_true(i) = corr(xw, h);
    
    mean_x(i) = mean(xw);
    xd = xw - mean_x(i);
    std_x(i) = sqrt(sum(xd.^2,1));
    
    xn = xd / std_x(i);
    
    r_pearson_attempt(i) = sum(xn .* hn);
end

%% Calculate mean of signal

% means
mu_x = xcorr_valid(x, ones(size(h))/length(h));
mu_h = mean(h);

% power
p_x = xcorr_valid(x.^2, ones(size(h))/length(h));
p_h = mean(h.^2);

% un-normalized standard deviation
s_x = sqrt(M*p_x - M*mu_x.^2);
s_h = sqrt(M*p_h - M*mu_h.^2);

% cross product
r_xh = xcorr_valid(x, h);

r_pearson_attempt2 = (1/s_h) * (1./s_x) .* (r_xh - M*mu_x*mu_h);

plot([r_pearson_true, r_pearson_attempt2])





%%





%%

cc = xcorr_valid(x, h);




%%

X = ones(2,3,4);
X(2,1,3) = 0;
[minX, ind, sub] = myminall(X);
minX
X(ind)
X(sub{:})

%%

q = 2;
p = 3;
s = 4;
figure;
subplot(3,1,1);
bounds = [MinAll(M.splits_loss(:,:,1,q,p,4)), MaxAll(M.splits_loss(:,:,1,q,p,s))]*1e4;
imagesc(M.splits_loss(:,:,1,q,p,4)*1e4, bounds);
colorbar;

subplot(3,1,2);
imagesc(M.splits_null_loss(:,:,1,q,p,s,1)*1e4, bounds);
colorbar;

subplot(3,1,3);
imagesc(M.splits_null_loss(:,:,1,q,p,s,2)*1e4, bounds);
colorbar;



%%
l = 1;
d = M.splits_diff_context(:,l,2,2,1);
p = M.splits_diff_context_bestpred(:,l,2,2,1);
dn = squeeze(M.splits_null_diff_context(:,l,2,2,1,1:5));
figure;
plot(L.lag_t, dn)
hold on;
plot(L.lag_t, d, 'k-', 'LineWidth', 3)
plot(L.lag_t, p, 'r-', 'LineWidth', 3)



%% Cross-context correlation

root_directory = '/Users/svnh2/Desktop/projects';
addpath([root_directory '/general-analysis-code']);
addpath([root_directory '/export_fig_v3']);
directory_to_save_results = [TCI_directory '/results-bstrap'];
L = cross_context_corr(D, t, S, 'chnames', chnames, ...
    'output_directory', directory_to_save_results, 'boundary', 'none', ...
    'nbstraps', 10, 'bstraptype', 'segs');

%%

Ln = L;
X = L.same_context(:,:,:,2:11);
Ln.same_context_err = mean(bsxfun(@minus, X, mean(X,4)).^2,4);
Ln.same_context = L.same_context(:,:,:,1);
Ln.diff_context = L.diff_context(:,:,:,1);
Ln.n_total_segs = Ln.n_total_segs(:,1);


%%

%% Model-fitting

M = modelfit_cross_context_corr(Ln, 'overwrite', true, ...
    'shape', 1, 'lossfn', 'unbiased-sqerr');

%%


hist(squeeze(L.same_context(5,1,1,2:11)));




%%

clc;
N = 1000;
s = randn(N,1);
w = rand(N,1)*5;
x = s + randn(N,1).*w;
y = s + randn(N,1).*w;
invW = 1./w;
1-normalized_squared_error(x,y)
weighted_nse(x,y,ones(size(x))/N)
weighted_nse(x,y,invW/sum(invW))


%%
intper_sec = 1;
delay_sec_start = [1,2,3];
shape = 1;
delaypoint = 'median';
converted_delay_sec = modelwin_convert_delay(intper_sec, delay_sec_start, shape, delaypoint)

figh = figure;
hold on;
for l = 1:length(delay_sec_start)
    % show delay point
    [h, t] = modelwin('gamma', intper_sec, delay_sec_start(l), 'shape', shape, 'delaypoint', 'start');
    plot(t, h, 'LineWidth', 2);
    yL = ylim;
    lineh = plot([1,1]*converted_delay_sec(l), yL, 'r--', 'LineWidth', 2);
    legend(lineh, delaypoint);
end

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
delay_sec_start = 0.1;
distr = 'gamma';
shape_param_for_gamma = 10; % [1, inf], lower -> more exponential, higher -> more gaussian
[h,t_sec,causal] = modelwin(distr, intper_sec, delay_sec_start, ...
    'plot', true, 'shape', shape_param_for_gamma, 'sr', 1000);

%%

% close all;
tic;
segdur_sec = 0.01;
distr = 'gamma';
intper_sec = 0.01;
delay_sec_start = 0.1;
shape = 1;
[h_relpower, t_sec, h, causal] = win_power_ratio(...
    segdur_sec, distr, intper_sec, delay_sec_start, ...
    'shape', shape, 'plot', true, 'centralinterval', 0.75, ...
    'delaypoint', 'median');
toc;

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