function r = normalized_correlation_v2(X, Y, varargin)

% Computes an estimate of the normalized correlation between X and Y. Version 2
% unlike version 1 can be applied to data where only one of the two variables
% have been sampled multiple times, as long as the noise is known to have the
% same properties across both measurements.
% 
% -- Inputs -- 
% 
% X, Y: Each column is assumed to reflect a fixed signal present throughout all
% columns plus uncorrelated noise, independently sampled for each column. 
% 
% -- Optional Arguments -- 
% 
% Optional arguments are specified as name-value pairs, e.g:
% normalized_correlation_v2(X, Y, 'NAME', 'VALUE', ...) 
% 
% same_noise: Whether the noise has the same properties for X and Y (default:
% false)
% 
% metric: 'pearson' (default) or 'demeaned-squared-error' (variance-sensitive
% correlation)
% 
% % -- Simple Example -- 
% 
% % create a correlated signal
% N = 100;
% Xsig = randn(N, 1);
% Ysig = Xsig + randn(N, 1);
% 
% % add i.i.d. noise to each column
% X = bsxfun(@plus, Xsig, 1*randn(N, 3));
% Y = bsxfun(@plus, Ysig, 1*randn(N, 2));
% 
% % true signal correlation and estimate
% corr(Xsig, Ysig)
% normalized_correlation_v2(X, Y)
% 
% 
% % -- Example: Compare with normalized_correlation_v2.m --  
% sig = logspace(log10(0.5),log10(10),10);
% n_smps = 100;
% r = nan(n_smps, 10);
% r1 = nan(n_smps, 10);
% r2 = nan(n_smps, 10);
% 
% for i = 1:10
%     
%     fprintf('%d\n', i);
%     
%     for j = 1:n_smps
%         
%         % create a correlated signal
%         N = 100;
%         Xsig = randn(N, 1);
%         Ysig = Xsig + randn(N, 1)*sig(i);
%         
%         % add i.i.d. noise to each column
%         X = bsxfun(@plus, Xsig, 1*randn(N, 3));
%         Y = bsxfun(@plus, Ysig, 1*randn(N, 2));
%         
%         r(j,i) = corr(Xsig, Ysig);
%         r1(j,i) = normalized_correlation(X, Y);
%         r2(j,i) = normalized_correlation_v2(X, Y, 'same_noise', true);
%         
%     end
% end
% 
% figure;
% set(gcf, 'Position', [200 200 800 300]);
% for i = 1:2
%     if i == 1
%         z = r1;
%     else
%         z = r2;
%     end
%     subplot(1,2,i);
%     plot(r(:), z(:), 'o');
%     hold on;
%     plot([0 1], [0 1], 'r--', 'LineWidth', 2);
%     xlim([-0.2 1.2]); ylim([-0.2 1.2])
%     title(sprintf('Version %d', i));
% end
% 
% nanmedian(abs(r(:) - r1(:)))
% nanmedian(abs(r(:) - r2(:)))

% whether or not the noise is the same for X and Y samples
I.same_noise = false;
I.metric = 'pearson';
I = parse_optInputs_keyvalue(varargin, I);

% needs to be multiple samples for X and Y if the noise is different
% otherwise needs to be multiple samples for either X or Y
if ~I.same_noise
    assert(size(X,2)>1 && (size(Y,2)>1));
else
    assert(size(X,2)>1 || (size(Y,2)>1));
end

% estimate variance of the signal
if size(X,2) > 1
    [Xvar, Xnoisevar, Xtotalvar] = separate_sig_and_noise_var(X);
end
if size(Y,2) > 1
    [Yvar, Ynoisevar, Ytotalvar] = separate_sig_and_noise_var(Y);
end
if I.same_noise
    wx = size(X,2); wy = size(Y,2);
    shared_noisevar = (Xnoisevar .* wx + Ynoisevar*wy) / (wx + wy);
    Xvar = Xtotalvar - shared_noisevar;
    Yvar = Ytotalvar - shared_noisevar;
end

% estimate covariance
f = @(a,b)sum((a-mean(a)).*(b-mean(b)))/(size(a,1)-1);
XYcov = nanfunc_all_column_pairs(f, X, Y);
XYcov = mean(XYcov(:));

% compute the desired metric
switch I.metric
    case 'pearson'
        r = XYcov / sqrt(Xvar * Yvar);
    case 'demeaned-squared-error'
        r = 1 - (Xvar + Yvar - 2*XYcov) / (Xvar + Yvar);
    otherwise
        error('No matching case for metric %s\n', metric);
end