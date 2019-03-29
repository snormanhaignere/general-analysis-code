function Ysmooth = mysmooth(Y, sr, fwhm_ms)

% Smoothes every column of a data matrix by a Gaussian kernel
% 
% 2017-11-24: Created by Sam NHs

if fwhm_ms == 0
    Ysmooth = Y;
    return;
end

% kernel
fwhm_smp = fwhm_ms*sr/1000;
sig = fwhm_smp / sqrt(8*log(2));
x = (-round(sig*3):round(sig*3))';
h = normpdf(x, 0, sig);
h = h/sum(h);

dims = size(Y);
Y = reshape(Y, dims(1), prod(dims(2:end)));
Ysmooth = nan(size(Y));
for i = 1:prod(dims(2:end))
    if ~any(isnan(Y(:,i)))
        Ysmooth(:,i) = myconv(Y(:,i), h, 'causal', false);
    end
end

Ysmooth = reshape(Ysmooth, dims);