function [F, subsamp_factor] = subsample_feature_matrix(F, max_average_corr)

% Subsamples feature matrix F so as to reduce the correlation between adjacent
% features. Returns a new subsampled F matrix, and a factor by which the matrix
% the matrices were sampled. The output matrix is equal to
% F(:,1:subsamp_factor:end). The matrix is iteratively subsampled by factors of
% 2 until the average correlation between adjacent features is less than
% "max_average_corr".

subsamp_factor = 1;
mean_adjacent_corr = mean(elem_just_below_diag(corr(F)));
while mean_adjacent_corr > max_average_corr
    F = transpose(resample(transpose(F), 1, 2));
    mean_adjacent_corr = mean(elem_just_below_diag(corr(F)));
    subsamp_factor = subsamp_factor * 2;
end