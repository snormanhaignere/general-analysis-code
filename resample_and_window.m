function X = resample_and_window(X, orig_win, orig_sr, targ_win, targ_sr)

% Resamples a signal X, sampled within a given time window (orig_win(1) -
% orig_win(2)) at a given sampling rate (orig_sr) to a new target window
% (targ_win) and sampling rate (targ_sr). The signal can be a multidimensional
% array, in which case only resampling and windowing is performed over the first
% (row) dimension. The target window must be contained within the original
% window.
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

% interpolate to target window at original sampling rate
xi = orig_win(1) : 1/orig_sr : orig_win(2);
yi = targ_win(1) : 1/orig_sr : targ_win(2);
assert(yi(1) >= xi(1) && yi(end) <= xi(end));
X = interp1(xi', X, yi', 'pchip');

% downsample to desired sampling rate
X = resample_ndarray(X, targ_sr, orig_sr);