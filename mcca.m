function [U, W] = mcca_v2(X, si, varargin)

clear I;
I.keep = NaN;
I.sphere = true;
I.ppca_args = {};
I = parse_optInputs_keyvalue(varargin, I);

[~, ~, si] = unique(si);
n_subjects = max(si(:));
Uallsubs = [];
if any(isnan(X(:))) % if NaNs reconstruct using ppca
    [U,S,V] = myppca(X, size(X,2),  I.ppca_args{:});
    X = U*S*V';
end
for i = 1:n_subjects
    fprintf('s%d\n', i); drawnow;
    [U, S, ~] = svd(X(:,si==i), 'econ');
    if I.sphere
        Z = U;
    else
        Z = U*S;
    end
    if ~isnan(I.keep)
        Z = Z(:,1:min(I.keep, size(Z,2)));
    end
    Uallsubs = cat(2, Uallsubs, Z);
end

% pool individual subject PCs
[U,~,~] = svd(Uallsubs, 'econ');

% weights
W = pinv(U)*X;

    