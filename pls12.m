function [Xs,Xl,Yl] = pls12(X,Y,K,demean,stdXY)

% Implements PLS 1/2 regression. Returns three matrices that approximate the
% feature matrix X and data Y as a linear combinations of orthonormal features:
% 
% X ~= Xs * Xl'
% Y ~= Xs * Yl'
% 
% Each columns of the score matrix Xs has maximal covariance with Y, after
% parcelling out the contribution of all other columns that come before it.
% 
% Xs' * Xs = eye(size(Xs,2))
% 
% 2016-01-19: Created, Sam NH


% whether or not to demean X and Y
if nargin < 4 || isempty(demean)
    demean = true;
end

% whether or not to divide each column of 
% X and Y by their standard deviation
if nargin < 5 || isempty(stdXY)
    stdXY = [false, false];
end

% demean
if demean
    mX = mean(X);
    mY = mean(Y);
    df = size(X,1)-1;
else
    mX = zeros(1,size(X,2));
    mY = zeros(1,size(Y,2));
    df = size(X,1);
end
X0 = bsxfun(@minus, X, mX);
Y0 = bsxfun(@minus, Y, mY);

% standardize
if stdXY(1)
    normX = std(X);
else
    normX = ones(1,size(X,2));
end
if stdXY(2)
    normY = std(Y);
else
    normY = ones(1,size(Y,2));
end
X0 = bsxfun(@times, X0, 1./normX);
Y0 = bsxfun(@times, Y0, 1./normY);
    
% number of components
max_size = min(df, max(size(X,2)));
if nargin < 3 || isempty(K)
    K = max_size;
else
    assert(K <= max_size);
end

% rotate to PCs to speed computation
[Ux, Sx, Vx] = svd(X0,'econ');
[Uy, Sy, Vy] = svd(Y0,'econ');
Xk = Ux * Sx;
Yk = Uy * Sy;

% iterative analysis loop
Xs = nan(size(Xk,1), K);
Xl = nan(size(Xk,2), K);
Yl = nan(size(Yk,2), K);
for i = 1:K
    
    % first principle component of covariance matrix
    % empirically faster to use eig than svd or eigs
    Sk = (Xk'*Yk)*(Yk'*Xk);
    [Z,D] = eig(Sk);
    [~,xi] = max(diag(D));    
    w = Z(:,xi(1)); 
    clear Z D Sk;
    
    % calculate score vector
    t = Xk*w;
    t = t/norm(t);
    clear w;
    
    % calculate loadings
    p = (pinv(t)*Xk)';
    q = (pinv(t)*Yk)';
    
    % deflate
    Xk = Xk - t*p';
    Yk = Yk - t*q';
    
    % store results
    Xs(:,i) = t;
    Xl(:,i) = p;
    Yl(:,i) = q;
    clear t p q;

end

% rotate from PCs back to original space
Xl = Vx * Xl;
Yl = Vy * Yl;

% rescale to undo normalization
Xl = bsxfun(@times, Xl, normX');
Yl = bsxfun(@times, Yl, normY');

% add mean back in
if demean
    t = ones(size(X,1),1);
    t = t/norm(t);
    Xs = [t, Xs];
    Xl = [X'*t, Xl];
    Yl = [Y'*t, Yl];
end