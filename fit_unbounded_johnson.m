function msab = fit_unbounded_johnson(x)
% function msab = fit_unbounded_johnson(x)
% 
% Finds parameters of the unbounded Johnson distribution that maximize
% the likelihood of the data, using gradient methods. 
% 
% See log_unbounded_johnson.m for details.
% 
% Example 1: Sample from and fit Johnson distribution
% msab = [0,1,1,1]; % skewed 
% smps = sample_unbounded_johnson(msab, [1,10000]);
% masb_fit = fit_unbounded_johnson(smps);
% x = linspace(-5, 25, 100);
% [N,x] = hist(smps,x);
% px_hist = N/sum(N);
% log_px = log_unbounded_johnson(x', masb_fit);
% px = exp(log_px)/sum(exp(log_px));
% plot(x', [px_hist', px]);
% yL = ylim;
% hold on;
% plot([0,0], yL, 'k--');
% legend('Samples', 'Fit');
% 
% Last modified by Sam Norman-Haignere on 4/2/2015

% options = optimoptions('fmincon','Algorithm','interior-point','GradObj','on','MaxIter',1e3,'Display','none','TolFun', 1e-6,'TolX',1e-6);
% johnson_fun_handle = @(msab)log_unbounded_johnson(x,msab,1);
% msab = fmincon(johnson_fun_handle,[0,1,0,1],[],[],[],[],[-inf,0,-inf,0],[inf,inf,inf,inf],[],options);

options = optimoptions('fminunc','Algorithm','quasi-newton','GradObj','on','MaxIter',1e3,'Display','none','TolFun', 1e-6,'TolX',1e-6);
johnson_fun_handle = @(msab)log_unbounded_johnson(x,msab,1);
msab = fminunc(johnson_fun_handle,[0,1,0,1],options);
