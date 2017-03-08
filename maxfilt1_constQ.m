function Y = maxfilt1_constQ(X,win_fac,inds)

N = size(X,1);

if nargin < 3
    inds = 1:N;
end

Y = nan(size(X));
for i = 1:N
    
    w = inds(i)*win_fac;
    w = ceil(w);
    w = w+(mod(w,2)-1);
    w = (w-1)/2
    
    if w >= 1
        
        xi = i-w:i+w;
        xi = max(xi,1);
        xi = min(xi,N);
        xi = unique(xi);
        
        Y(i,:) = max(X(xi,:));
        
    else
        
        Y(i,:) = X(i,:);
        
    end
    
end



