function e=myerror(x,t,m)
r=x(1);
t0=x(2);
h=1./(1+exp(-r*(t-t0)));
e=m'*m-(h'*m)^2/(h'*h);