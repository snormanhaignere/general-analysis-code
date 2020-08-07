function rgb = saturate_color(rgb, satval, varargin)

clear I;
I.type = 'relative';
I = parse_optInputs_keyvalue(varargin, I);
rgb = hsv_ops(rgb, 2, satval, I.type);