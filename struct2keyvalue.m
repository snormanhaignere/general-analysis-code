function keyvalue_pairs = struct2keyvalue(S, varargin)

% Converts the fields of a structure into a cell array of key value pairs
% 
% 2019-11-22: Created, Sam NH
% 
% -- Example --
% clear S;
% S.a = 1;
% S.b = 'hi!';
% S.c = {1,2,3};
% struct2keyvalue(S)
% struct2keyvalue(S, 'omit_fields', {'a'})

I.omit_fields = {};
I = parse_optInputs_keyvalue(varargin, I);
f = setdiff(fieldnames(S), I.omit_fields);
n_keyvalue_pairs = length(f);
keyvalue_pairs = cell(1, n_keyvalue_pairs*2);
for i = 1:n_keyvalue_pairs
    keyvalue_pairs{1 + (i-1)*2} = f{i};
    keyvalue_pairs{2 + (i-1)*2} = S.(f{i});
end


