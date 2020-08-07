function rgb = hue_color(rgb, hueval)

hsv = rgb2hsv(rgb);
hsv(1) = hueval;
rgb = hsv2rgb(hsv);