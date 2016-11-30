function [Yh, test_folds] = regress_predictions_parallelize_with_slurm(...
    F, Y, test_folds, method, K, train_folds, output_directory, varargin)

addpath('/mindhive/nklab/u/svnh/sbatch-code-v2');

% batch parameters
B.max_num_process = 30;
B.batch_directory = output_directory;
B.mem = '8000';
B = parse_optInputs_keyvalue(varargin, B);

Yh = nan(size(Y));
while 1
    finished = false(1,size(Y,2));
    for i = 1:size(Y,2)
        MAT_file = [output_directory '/predictions' num2str(i) '.mat'];
        
        if ~exist(MAT_file, 'file')            
            
            % set the job id
            B.job_id = ['sb' num2str(i)];
            
            % matlab function, arguments and directory to call the function from
            B.matlab_fn = @regress_predictions_from_3way_crossval;
            B.matlab_fn_args = {F, Y(:,i), test_folds, method, K,...
                train_folds, MAT_file};
            B.directory_to_run_from = '/mindhive/nklab/u/svnh/general-analysis-code';
            
            % call the sbatch
            call_sbatch_smart(B);
                        
        end
        
        if exist(MAT_file, 'file')
            load(MAT_file, 'yh', 'test_fold_indices');
            Yh(:,i) = yh;
            test_folds = test_fold_indices;
            finished(i) = true;
        end
    end
    if all(finished)
        break;
    end
end