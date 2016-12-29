function [U, s, V, mF, normF] = svd_for_regression(F, std_feats, groups)

% Helper function for other regression scripts (see ridge_via_svd_wrapper.m and
% regress_weights_from_2way_crossval.m). Demeans and optionally z-scores the
% feature matrix, and then calculates the SVD.

if nargin < 3
    groups = 1:size(F,2);
end

assert(all(~isnan(F(:))));

% de-mean or z-score features
% save normalization factor
if std_feats
    normF = std(F);
else
    normF = ones(1,size(F,2));
end
mF = mean(F);
F_formatted = bsxfun(@minus, F, mF);
F_formatted = bsxfun(@times, F_formatted, 1./normF);

% % fix overall variance, done separately for each group
% n_groups = max(groups);
% for i = 1:n_groups
%     xi = groups==i;
%     X = F_formatted(:,xi);
%     total_rms = rms(X(:));
%     F_formatted(:,xi) = F_formatted(:,xi) / total_rms;
%     normF(xi) = normF(xi) * total_rms;
%     clear X xi total_rms;
% end

[U,S,V] = svd(F_formatted, 'econ');
s = diag(S);
clear S F_formatted;