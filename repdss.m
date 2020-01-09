function Udss = repdss(D, varargin)

% DSS based on enhancing repetitions
% 
% 2019-12-19: Created, Sam NH

I.K = NaN;
I = parse_optInputs_keyvalue(varargin, I);

[n_smps, n_channels, n_reps] = size(D);

% move channel to last dimension
D = permute(D, [1, 3, 2]);

% unwrap repetition dimension
Du = reshape(D, n_smps*n_reps, n_channels);

% get whitened data
[U, ~, ~] = svd(Du, 'econ');
if ~isnan(I.K)
    U = U(:,1:I.K);
    n_channels = I.K;
end

% average whitened data and recompute PCs
Um = squeeze_dims(mean(reshape(U, [n_smps, n_reps, n_channels]),2),2);
[Udss, ~, ~] = svd(Um, 'econ');

