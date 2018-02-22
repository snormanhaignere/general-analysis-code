function Y = resample_and_window(X, orig_win, orig_sr, targ_win, targ_sr)

% Resamples a signal X, sampled within a given time window (orig_win(1) -
% orig_win(2)) at a given sampling rate (orig_sr) to a new target window
% (targ_win) and sampling rate (targ_sr). The signal can be a multidimensional
% array, in which case only resampling and windowing is performed over the first
% (row) dimension. The target window must be contained within the original
% window. Missing NaN values are filled in via interpolation.
%
% This function relies on resample, resample_ndarray, and interp1.
%
% -- Simple Example --
%
% % create a signal
% orig_sr = 100;
% orig_win = [0, orig_sr]/orig_sr;
% X = randn(orig_sr+1, 1);
%
% % add some NaN values to demonstrate filling in
% X(rand(size(X)) < 0.2) = NaN;
%
% % downsample
% targ_sr = 50;
% targ_win = [0.25 0.75];
% X_resamp = resample_and_window(X, orig_win, orig_sr, targ_win, targ_sr);
%
% % plot
% figure;
% hold on;
% plot(orig_win(1) : 1/orig_sr : orig_win(2), X);
% plot(targ_win(1) : 1/targ_sr : targ_win(2), X_resamp);
%
% 2017-06-06: Created, Sam NH

% unwrap all but first dimension
X_dims = size(X);
X = reshape(X, X_dims(1), prod(X_dims(2:end)));

% interpolation anchor points
xi = orig_win(1) : 1/orig_sr : orig_win(2);
yi = targ_win(1) : 1/orig_sr : targ_win(2);
assert(yi(1) >= xi(1) && yi(end) <= xi(end));

% initialize resampled matrix
Y = nan([length(yi), size(X,2)]);

% interpolate columns without NaN
try
    no_NaNs = all(~isnan(X));
    if sum(no_NaNs)>0
        Y(:,no_NaNs) = interp1(xi', X(:,no_NaNs), yi', 'pchip');
    end
catch
    keyboard
end

% interpolate columns with NaNs
for zi = find(~no_NaNs)
    NaN_rows = isnan(X(:,zi));
    if ~all(NaN_rows)
        Y(:,zi) = myinterp1(xi(~NaN_rows)', X(~NaN_rows, zi), yi', 'pchip');
    end
end
assert(all(all(~isnan(Y)) | all(isnan(Y))));

% resample
Y = resample_ndarray(Y, targ_sr, orig_sr);

% reshape to nd-array
Y = reshape(Y, [size(Y,1), X_dims(2:end)]);
