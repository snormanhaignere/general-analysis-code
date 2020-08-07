function bool = isvar_in_MAT_file(fname, varname)

if exist(fname, 'file')
    variableInfo = who('-file', fname);
    bool = ismember(varname, variableInfo);
else
    bool = false;
end
