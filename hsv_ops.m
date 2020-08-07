function rgb = hsv_ops(rgb, dim, val, type)

assert(abs(val)<=1);
for i = 1:size(rgb)
    hsv = rgb2hsv(rgb(i,:));
    switch type
        case 'abs'
            hsv(dim) = val;
        case 'relative'
            if val > 0
                hsv(dim) = hsv(dim) + abs(val)*(1-hsv(dim));
            else
                hsv(dim) = hsv(dim) - abs(val)*hsv(dim);
            end
        otherwise
            error('No matching type')
    end
    rgb(i,:) = hsv2rgb(hsv);
end