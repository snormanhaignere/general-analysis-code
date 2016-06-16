function sig = estimate_noise_from_repeated_measurements(X)
% function estimate_noise_from_repeated_measurements
% 
% Estimates the standard error of each voxel's response, using repeated measurements.
% X is a [M x N x R] matrix with M conditions, N voxels and R repeated measurements
% If a voxel only has R-X repeated measurements than it should have X columns with only NaN values.
% Every column should Zero NaNs or All NaNs.
% 
% The standard error is estimated by measuring the standard deviation of the difference between pairs of repeated measurements.
% 
% The data matrix used to infer response profiles, sparsity factors, and latent activations should equal the mean
% of all repeated measurements, e.g. nanmean(X,3).
% 
% Example with 100 features per voxel and 3 measurements per voxel
% X = 2*randn(100,1000,3); % zero mean noise with known standard deviation
% X(:,501:end,3) = NaN; % only 2 measurements for the last 3 voxels
% e_expected = [2/sqrt(3), 2/sqrt(2)] % expected standard error for 3 measurements and 2 measurements
% e_measured1 = estimate_noise_from_repeated_measurements(X); % estimated error
% [mean(e_measured1(1:500)),mean(e_measured1(501:1000))]
% e_measured2 = rms(nanmean(X,3)); % estimated error directly from rms of mean responses
% [mean(e_measured2(1:500)),mean(e_measured2(501:1000))]
% 
% Example with 1 feature per voxel and 20 measurements per voxel
% X = 2*randn(1,1000,20); % zero mean noise with known standard deviation
% X(:,501:end,11:20) = NaN; % half voxels have 10 measurements, other half have 20
% e_expected = [2/sqrt(20), 2/sqrt(10)] % expected standard error for 20 measurements and 10 measurements
% e_measured1 = estimate_noise_from_repeated_measurements(X); % estimated error
% [mean(e_measured1(1:500)),mean(e_measured1(501:1000))]
% e_measured2 = abs(nanmean(X,3)); % estimated error directly from rms of mean responses
% [rms(e_measured2(1:500)),rms(e_measured2(501:1000))]
% 
% Last modified by Sam Norman-Haignere on 1/6/2014

% dimensionality of the data
[M,N,R] = size(X);

% make sure there are at least two measurements per voxel
if R < 2
    error('Need at least two repeated measurements to measure a voxels''s error, but the size of the third dimension is less than 2.');
end

sig = nan(1,N);
for i = 1:N
    % columns to use for measuring error
    columns_without_NaNs = find(squeeze(~any(isnan(X(:,i,:)),1)));
    if length(columns_without_NaNs) < 2
        error('Need at least two repeated measurements to measure a voxels''s error.');
    end
    
    % number of repeated measurements for this voxel
    n_repeated_measurements = length(columns_without_NaNs);
    
    % all pairs of valid columns
    pairs = nchoosek(columns_without_NaNs,2);
    n_pairs = size(pairs,1);
    
    % estimated error for a single measurement based on all pairs of valid columns
    E = nan(M,n_pairs);
    for j = 1:n_pairs
        E(:,j) = X(:,i,pairs(j,1)) - X(:,i,pairs(j,2)); 
    end
    
    % error for the average of all measurements
    % sqrt(2) accounts for the fact that variances add
    % sqrt(n_repeated_measurements) accounts for standard error calculation
    sig(i) = rms(E(:))/(sqrt(2)*sqrt(n_repeated_measurements));
end