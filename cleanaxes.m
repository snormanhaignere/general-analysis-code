function cleanaxes(axh, varargin)

clear I;
I.ticklength = 0.02;
I.tickwidth = 2;
I.notick = false;
I = parse_optInputs_keyvalue(varargin, I);

box off;
if I.notick
    set(axh, 'XTick', [], 'YTick', []);
else
    set(axh, 'TickLength', [I.ticklength, 0], 'linewidth', I.tickwidth);
end
set(axh, 'XTickLabel', [], 'YTickLabel', []);
xlabel(''); ylabel('');
