function [r, Px_sig, Py_sig, XY, Mx, My] = noise_corrected_similarity(X, Y, varargin)

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
% noise_corrected_similarity(X, Y, 'NAME', 'VALUE', ...) 
% 
% same_noise: Whether the noise has the same properties for X and Y (default:
% false)
% 
% metric: 'pearson' (default) or 'demeaned-squared-error' (variance-sensitive
% correlation)
% 
% 
% % -- Simple example with a couple of metrics --
% 
% % create a correlated signal
% N = 100;
% global_sig = randn(N, 1);
% Xsig = global_sig + randn(N, 1);
% Ysig = global_sig + randn(N, 1) + 3;
% 
% % add i.i.d. noise to each column
% X = bsxfun(@plus, Xsig, 1*randn(N, 3));
% Y = bsxfun(@plus, Ysig, 1*randn(N, 2));
% 
% % true signal correlation and estimate
% corr(Xsig, Ysig)
% noise_corrected_similarity(X, Y)
% normalized_squared_error(Xsig,Ysig)
% noise_corrected_similarity(X, Y, 'metric', 'normalized-squared-error')
% 
% % -- Example: Compare with normalized_correlation.m --  
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
%         r2(j,i) = noise_corrected_similarity(X, Y, 'same_noise', true);
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
% 
% % -- Example: normalized squared error metric --
% 
% sig = logspace(log10(0.5),log10(10),10);
% n_smps = 100;
% r = nan(n_smps, 10, 4);
% rest = nan(n_smps, 10, 4);
% 
% for k = 1:4
%     for i = 1:10
%         
%         fprintf('%d\n', i);
%         
%         for j = 1:n_smps
%             
%             % create a correlated signal
%             N = 100;
%             global_sig = randn(N, 1);
%             Xsig = global_sig + randn(N, 1)*sig(i) + k-1;
%             Ysig = global_sig + randn(N, 1)*sig(i);
%             
%             % add i.i.d. noise to each column
%             X = bsxfun(@plus, Xsig, 2*randn(N, 3));
%             Y = bsxfun(@plus, Ysig, 2*randn(N, 2));
%             
%             r(j,i,k) = normalized_squared_error(Xsig, Ysig);
%             % rest(j,i,k) = normalized_squared_error(X(:,1), Y(:,1));
%             rest(j,i,k) = noise_corrected_similarity(X, Y, 'metric', 'normalized-squared-error');
%             
%         end
%     end
% end
% 
% figure;
% for k = 1:4
%     X = r(:,:,k);
%     Y = rest(:,:,k);
%     plot(X(:), Y(:), 'o');
%     hold on;
%     plot([0 1], [0 1], 'r--', 'LineWidth', 2);
%     xlim([-0.2 1.2]); ylim([-0.2 1.2])
%     title(sprintf('Version %d', i));
% end

% 2017-03-19: Modified to return numerator and denominator separately
% 
% 2017-03-20: Fixed a bug that prevent the scripts from working when one of the
% variables is only sampled once.
% 
% 2017-03-27: Changed output so that it returns the three key stats, rather than
% the numerator and denominator
% 
% 2017-03-29: Added 'variance_centering' option
% 
% 2017-08-25: Made it possible to only compute cross column covariances
% 
% 2017-09-26: Made it possible to compute the normalized squared error, which
% requires correlation and power statistics instead of covariance and variance
% statistics, as well as mean statistics
% 
% 2018-03-16: Made it possible to take the absolute value of the
% denominator rather than returning NaN.
% 
% 2018-04-23: Can force the noise to only be computed from one of the two
% variables

% whether or not the noise is the same for X and Y samples
I.same_noise = false;
I.noise_only_from_Y = false;
I.noise_only_from_X = false;
I.metric = 'pearson';
I.variance_centering = false;
I.only_cross_column_cov = false;
I.neg_denom = 'NaN';
I = parse_optInputs_keyvalue(varargin, I);

% if we're estimating the noise power of X from Y
% then we're assuming the noise is the same, and 
% we can't do the reverse
if I.noise_only_from_Y
    I.same_noise = true;
    assert(~I.noise_only_from_X);
    assert(size(Y,2)>1);
