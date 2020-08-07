function partition_index = partition_within_labels_v2(labels, partition_fractions, varargin)

% Group elements of a vector into partitions separately for elements with the
% same label. Useful for training / testing models where you want an even number
% of examples per class in the training / testing set.
% 
% -- Example --
% 
% % Create training, validation, test set with 60/20/20%. There are three
% % classes, each with 5 elements.
% labels = [1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3];
% partition_fractions = [0.6, 0.2, 0.2];
% partition_index = partition_within_labels(labels, partition_fractions);
% reshape(partition_index, 5, 3)
% 
% 2018-02-22: Created, Sam NH
% 
% 2018-04-11: Updated to work with cell arrays of labels, and to make shuffling
% within a label group optional, also made it possible to specify an integer
% argument in which case the partition is even amongst that many groups

I.seed = [];
I.shuffle = true;
I = parse_optInputs_keyvalue(varargin, I);

% check vector
assert(isvector(labels));

% optionally set the random seed for fixed random decisions
if ~isempty(I.seed)
    ResetRandStream2(I.seed);
end

% turn integer into probability vector
if isscalar(partition_fractions)
    partition_fractions = ones(1, partition_fractions) / partition_fractions;
end

% unique labels, sort by frequency
unique_labels = unique(labels);
n_unique_labels = length(unique_labels);
n_instances_per_label = nan(1, n_unique_labels);
for i = 1:n_unique_labels
    n_instances_per_label(i) = sum(ismember(labels, unique_labels(i)));
end
[~, xi] = sort(n_instances_per_label, 'ascend');
unique_labels = unique_labels(xi);
clear xi;

n_labels = length(labels);
n_partitions = length(partition_fractions);
partition_index = nan(n_labels,1);
n_total_samples_per_partion = zeros(1, n_partitions);
for i = 1:n_unique_labels

    % indices for this label
    xi = find(ismember(labels, unique_labels(i)));

    % shuffle the indices
    if I.shuffle
        xi = xi(randperm(length(xi)));
    end
    
    % number of samples in each partition
    n_samples_per_partition = length(xi)*partition_fractions;
    n_samples_per_partition = floor(n_samples_per_partition);
    n_samples_to_add = length(xi) - sum(n_samples_per_partition);
    [~,zi] = sort(n_total_samples_per_partion, 'ascend');
    n_samples_per_partition(zi(1:n_samples_to_add)) = n_samples_per_partition(zi(1:n_samples_to_add))+1;
    assert(sum(n_samples_per_partition)==length(xi));
    
    for j = 1:n_partitions

        yi = (1:n_samples_per_partition(j))+sum(n_samples_per_partition(1:j-1)); %np.int32(np.arange(start_ind, end_ind))
        
        % select indices
        partition_index(xi(yi)) = j;
        n_total_samples_per_partion(j) = n_total_samples_per_partion(j) + n_samples_per_partition(j);
        
    end
end