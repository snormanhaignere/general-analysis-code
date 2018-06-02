function [Yh, test_folds, MAT_files] = regress_predictions_wrapper(F, Y, varargin)

% Wrapper function for computing predictions from a set of features via
% regression. F is a [sample x dimension] matrix of feature values. Y is a
% [sample x D] matrix comprised of D response observations to be predicted using
% F (Y ~= F*Beta). These predictions are computed in batches, which is faster if
% D is large (default batch_size = 1000). The results can be saved in a
% directory of the users choice (default: working directory), and are not
% recomputed unless desired (see optional inputs). If SLURM is available, the
% batches can be parallelized. This function relies on two key functions:
%
% regress_predictions_from_3way_crossval.m
% regress_predictions_from_3way_crossval_noisecorr.m
%
% Using SLURM requires scripts from this repository:
% https://github.com/snormanhaignere/sbatch-code-v2
%
% 2017-03-15: Added capacity to overwrite files, Sam NH
%
% 2017-03-17: Fixed problem that caused the function to create huge log files
% when run via slurm.
%
% 2017-04-06: Changed name from regress_predictions_parallelize_with_slurm to
% regress_predictions_wrapper
%
% 2017-04-06/07: Cleaned up code and improved documentation

% parameters of this function
I.batch_size = 1000;
I.test_folds = 5;
I.train_folds = 5;
I.method = 'ridge';
I.K = [];
I.save_results = false;
I.overwrite = false;
I.output_directory = pwd;
I.slurm = false;
I.std_feats = true;
I.demean_feats = true;
I.groups = ones(1, size(F,2));
I.regularization_metric = 'unnormalized-squared-error';
I.noisecorr_regmetric = false;
I.correction_method = 'variance-based';
I.slurm_code_directory = '/mindhive/nklab/u/svnh/sbatch-code-v2';
I.max_num_process = 30;
I.mem = '8000';
I.max_run_time_in_min = num2str(60*10);
I.F_test = [];
I = parse_optInputs_keyvalue(varargin, I);

% must save results if using SLURM
if I.slurm
    I.save_results = true;
end

% add slurm code directory to path
if I.slurm
    addpath(I.slurm_code_directory);
end

% check dimensions and determine number of total batches
if I.noisecorr_regmetric
    assert(ndims(Y) == 3);
    n_batches = ceil(size(Y,3) / I.batch_size);
else
    assert(ndims(Y) == 2); %#ok<ISMAT>
    n_batches = ceil(size(Y,2) / I.batch_size);
end

% if not saving results
if ~I.slurm
    
    Yh = nan(size(Y));
    MAT_files = cell(1, n_batches);
    for i = 1:n_batches
        
        yi = (1:I.batch_size) + (i-1) * I.batch_size;
        if I.noisecorr_regmetric
            yi(yi > size(Y,3)) = [];
            Ybatch = Y(:,:,yi);
        else
            yi(yi > size(Y,2)) = [];
            Ybatch = Y(:,yi);
        end
        
        % MAT file to save results to
        if I.save_results
            MAT_files{i} = [I.output_directory '/predictions' ...
                num2str(yi(1)) '-' num2str(yi(end)) '.mat'];
        else
            MAT_files{i} = '';
        end
        
        fprintf('Started batch %d of %d: %d - %d\n', ...
            i, n_batches, yi(1), yi(end));
        
        if ~I.save_results || ~exist(MAT_files{i}, 'file') || I.overwrite
            
            [Yh_batch, test_folds] = ...
                predictions_single_batch(F, Ybatch, I, MAT_files{i}, i);
            
        else
            
            batch = load(MAT_files{i}, 'Yh', 'test_fold_indices');
            Yh_batch = batch.Yh;
            test_folds = batch.test_fold_indices;
            
        end
        
        if I.noisecorr_regmetric
            Yh(:, :, yi) = Yh_batch;
        else
            Yh(:, yi) = Yh_batch;
        end
        
        clear Ybatch Yh_batch;
    end
    
