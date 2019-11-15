function[y, win_size_sec, hop_sec] = rec_hann_basis(N, sr, win_size_sec, hop_frac, varargin)

% Returns a rectangular basis with hanning windowed edges
% 
% 2019-10-10: Created, Sam NH

I.plot = false;
I.shift_index = NaN;
I.return_nshifts = false;
I.hann_frac = hop_frac;
I.valid = false;
I = parse_optInputs_keyvalue(varargin, I);

% window size, force even number of samples
% to illustrate: x = 0:0.1:10; y = round(x/2)*2; plot(x,y); OLD: x = 0:0.1:10; y = floor(x/2)*2+1; plot(x,y)
win_size_smp = round(win_size_sec*sr/2)*2;
win_size_sec = win_size_smp/sr;
hop_smp = round(win_size_smp*hop_frac);
hop_sec = hop_smp/sr;

if I.valid
    shifts_smp = 0:hop_smp:(N-1)-(win_size_smp-1);
else
    shifts_smp = 0-(win_size_smp-hop_smp):hop_smp:(N-1)-(win_size_smp-1)+(win_size_smp-hop_smp);
end
if I.return_nshifts
    y = length(shifts_smp);
    return;
end
if ~isnan(I.shift_index)
    shifts_smp = shifts_smp(I.shift_index);
end
n_shifts = length(shifts_smp);
y = zeros(N,n_shifts);
if I.hann_frac > 0
    win = ramp_hann(ones(win_size_smp,1), win_size_sec*I.hann_frac, sr);
else
    win = ones(win_size_smp,1);
end
for i = 1:n_shifts
    win_tps = (0:(win_size_smp-1));
    win_tps_shifted = win_tps + shifts_smp(i);
    xi = ge_tol(win_tps_shifted, 0) & le_tol(win_tps_shifted, N-1);
    y(win_tps_shifted(xi)+1,i) = win(xi);
end

if I.plot
    figure;
    t = (0:N-1)/sr;
    plot(t, y);
    hold on;
    plot(t, sum(y,2), 'k--', 'LineWidth', 2);
end
