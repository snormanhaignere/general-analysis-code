function file = mkpdir(file)

% Creates a parent directory for a file if it doesn't exist
% 
% 2019-01-22: Created, Sam NH

[d, ~, ~] = fileparts(file);
if ~exist(d, 'dir'); mkdir(d); end