function in_file = isvar_in_mfile(fname, v)

% Simple function to check if a variable exists in a MAT file
% 
% Code taken from here:
% 
% https://www.mathworks.com/matlabcentral/answers/279218-is-there-a-way-to-find-if-a-variable-exists-inside-a-mat-file
% 
% 2019-11-15: Created, Sam NH

variableInfo = who('-file', fname);
in_file = ismember(v, variableInfo);
