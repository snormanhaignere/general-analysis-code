function p = bootstrap_anova_oneway_fromsmps_perm(S)

S_shuff = Shuffle(S')';

% calculate variance
% v_obs = var(o, [], 2);
err = var(bsxfun(@minus, S, mean(S,1)), [], 2);
err_perm = var(bsxfun(@minus, S_shuff, mean(S_shuff,1)), [], 2);

keyboard;

% F_obs = v_obs / v_resid;
% 
% F_null = v_obs / v_resid_perm;

p = mean(err > err_perm);


