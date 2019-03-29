function s = mytostring(x, varargin)

% Relatively general function for converting an input to a string that
% represents its content. Used by struct2string.
% 
% -- Example --
% 
% mytostring({[2.33,3,4], 1, 'test'})

% 2018-08-20: Created, Sam NH
% 2018-09-15: Made delimiter optional argument, Sam NH

P.delimiter = '-';
P = parse_optInputs_keyvalue(varargin, P);

if ischar(x)
    s = x;
elseif (isnumeric(x) || islogical(x)) && (isscalar(x) || isvector(x))
    s = regexprep(num2str(x), '[ ]*', '-');
elseif iscell(x)
    s = '';
    for i = 1:length(x)
        if i == 1
            s = mytostring(x{1});
        else
            s = [s P.delimiter mytostring(x{i})]; %#ok<AGROW>
        end
    end
else
    error('No valid type');
end