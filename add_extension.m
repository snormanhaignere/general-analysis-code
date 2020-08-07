function [fname_with_ext, ext] = add_extension(fname)

% Takes in a file name and returns the file with the extension added

[parent_directory, name] = fileparts(fname);
fname_with_ext = mydir(parent_directory, [name '.*']);
assert(length(fname_with_ext)==1);
fname_with_ext = [parent_directory '/' fname_with_ext{1}];
[~, ~, ext] = fileparts(fname_with_ext);