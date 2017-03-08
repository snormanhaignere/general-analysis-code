function [U, s, V, mF, normF] = svd_for_regression(...
    F, std_feats, demean_feats, groups)

% Helper function for other regression scripts (see ridge_via_svd_wrapper.m and
% regress_weights_from_2way_crossval.m). Demeans and optionally z-scores the
% feature matrix, and then calculates the SVD.
%
% 2016-01-10 - Made it possible to NOT demean the features and data

if nargin < 4
    groups = 1:size(F,2);
end

assert(all(~isnan(F(:))));

% optionally remove mean and standard deviation
if demean_feats
    mF = mean(F);
else
    mF = zeros(1,size(F,2));
end
F_formatted = bsxfun(@minus, F, mF);

if std_feats
    normF = std(F);
else
    normF = ones(1,size(F,2));
end
normF(normF==0) = 1;
F_formatted = bsxfun(@times, F_formatted, 1./normF);

% fix overall variance, done separately for each group
n_groups = max(groups);
if n_groups > 1
    total_norm = norm(F_formatted(:));
    desired_group_norm = total_norm / sqrt(n_groups);
    clear total_norm;
    for i = 1:n_groups
        xi = groups==i;
        X = F_formatted(:,xi);
        group_norm = norm(X(:));
        F_formatted(:,xi) = F_formatted(:,xi) * desired_group_norm / group_norm;
        normF(xi) = normF(xi) * group_norm / desired_group_norm;
        clear xi group_norm;
    end
    clear desired_group_norm;
end

try
    [U,S,V] = svd(F_formatted, 'econ');
    s = diag(S);
    clear S F_formatted;
catch ME
    print_error_message(ME);
    keyboard
end