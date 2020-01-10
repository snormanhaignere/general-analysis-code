function [U, W] = mcca(X, si, varargin)

clear I;
I.keep = NaN;
I.sphere = true;
I.ppca = false;
I.ppca_args = {};
I = parse_optInputs_keyvalue(varargin, I);

[~, ~, si] = unique(si);
n_subjects = max(si(:));
Uallsubs = [];
if I.ppca
    X_recon = nan(size(X));
end
for i = 1:n_subjects
    fprintf('s%d\n', i); drawnow;
    if I.ppca
        if sum(si==i)==1
            assert(all(~isnan(X(:,si==i))));
            [U,S,V] = svd(X(:,si==i), 'econ');
            X_recon(:,si==i) = X(:,si==i);
        else
            if ~isnan(I.keep)
                K = min(I.keep, sum(si==i));
            else
                K = sum(si==i);
            end
            try
                [U, S, V] = myppca(X(:,si==i), K, I.ppca_args{:});
            catch
                keyboard
            end
            X_recon(:,si==i) = U*S*V';
        end
    else
        [U, S, ~] = svd(X(:,si==i), 'econ');
    end
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

[U,~,~] = svd(Uallsubs, 'econ');

if I.ppca
    W = pinv(U)*X_recon;
else
    W = pinv(U)*X;
end
    