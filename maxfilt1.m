function Y = maxfilt1(X,win_size)

N = size(X,1);

if mod(win_size,2)==0
    win_size = wiXn_size-1;
end

Y = nan(size(X));
for i = 1:N
    
    w = (win_size-1)/2;
    xi = i-w:i+w;
    xi = max(xi,1);
    xi = min(xi,N);
    xi = unique(xi);
    
    Y(i,:) = max(X(xi,:));
    
end



