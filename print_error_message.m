function print_error_message(ME)

% Prints an error message with the function name, line and nature of the error
% that occured. Useful in combination with try/catch loops. See example below.
% 
% -- Example --
% 
% try
%     x = [3 4 5] + [3 4];
% catch ME
%     print_error_message(ME)
% end
% 
% 2016-01-18: Created, Sam NH

errorMessage = sprintf(...
    'Error in function %s() at line %d.\n\nError Message:\n%s', ...
    ME.stack(1).name, ME.stack(1).line, ME.message);
fprintf('%s\n', errorMessage);