else
    
    % initialize variables
    Yh = nan(size(Y));
    overwritten = false(1, n_batches);
    finished_batch = false(1, n_batches);
    MAT_files = cell(1, n_batches);
    while ~all(finished_batch) % loop until complete
        
        for i = 1:n_batches
            
            yi = (1:I.batch_size) + (i-1) * I.batch_size;
            if I.noisecorr_regmetric
                yi(yi > size(Y,3)) = [];
                Ybatch = Y(:,:,yi);
            else
                yi(yi > size(Y,2)) = [];
                Ybatch = Y(:,yi);
            end
            
            % MAT file to save results to
            MAT_files{i} = [I.output_directory '/predictions' ...
                num2str(yi(1)) '-' num2str(yi(end)) '.mat'];
            
            % optionally overwrite
            if I.overwrite && ~overwritten(i)
                if exist(MAT_files{i}, 'file')
                    delete(MAT_files{i})
                end
                overwritten(i) = true;
            end
            
            if ~exist(MAT_files{i}, 'file')
                
                [~,~,batch_started] = ...
                    predictions_single_batch(F, Ybatch, I, MAT_files{i}, i);
                
                % indicate that a job has been started
                if batch_started
                    fprintf('Started batch %d of %d: %d - %d\n', ...
                        i, n_batches, yi(1), yi(end));
                    drawnow;
                end
                
            else
                
                % try to read the file for 5 minutes ..
                % (file might exist but not be fully written to)
                tic;
                while toc < 5*60
                    try
                        batch = load(MAT_files{i}, 'Yh', 'test_fold_indices');
                        if I.noisecorr_regmetric
                            Yh(:, :, yi) = batch.Yh;
                        else
                            Yh(:, yi) = batch.Yh;
                        end
                        test_folds = batch.test_fold_indices;
                        finished_batch(i) = true;
                        break;
                    catch
                    end
                end
                
                % if couldn't read the file, delete it so that it's regenerated
                if ~finished_batch(i)
                    delete(MAT_files{i});
                end
            end
            clear yi Ybatch;
        end
    end
end

function [Yh, folds, batch_started] = predictions_single_batch(F, Y, I, MAT_file, job_index)

% arguments to the function
func_args = {...
    F, Y, 'test_folds', I.test_folds, 'train_folds', I.train_folds, ...
    'method', I.method, 'K', I.K, 'std_feats', I.std_feats, ...
    'demean_feats', I.demean_feats, 'groups', I.groups, 'MAT_file', MAT_file,...
    'regularization_metric', I.regularization_metric, ...
    'F_test', I.F_test};

% arguments only applicable to noise correction
if I.noisecorr_regmetric
    func_args = [func_args, 'correction_method', I.correction_method];
end

if I.slurm
    
    % structure with batch parameters for slurm
    B.max_num_process = I.max_num_process;
    B.mem = I.mem;
    B.max_run_time_in_min = num2str(60*10);
    B.batch_directory = I.output_directory;
    
    % set the job id
    % hash string for the job id
    ResetRandStream2(1);
    Frand = F(randi(numel(F), [min(numel(F), 10000),1]));
    Yrand = Y(randi(numel(Y), [min(numel(Y), 10000),1]));
    hashstring = DataHash({Frand, Yrand, I});
    B.job_id = [num2str(job_index) '-' hashstring];
    
    % arguments
    if I.noisecorr_regmetric
        B.matlab_fn = @regress_predictions_from_3way_crossval_noisecorr;
    else
        B.matlab_fn = @regress_predictions_from_3way_crossval;
    end
    B.matlab_fn_args = func_args;
    B.directory_to_run_from = fileparts(which(mfilename));
    batch_started = call_sbatch_smart(B);
    Yh = [];
    folds = [];
    
else
    
    % start job
    if I.noisecorr_regmetric
        [Yh, folds] = ...
            regress_predictions_from_3way_crossval_noisecorr(func_args{:});
    else
        [Yh, ~, ~, folds] = ...
            regress_predictions_from_3way_crossval(func_args{:});
    end
    batch_started = true;
    
end