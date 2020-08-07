function args = expand_opt_args(I)

% parse into distinct arguments
f = fieldnames(I);
n_fields = length(f);
args = {};
for i = 1:n_fields
    n_params = length(I.(f{i}));
    if i == 1
        args = cell(1, n_params);
        for j = 1:n_params
            if iscell(I.(f{i}))
                args{j} = {f{i}, I.(f{i}){j}};
            else
                args{j} = {f{i}, I.(f{i})(j)};
            end
        end
    else
        new_args = cell(length(args), n_params);
        for k = 1:length(args)
            for j = 1:n_params
                if iscell(I.(f{i}))
                    new_args{k,j} = [args{k}, {f{i}, I.(f{i}){j}}];
                else
                    new_args{k,j} = [args{k}, {f{i}, I.(f{i})(j)}];
                end
            end
        end
        args = new_args(:);
        clear new_args;
    end
end
