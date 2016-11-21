function [F, subsamp_factor] = subsample_feature_array(F, DIM, max_average_corr)

% Subsamples feature array F so as to reduce the correlation between adjacent
% features along specified dimension. Returns a new subsampled F array, and a
% factor by which the matrix the matrices were sampled. The matrix is
% iteratively subsampled by factors of 2 until the average correlation between
% adjacent features is less than "max_average_corr".
% 
% 2016-11-18: Created, Sam NH

% dimensions of F
dims = size(F);

% average correlation between adjacent elements for given dimension
r = fastcorr(...
    index(F, DIM, 1:dims(DIM)-1), index(F, DIM, 2:dims(DIM)));
mean_adjacent_corr = mean(r(:));

% subsample
subsamp_factor = 1;
while mean_adjacent_corr > max_average_corr
    
    % subsample by factor of 2
    F = index(F, DIM, 1:2:dims(DIM));
    subsamp_factor = subsamp_factor * 2;
    dims(DIM) = size(F, DIM);
    
    % recompute average correlation between adjacent elements
    r = fastcorr(...
        index(F, DIM, 1:dims(DIM)-1), index(F, DIM, 2:dims(DIM)));
    mean_adjacent_corr = mean(r(:));

end


