function partition_index = partition_within_labels(labels, partition_fractions, varargin)

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

I.seed = [];
I = parse_optInputs_keyvalue(varargin, I);

% check vector
assert(isvector(labels));

% optionally set the random seed for fixed random decisions
if ~isempty(I.seed)
    ResetRandStream2(I.seed);
end

n_labels = length(labels);
n_unique_labels = length(unique(labels));
n_partitions = length(partition_fractions);
partition_index = nan(n_labels,1);
for i = 1:n_unique_labels

    % indices for this label
    xi = find(labels == i);

    % shuffle the indices
    xi = Shuffle(xi);

    count = 0;
    for j = 1:n_partitions

        % indices for this partition (relative to the indices for this label)
        start_ind = count+1;
        if j == n_partitions
            end_ind = length(xi);
        else
            end_ind = count + round(partition_fractions(j)*length(xi));
        end
        yi = (start_ind:end_ind); %np.int32(np.arange(start_ind, end_ind))

        % select indices
        partition_index(xi(yi)) = j;

        % update count
        count = count + length(yi);
    end
end