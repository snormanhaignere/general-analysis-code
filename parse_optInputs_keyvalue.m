function [I, C, C_value] = parse_optInputs_keyvalue(optargs, I, varargin)

% Parse optional inputs specified as a key-value pair. Key must be a string.
% 
% I is an optional input argument with a structure containing the default values
% of the parameters, which are overwritten by the optional arguments. If I is
% specified then every key must match one of the fields of the structure I. 
% 
% C is a structure that tells you whether each field has been modified.
% 
% C_value has the value for all of the fields that have been changed
% 
% -- Example --
% 
% % parse key value pairs
% optargs = {'key1', {1 2 3}, 'key2', 1:3, 'key3', 'abc'};
% [I, C] = parse_optInputs_keyvalue(optargs)
% 
% % specifying default values
% I.key1 = {1 2 3};
% I.key2 = 1:3;
% I.key3 = 'abc';
% [I, C] = parse_optInputs_keyvalue({'key1', {4,5,6}}, I)
% 
% % empty lists mean unspecified
% I.key1 = {1 2 3};
% I.key2 = 1:3;
% I.key3 = 'abc';
% [I, C] = parse_optInputs_keyvalue({'key1', {}}, I, 'empty_means_unspecified', true)
% 
% % use defaults to catch a spelling mistake
% I = parse_optInputs_keyvalue({'keys1', {4,5,6}}, I)

% 2016-08-27: Created, Sam NH
% 
% 2018-05-23: Added functionality to detect if an optional input has
% changed. Added functionality to have empty lists mean unspecified values.
% 
% 2019-01-18: Added C_value, useful for creating strings of parameters that
% have changed

P.empty_means_unspecified = false;
if ~isempty(varargin)
    P = parse_optInputs_keyvalue(varargin, P);
    if isempty(P.empty_means_unspecified)
        P.empty_means_unspecified = false;
    end
end

% should be an event number of arguments
n_optargs = length(optargs);
if mod(n_optargs,2)~=0
    error('There are not an even number of optional inputs');
end

% initialize with empty structure if not specified
if nargin < 2
    I = struct;
else % extract list of possible keys from the values of I if specified
    possible_keys = fieldnames(I);
end

% check keys are not repeated
if length(unique(optargs(1:2:n_optargs))) ~= length(optargs(1:2:n_optargs))
    error('Duplicate keys');
end

% assume keys are not changed unless they are
if exist('possible_keys', 'var')
    for i = 1:length(possible_keys)
        C.(possible_keys{i}) = false;
    end
end

C_value = struct;

% immediately return if there are no optional arguments
if n_optargs == 0
    return;
end

% assign keys and values
i_key = 1:2:n_optargs;
i_val = 2:2:n_optargs;
for j = 1:n_optargs/2
    key = optargs{i_key(j)};
    value = optargs{i_val(j)};

    % check key is a string
    if ~ischar(key)
        error('Optional arguments not formatted propertly\nAll keys must be strings\n');
    end
    
    % check key is one of the possible keys, and if it has the same type class
    % type
    if exist('possible_keys', 'var')
        if ~any(strcmp(key, possible_keys))
            error(['Optional arguments not formatted propertly\n' ...
                '''%s'' not a valid key\n'], key);
        end
        
        if ~isequal(class(I.(key)), class(value))
            allowed_class_swaps = {'double', 'int32'};
            allowed_swap = false;
            for k = 1:size(allowed_class_swaps,1)
                if P.empty_means_unspecified && isempty(value)
                    allowed_swap = true;
                end
                if strcmp(class(I.(key)), allowed_class_swaps{k,1}) ...
                        && strcmp(class(value), allowed_class_swaps{k,2})
                    allowed_swap = true;
                end
                if strcmp(class(value), allowed_class_swaps{k,1}) ...
                        && strcmp(class(I.(key)), allowed_class_swaps{k,2})
                    allowed_swap = true;
                end                
            end
            if ~allowed_swap
                error(['Optional arguments not formatted propertly\n' ...
                    'Value of ''%s'' should be of type %s\n'], key, class(I.(key)));
            end
        end
    end
        
    % assign
    if P.empty_means_unspecified && isempty(value)
        % do nothing
    else
        if ~isfield(I, key) || ~isequal(I.(key), value)
            I.(key) = value;
            C.(key) = true;
            C_value.(key) = I.(key);
        end
    end
    
end

