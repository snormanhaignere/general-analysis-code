function [U, W] = mcca(X, si, varargin)

% Implements MCCA analysis, similar to that described in Alain's paper
% 
% If there NaN values, probabilistic pca is used to fill them in.
% 
% 2019-01-10: Last edited, Sam NH

% optional arguments
clear I;
I.keep = NaN; % can optionally only keep N components from every subject
I.sphere = true; % whether to sphere each subjects data, only set to false to compare with vanilla pca
I.ppca_args = {}; % arguments to myppca function to used to fill in NaN values
I = parse_optInputs_keyvalue(varargin, I);

% modify subject ids to gaurantee monotonic increase
[~, ~, si] = unique(si);

% total number of subjects
n_subjects = max(si(:));

% fill in NaN values using ppca
if any(isnan(X(:))) % if NaNs reconstruct using ppca
    [U,S,V] = myppca(X, size(X,2),  I.ppca_args{:});
    X = U*S*V';
end

% concate the sphered U matrix from all subjects
Uallsubs = [];
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

% group PCA
[U,~,~] = svd(Uallsubs, 'econ');

% infer reconstruction weights
W = pinv(U)*X;

    