end
if I.noise_only_from_X
    I.same_noise = true;
    assert(~I.noise_only_from_Y)
    assert(size(X,2)>1);
end

% force only taking noise from one of the variables if theother is not available
if I.same_noise && size(X,2) == 1 && size(Y,2) > 1
    I.noise_only_from_Y = true;
end
if I.same_noise && size(Y,2) == 1 && size(X,2) > 1
    I.noise_only_from_X = true;
end

% needs to be multiple samples for X and Y if the noise is different
% otherwise needs to be multiple samples for either X or Y
if ~I.same_noise
    assert(size(X,2)>1 && (size(Y,2)>1));
else
    assert(size(X,2)>1 || (size(Y,2)>1));
end

% set standard deviation of samples to the global mean standard deviation
% for each variable separately
if I.variance_centering
    X = bsxfun(@times, X, mean(std(X))./std(X));
    Y = bsxfun(@times, Y, mean(std(Y))./std(Y));
end

% features specific to the normalized squared error metric
% whether to compute the power or the variance
% whether to use the correlation or covariance
% normalized squared error also requires the sample means
if strcmp(I.metric, 'normalized-squared-error')
    power_not_variance = true;
    corr_func = @(a,b)sum(a.*b)/size(a,1);
else
    power_not_variance = false;
    corr_func = @(a,b)sum((a-mean(a)).*(b-mean(b)))/(size(a,1)-1);
end

% means (only needed for normalized squared error metric)
Mx = mean(mean(X,1),2);
My = mean(mean(Y,1),2);

% estimate power or variance in the signal
wx = size(X,2); wy = size(Y,2);
[Px_sig, Px_noise, Px_total] = separate_sig_and_noise_var(X, 'power', power_not_variance);
[Py_sig, Py_noise, Py_total] = separate_sig_and_noise_var(Y, 'power', power_not_variance);

% optionally combine the two noise variance or power estimates, and use this to
% estimate the variance/power of the signal
if I.same_noise
    if I.noise_only_from_Y
        Pxy_noise = Py_noise;
    elseif I.noise_only_from_X
        Pxy_noise = Px_noise;
    else
        Pxy_noise = (Px_noise*wx + Py_noise*wy) / (wx + wy);
    end
    Px_sig = Px_total - Pxy_noise;
    Py_sig = Py_total - Pxy_noise;
end

% estimate covariance or correlation
XY = nanfunc_all_column_pairs(corr_func, X, Y);
if I.only_cross_column_cov
    XY = mean(XY(~eye(size(XY))));
else
    XY = mean(XY(:));
end

% compute the desired metric
switch I.metric
    case 'pearson'
        if Px_sig < 0 || Py_sig < 0
            r = NaN;
        else
            r = XY / sqrt(Px_sig * Py_sig);
        end
        
    case 'demeaned-squared-error'
        if (Px_sig + Py_sig) < 0
            r = NaN;
        else
            % r = 1 - (Xvar + Yvar - 2*XYcov) / (Xvar + Yvar);
            r = XY / ((Px_sig + Py_sig)/2);
        end
    case 'unnormalized-squared-error'
        r = Px_sig + Py_sig - 2*XY;
        
    case 'normalized-squared-error'
        a = Px_sig + Py_sig - 2*XY;
        b = Px_sig + Py_sig - 2*Mx*My;
        if b < 0
            switch I.neg_denom
                case 'NaN'
                    r = NaN;
                case 'abs'
                    r = 1 - a./abs(b);
                otherwise
                    error('params:notvalid', 'neg_denom cannot be %s', I.neg_denom);
            end
        else
            r = 1 - a./b;
        end
    
    case 'std-ratio-v2'
        if Py_sig < 0
            switch I.neg_denom
                case 'NaN'
                    r = NaN;
                case 'abs'
                    r = sign(Px_sig) .* sqrt(abs(Px_sig) ./ abs(Py_sig));
                otherwise
                    error('params:notvalid', 'neg_denom cannot be %s', I.neg_denom);
            end
        else
            r = sign(Px_sig) .* sqrt(abs(Px_sig) ./ Py_sig);
        end
        
    otherwise
        error('No matching case for metric %s\n', I.metric);
end

% check r is real
if ~isreal(r)
    error('r should be real');
end