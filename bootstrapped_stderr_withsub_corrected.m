function [E, med] = bootstrapped_stderr_withsub_corrected(X, n_smps)

% Calculates standard error margins via bootstrapping. The input X is an M x N matrix with M samples
% from N conditions. Condition means are calculated by sampling with replacemnt N_SMPS times.
% Ignores differences in row means when calculating standard errors (i.e. 'within-subject standard
% errors' when the rows correspond to different subjects).
% 
% The output is a 2 x M matrix with lower and upper standard error for each condition. 
% 
% -- Example: Two condition matrix --
% 
% N = 10;
% sig = 1;
% column_means = [1 2];
% row_means = randn(N,1)*10;
% X = [randn(N,1)*sig + means(1) + row_means, randn(N,1)*sig + means(2) + row_means];
% analytic_withsub_stderr = sig/sqrt(N)
% E = bootstrapped_stderr_withsub_corrected(X, 10000);
% diff(E)/2
% analytic_betweensub_stderr = sqrt(sig^2/(N) + 10^2/(N))
% E = bootstrapped_stderr(X, 10000);
% diff(E)/2
% 
% -- Example: Check bias --
% 
% N = 10;
% sig = 1;
% column_means = [1 2];
% row_means = randn(N,1)*10;
% analytic_withsub_stderr = sig/sqrt(N)
% err = nan(100,2);
% for i = 1:100
%     X = [randn(N,1)*sig + means(1) + row_means, randn(N,1)*sig + means(2) + row_means];
%     E = bootstrapped_stderr_withsub_corrected(X, 1000);
%     err(i,:) = diff(E)/2;
% end
% mean(err)

% reshape to 2D matrix
dims = size(X);
X = reshape(X, [dims(1), prod(dims(2:end))]);

n_rows = size(X,1);
n_cols = size(X,2);
smps = randi(n_rows, [n_rows, n_smps]);

bootstrapped_means = nan(n_smps, n_cols);
for i = 1:n_cols
    X_single_col = X(:,i);
    bootstrapped_means(:,i) = mean(X_single_col(smps));    
end

% reshape back to ND matrix
bootstrapped_means = reshape(bootstrapped_means, [n_smps, dims(2:end)]);

% errors and medians
E = stderr_from_samples_withsub_corrected(bootstrapped_means);
med = median(bootstrapped_means);