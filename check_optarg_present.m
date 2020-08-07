function check_optarg_present(I, optargs)

all_params = {};
for i = 1:length(I)
    all_params = cat(1, all_params, fieldnames(I{i}));
end

optarg_keys = optargs(1:2:end);

% check the keys map onto one of the parameters
for i = 1:length(optarg_keys)
    if ~(ismember(optarg_keys(i), all_params))
        error('%s not found\n', optarg_keys{i});
    end
end