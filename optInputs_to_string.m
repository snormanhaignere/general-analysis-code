function str = optInputs_to_string(I, C_value, always_include, always_exclude, varargin)

% Takes two of the outputs of parse_optInputs_keyvalue
% and turns them into a string used to save the results of an analysis
% 
% By default, only variables that are changed are included in the string,
% unless that variable is included in the cell array "always_include"
% 
% Variables can be excluded even if they are changed by specifying them in
% "always_exclude"
% 
% 2019-06-11: Created by Sam NH
% 
% -- Example --
% 
% I.a = 'TCI';
% I.b = [1,2,3];
% I.c = {'hello','world'};
% varargin = {'a', 'quilting', 'c', {'goodbye','world'}};
% [I, ~, C_value] = parse_optInputs_keyvalue(varargin, I);
% always_include = {'b'};
% always_exclude = {'a'};
% str = optInputs_to_string(I, C_value, always_include, always_exclude)

P.maxlen = 100;
P.delimiter = '/';
P = parse_optInputs_keyvalue(varargin, P);

% check there is no overlap between fields to include and exclude
overlapping_fields = intersect(always_include, always_exclude);
if ~isempty(overlapping_fields)
    str = '';
    for i = 1:length(overlapping_fields)
        str = [str, sprintf('%s\n',overlapping_fields{i})]; %#ok<AGROW>
    end
    error('The following fields are present in both always_include and always_exclude:\n%s', str);
end

% remove fields to always exclude from string
for i = 1:length(always_exclude)
    if ~(isfield(I, always_exclude{i}))
        error('%s cannot be excluded because it is not a possible field', always_exclude{i});
    end
    I = rmfield(I, always_exclude{i});
    if isfield(C_value, always_exclude{i})
        C_value = rmfield(C_value, always_exclude{i});
    end
end

% include fields that should always be included
clear Z;
Z = struct;
for i = 1:length(always_include)
    if ~isfield(I, always_include{i})
        error('%s cannot be always included because it is not a possible field', always_include{i});
    end
    Z.(always_include{i}) = I.(always_include{i});
end

% include additional fields that have been changed
f = fieldnames(C_value);
for i = 1:length(f)
    if ~any(ismember(always_include, f(i)))
        Z.(f{i}) = C_value.(f{i});
    end
end
    
% convert to string
str = struct2string(Z, 'maxlen', 100, 'delimiter', P.delimiter);