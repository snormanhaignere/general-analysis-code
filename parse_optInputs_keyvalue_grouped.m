function [I, C, C_value, allkeys, paramstring] = parse_optInputs_keyvalue_grouped(optargs, I, varargin)

% Wrapper for parse_optInputs_keyvalue for sets of grouped parameters.
% 
% 2019-12-10: Created Sam NH

clear P;
P.empty_means_unspecified = false;
P.always_include = {};
P.always_exclude = {};
P.maxlen = 100;
P.delimiter = '/';
P = parse_optInputs_keyvalue(varargin, P);
C = cell(size(I));
C_value = cell(size(I));
allkeys = cell(size(I));
paramstring = cell(size(I));
for i = 1:length(I)
    if isempty(P.always_include)
        always_include = {};
    else
        always_include = P.always_include{i};
    end
    if isempty(P.always_exclude)
        always_exclude = {};
    else
        always_exclude = P.always_exclude{i};
    end
    [I{i}, C{i}, C_value{i}, allkeys{i}, paramstring{i}] = ...
        parse_optInputs_keyvalue(optargs, I{i}, ...
        'ignore_bad_keys', true, ...
        'always_include', always_include, ...
        'always_exclude', always_exclude, ...
        'empty_means_unspecified', P.empty_means_unspecified, ...
        'maxlen', P.maxlen, 'delimiter', P.delimiter);
end

% check the keys map onto one of the parameters
all_params = {};
for i = 1:length(I)
    all_params = cat(1, all_params, fieldnames(I{i}));
end
for i = 1:length(allkeys{1})
    if ~ismember(allkeys{1}(i), all_params)
        error('%s is not an optional parameter', allkeys{1}{i});
    end
end