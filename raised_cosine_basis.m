function y = raised_cosine_basis(N, sr, win_size_sec, hop_frac, varargin)

% Returns a raise cosine basis with a flat sum
% 
% 2019-10-09: Created, Sam NH
% 
% 2019-10-10: Modified, Sam NH

I.plot = false;
I.shift_index = NaN;
I.return_nshifts = false;
I.valid = false;
I = parse_optInputs_keyvalue(varargin, I);

t = (0:N-1)/sr;
fc = 1/win_size_sec;
hop_sec = hop_frac*win_size_sec;

if I.valid
    hop_adjustment = win_size_sec/2;
else
    hop_adjustment = win_size_sec/2 - (win_size_sec-hop_sec);
end
shifts = hop_adjustment:hop_sec:ceil((N/sr-hop_adjustment)/hop_sec)*hop_sec;
if I.return_nshifts
    y = length(shifts);
    return;
end
if ~isnan(I.shift_index)
    shifts = shifts(I.shift_index);
end
n_shifts = length(shifts);
y = zeros(N,n_shifts);
for i = 1:n_shifts
    t_shift = t-shifts(i);
    xi = ge_tol(t_shift, -win_size_sec/2) & le_tol(t_shift, win_size_sec/2);
    y(xi,i) = cos(t_shift(xi)*2*pi*fc)/2+0.5;
end

if I.plot
    figure;
    plot(t, y);
    hold on;
    plot(t, sum(y,2), 'k--', 'LineWidth', 2);
end
