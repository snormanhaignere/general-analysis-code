function R = reliability(D, varargin)

% Calculates test-retest reliability and optionally 
% calculates significance via a permutation test
% 
% D: samples x reps x variables

% 2019-01-29: Reliability calculation, Sam NH

[n_smps, n_reps, n_vars] = size(D);

I.splithalf = true;
I.spearbrown = false;
I.nperms = 0;
I.chunksize = 0;
I.removeNaNs = false;
I = parse_optInputs_keyvalue(varargin, I);

% reliability per electrode
R.corr = nan(1, n_vars);
for i = 1:n_vars
    R.corr(i) = corrfn(D(:,:,i), I.splithalf, I.spearbrown, I.removeNaNs);
end

% permutation test
if I.nperms > 0
    
    R.null = nan(I.nperms, n_vars);
    D_perm = nan(size(D));
    for z = 1:I.nperms
        
        if mod(z,10)==0
            fprintf('perm %d\n', z); drawnow;
        end
        
        % shuffle one-second chunks
        for j = 1:n_reps
            if I.chunksize == 0
                D_perm(:,j,:) = D(randperm(n_stimuli),j,:);
            else
                % divide into into chunks
                n_chunks = ceil(n_smps/I.chunksize);
                xi = reshape(1:(I.chunksize * n_chunks), I.chunksize, n_chunks);
                xi(n_smps+1:end) = NaN;
                
                % permute chunks
                xi = xi(:,randperm(n_chunks));
                xi = xi(:);
                xi(isnan(xi)) = [];
                
                % assign based on permuted chunks
                D_perm(:,j,:) = D(xi,j,:);
            end
        end
        
        % reliability per electrode
        for i = 1:n_vars
            R.null(z, i) = corrfn(D_perm(:,:,i), I.splithalf, I.spearbrown, I.removeNaNs);
        end
    end
    
    [R.logP_gauss, R.z] = sig_via_null_gaussfit(R.corr, R.null);
    [R.logP_counts] = sig_via_null_counts(R.corr, R.null);
    R.logP_gauss(isinf(R.logP_gauss)) = max(R.logP_gauss(~isinf(R.logP_gauss)));
        
else
    
    R.logP_gauss = [];
    R.z = [];
    R.logP_counts = [];
    
end

function r_final = corrfn(X, splithalf, spearbrown, removeNaNs)


% data without outliers
% samples/time x run for single electrode
if removeNaNs
    % remove columns with only NaNs
    X = X(:,any(~isnan(X),1));
    assert(~isempty(X));
    
    % remove rows with any NaNs
    X_not_outliers = X(all(~isnan(X),2),:);
else
    X_not_outliers = X;
end
assert(all(~isnan(X_not_outliers(:))));
clear X;

% number or repetitions
n_reps = size(X_not_outliers,2);

% splithalf or rep-by-rep correlation
if splithalf
    odd_runs = 1:2:n_reps;
    even_runs = 2:2:n_reps;
    odd_runs = odd_runs(1:length(even_runs));
    assert(length(odd_runs)==length(even_runs));
    runs_per_split = length(odd_runs);
    assert(runs_per_split>0);
    r = corr(mean(X_not_outliers(:,odd_runs),2), mean(X_not_outliers(:,even_runs),2));
    clear odd_runs even_runs;
else
    runs_per_split = 1;
    r_pairs = corr(X_not_outliers); % correlation of response timecourse for all pairs of runs
    r = mean(r_pairs(~eye(n_reps))); % average off diagonal entries
    clear r_pairs;
end
clear X_not_outliers;

% spearman brown correct
if spearbrown
    r_final = correlation_power_analysis(r, n_reps/runs_per_split, 0); % estimate reliability of entire dataset
else
    r_final = r;
end
clear r runs_per_split;