function index = optInputs(argList, argTest)
% index = optInputs(argList, argTest)

index = 0;
for xx = 1:length(argList)
    if isequal(argList{xx}, argTest)
        index = xx;
        return;      
    end
end