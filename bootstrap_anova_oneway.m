
n_iter = 1000;
ps = nan(n_iter,1);
for i = 1:n_iter
    
    if mod(i, n_iter/20)==0
        fprintf('%d\n', i);
        drawnow;
    end
    
    N = 8;
    p = 5;
    X = randn(N,p);
    
    % bootstrap samples
    S = bootstrp(1000, @(a)mean(a,1), X);
    
    % p value
    ps(i) = bootstrap_anova_oneway_fromsmps_perm(S);

end


%%


n_iter = 1000;
ps = nan(n_iter,1);
for i = 1:n_iter
    
    if mod(i, n_iter/20)==0
        fprintf('%d\n', i);
        drawnow;
    end
    
    N = 8;
    p = 2;
    X = randn(N,p);
    
    % bootstrap samples
    S = bootstrp(1000, @(a)mean(a,1), X);
    
    % p value
    ps(i) = mean(S(:,1) < S(:,2));

end


%%


% mean(ps < 0.05)

N = 20;
p = 5;
X = randn(N,p);

% bootstrap samples
S = bootstrp(1000, @(a)mean(a,1), X);


% remove trial mean

% S2 = bsxfun(@minus, )
% hist(S1)