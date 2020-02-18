function [Z,W,S,S_opt] = flda(X, labels, L, varargin)

% Implement Fisher's linear discriminant analysis as described in Murphy,
% 2006. 
% 
% X: data matrix, feature x sample
% 
% labels: list of integers specifying the label for each sample
% 
% L: desired dimensionality
% 
% see test_flda.m
% 
% 2019-08-07: Created, Sam NH

I.K = NaN;
I.optimize = true;
I.nthresh = 100;
I = parse_optInputs_keyvalue(varargin, I);

% reduce dimensionality
if ~isnan(I.K)
    X_orig = X;
    [Upca,~,~] = svd(X_orig, 'econ');
    Upca = Upca(:,1:I.K);
    X = Upca'*X_orig;
end

% data dimensionality
[D, N] = size(X);

% format labels
% determine numbef classes
[~,~,S.labels] = unique(labels);
C = max(S.labels);

% data mean
M = mean(X,2);

% class means
S.Mc = nan(D, C);
Nc = nan(1, C);
for i = 1:C
    xi = S.labels==i;
    S.Mc(:,i) = mean(X(:,xi),2);
    Nc(i) = sum(xi);
    clear xi;
end

% calculate between-class distance
S.Cb = zeros(D,D);
for i = 1:C
    S.Cb = S.Cb + (Nc(i)/N) * (S.Mc-M) * (S.Mc-M)';
end

% calculate within-class variance
S.Cw = zeros(D,D);
for i = 1:N
    S.Cw = S.Cw + (1/N) * (X(:,i) - S.Mc(:,S.labels(i)))*(X(:,i) - S.Mc(:,S.labels(i)))';
end

%% additional stats

% calculate average distance between categories
if nargout >=3
    
    S.Dbcum = mean(sqrt(cumsum(bsxfun(@minus, S.Mc, M).^2,1)),2);
    S.Db = S.Dbcum(end,:);
    
    % calculate average distance within categories
    S.Dwcum = 0;
    for i = 1:N
        S.Dwcum = S.Dwcum + (1/N) * sqrt(cumsum((X(:,i) - S.Mc(:,S.labels(i))).^2,1));
    end
    S.Dw = S.Dwcum(end,:);
    
    % accuracy
    S.acc = nan(D, C);
    S.dist_same = nan(D, C);
    S.dist_diff = nan(D, C);
    for i = 1:C
        Dsame = sqrt(cumsum(bsxfun(@minus, X(:,S.labels==i), S.Mc(:,i)).^2));
        Ddiff = sqrt(cumsum(bsxfun(@minus, X(:,S.labels~=i), S.Mc(:,i)).^2));
        S.dist_same(:,i) = mean(Dsame,2);
        S.dist_diff(:,i) = mean(Ddiff,2);
        
        thresh = linspace(min(Dsame(:)), max(Ddiff(:)), I.nthresh);
        acc = nan(D,I.nthresh);
        for l = 1:I.nthresh
            acc(:,l) = mean(Dsame < thresh(l),2)/2 + mean(Ddiff > thresh(l),2)/2;
        end
        S.acc(:,i) = max(acc,[],2);
    end
end

%%
if I.optimize
    
    % solve eigen value problem
    sqInvS.Cw = sqrtm(inv(S.Cw));
    [U,eigvals] = eig(sqInvS.Cw*S.Cb*sqInvS.Cw);
    U = real(U);
    eigvals = diag(real(eigvals));
    [~,xi] = sort(eigvals,'descend');
    U = U(:,xi);
    eigvals = eigvals(xi); %#ok<NASGU>
    clear xi;
    
    if ~isnan(I.K)
        % projection matrix
        W = Upca*sqInvS.Cw*U(:,1:L);
        
        % apply projection
        Z = W' * X_orig;
    else
        % projection matrix
        W = sqInvS.Cw*U(:,1:L);
        
        % apply projection
        Z = W' * X;
    end
    
    %% stats for optimized projection
    
    if nargout >= 4
        [~,~,S_opt] = flda(Z, labels, L, 'optimize', false);
    end
    
else
    
    Z = [];
    W = [];
    S_opt = [];

end
