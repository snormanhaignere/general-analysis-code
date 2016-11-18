function yi = myinterp1(x,y,xi,varargin)

yi = interp1(x,y,xi,varargin{:});
yi(xi < min(x)) = y(x == min(x));
yi(xi > max(x)) = y(x == max(x));