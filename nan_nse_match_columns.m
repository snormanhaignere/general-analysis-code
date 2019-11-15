function C = nan_nse_match_columns(A,B)

% Computes the nse between corresponding columns, excluding NaN values
% 
% 2019-04-23: Created by Sam NH

C = nanfunc_match_columns(@normalized_squared_error, A, B);