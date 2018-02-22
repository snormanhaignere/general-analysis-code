function p = bootstrap_anova_oneway_fromsmps(o, S)

% o: observed
% 
% S: bootstrapped samples

% -- Example -- 
% 
% ps = nan(1000,1);
% for i = 1:1000  
%     
%     N = 20;
%     p = 5;
%     X = randn(N,p);
%     
%     % bootstrap samples
%     S = bootstrp(1000, @(a)mean(a,1), X);
%     
%     % p value
%     ps(i) = bootstrap_anova_oneway_fromsmps(mean(X,1), S);
% 
% end

assert(ismatrix(S));

% remove mean for each condition
S_demean = bsxfun(@minus, S, mean(S,1));

% calculate variance
v_obs = var(o, [], 2);
v_null = var(S_demean, [], 2);

% p value
p = mean(v_obs < v_null);
