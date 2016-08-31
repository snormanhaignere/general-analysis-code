
clc;
X = randn(1000,4);
Y = randn(1000,4);
d = jsdiv(X,Y,'eps_factor',1e-6)