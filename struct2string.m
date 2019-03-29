function idstring = struct2string(S, varargin)

% Creates a string the fields / values in the input struct. Useful for
% parameter handling / saving.
%
% 2018-08-20: Created, Sam NH
%
% -- Example --
% clear S;
% S.a = 'doowicky';
% S.b = [pi, 42];
% struct2string(S)
% struct2string(S, 'maxlen', 3)
% struct2string(S, 'maxlen', 3, 'delimiter', '/')
% 
% 2019-01-18: Added include_fields option

P.maxlen = 100;
P.delimiter = '';
P.omit_field = {};
P.include_fields = {};
[P, C] = parse_optInputs_keyvalue(varargin, P);

idstring = {''};

if C.include_fields
    f = intersect(P.include_fields, fieldnames(S));
else
    f = fieldnames(S);
end
for i = 1:length(f)
    omit = ~isempty(P.omit_field) && any(ismember(P.omit_field, f{i}));
    if ~omit
        % break into new cell if length limit exceeded
        if length(idstring{end}) > P.maxlen
            idstring = [idstring, {''}]; %#ok<AGROW>
        end
        
        % add to string
        if isempty(idstring{end})
            idstring{end} = [f{i} '-' mytostring(S.(f{i}))];
        else
            try
                idstring{end} = [idstring{end} '_' f{i} '-' mytostring(S.(f{i}))];
            catch
                keyboard
            end
        end
    end
end

% concatenate cells with delimiter
if ~isempty(P.delimiter)
    s = idstring{1};
    for i = 1:length(idstring)
        if i == 1
            s = idstring{1};
        else
            s = [s P.delimiter idstring{i}]; %#ok<AGROW>
        end
    end
    idstring = s;
end

% return a single string if length equals 1
if iscell(idstring) && length(idstring)==1
    idstring = idstring{1};
end




