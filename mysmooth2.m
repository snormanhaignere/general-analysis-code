function Zsmooth = mysmooth2(Z, spacing, fwhm, varargin)

% 2D smoothing function, wrapper for conv2
% 
% 2019-10-02: Created, Sam NH

I.plot_kernel = false;
I.plot_effect = 0;
I = parse_optInputs_keyvalue(varargin, I);

% if no smoothing, return input
if fwhm == 0
    Zsmooth = Z;
    return;
end

% average over everything if smoothing is infinite
if isinf(fwhm)
    dims = size(Z);
    if length(dims)==2
        dims = [dims,1];
    end
    Z = reshape(Z, prod(dims(1:2)), prod(dims(3:end)));
    Zsmooth = repmat(nanmean(Z,1), [size(Z,1), 1]);
    Zsmooth(isnan(Z)) = NaN;
    Zsmooth = reshape(Zsmooth, dims);
    return;
end

% unwrap the 3rd through Nth dimension if present
dims = size(Z);
assert(length(dims)>=2)
if length(dims)>3
    Z = reshape(Z, [dims(1:2), prod(dims(3:end))]);
end

% kernel
fwhm_smp = fwhm/spacing;
sig = fwhm_smp / sqrt(8*log(2));
bins = -round(sig*3):round(sig*3);
[X,Y] = meshgrid(bins,bins);
H = normpdf(sqrt(X.^2 + Y.^2), 0, sig);
H = H/sum(H(:));
if I.plot_kernel
    figure;
    imagesc(H);
end

% apply kernel
Zsmooth = nan(size(Z));
for i = 1:size(Z,3)
    Zsmooth(:,:,i) = conv2_setNaNs_tozero(Z(:,:,i), H);
end
if I.plot_effect>0
    figure;
    subplot(1,2,1);
    imagesc(Z(:,:,I.plot_effect));
    subplot(1,2,2);
    imagesc(Zsmooth(:,:,I.plot_effect));
end

% reshape
Zsmooth = reshape(Zsmooth, dims);