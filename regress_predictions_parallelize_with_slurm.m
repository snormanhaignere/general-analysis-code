function [Yh, test_folds] = regress_predictions_parallelize_with_slurm(...
    F, Y, test_folds, method, K, train_folds, output_directory, varargin)

% 2017-03-15: Added capacity to overwrite files, Sam NH
% 
% 2017-03-17: Fixed problem that caused the function to create huge log files
% when run via slurm.

addpath('/mindhive/nklab/u/svnh/sbatch-code-v2');

% batch parameters
B.max_num_process = 30;
B.batch_directory = output_directory;
B.mem = '8000';
B.std_feats = true;
B.groups = [];
B.batch_size = 1000;
B.max_run_time_in_min = num2str(60*10);
B.overwrite = false;
B.use_sbatch = true;
B = parse_optInputs_keyvalue(varargin, B);

n_batches = ceil(size(Y,2) / B.batch_size);

Yh = nan(size(Y));
overwritten = false(1, n_batches);
while true
        
    finished_batch = false(1, n_batches);
    for i = 1:n_batches
        
        yi = (1:B.batch_size) + (i-1) * B.batch_size;
        yi(yi > size(Y,2)) = [];
        MAT_file = [output_directory '/predictions' ...
            num2str(yi(1)) '-' num2str(yi(end)) '.mat'];
        
        % overwrite once
        if B.overwrite && ~overwritten(i)
            if exist(MAT_file, 'file')
                delete(MAT_file)
            end
            overwritten(i) = true;
        end
        
        if ~exist(MAT_file, 'file')            
            
            if B.use_sbatch
                % set the job id
                B.job_id = ['sb' num2str(i)];
                
                % matlab function, arguments and directory to call the function from
                B.matlab_fn = @regress_predictions_from_3way_crossval;
                B.matlab_fn_args = {F, Y(:,yi), test_folds, method, K,...
                    train_folds, MAT_file, B.std_feats, B.groups};
                B.directory_to_run_from = '/mindhive/nklab/u/svnh/general-analysis-code';
                
                % call the sbatch
                job_started = call_sbatch_smart(B);
                if job_started
                    fprintf('Started batch %d of %d: %d - %d\n', ...
                        i, n_batches, yi(1), yi(end));
                    drawnow;
                end
                
            else
                regress_predictions_from_3way_crossval(F, Y(:,yi), ...
                    test_folds, method, K, train_folds, MAT_file, ...
                    B.std_feats, B.groups);
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
                    batch = load(MAT_file, 'Yh', 'test_fold_indices');
                    Yh(:,yi) = batch.Yh;
                    test_folds = batch.test_fold_indices;
                    finished_batch(i) = true;
                    break;
                catch
                end
            end
            
            % if couldn't read the file, delete it so that it's regenerated
            if ~finished_batch(i)
                delete(MAT_file);
            end
            
        end
        clear yi;
        
    end
    
    if all(finished_batch)
        break;
    end
end