function rgb = lighten_color(rgb, darkval, varargin)

I.type = 'relative';
I = parse_optInputs_keyvalue(varargin, I);
rgb = hsv_ops(rgb, 3, darkval, I.type);