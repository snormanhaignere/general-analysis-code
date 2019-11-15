function y = mod1index(x, c)

% Idiotically simple function to handle the fact
% that matlab is not zero-indexed: mod(x-1,c)+1
% 
% % Compare:
% 
% mod1index(1:9, 3)
% 
% % With:
% 
% mod(1:9, 3)

y = mod(x-1,c)+1;