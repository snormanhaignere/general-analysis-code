function e=sum_sq_e(x,t,m)
r=x(1);
t0=x(2);
K = x(3);
h=K./(1+exp(-r*(t-t0)));
e=m'*m-(h'*m)^2/(h'*h);