function str = mytimestamp

t = clock;
str = '';
for i = 1:6
    if i < 6
        str = [str sprintf('%.0f-', t(i))]; %#ok<AGROW>
    else
        str = [str sprintf('%.3f', t(i))]; %#ok<AGROW>
    end
end


