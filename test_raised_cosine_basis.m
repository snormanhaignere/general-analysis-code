% Illustrates how to use raised_cosine_basis.m

% period of 1 second
N = 2000;
sr = 1000;
win_size_sec = 1;
hop_frac = 0.25;
valid = true;
y = raised_cosine_basis(N,sr,win_size_sec,hop_frac,...
    'plot',true,'valid',valid);

