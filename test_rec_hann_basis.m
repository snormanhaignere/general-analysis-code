% Illustrates how to use rec_hann_basis.m
close all;
clc;

% period of 1 second
N = 2000;
sr = 1000;
win_size_sec = 1;
hop_frac = 0.25;
hann_frac = 0;
valid = true;
y = rec_hann_basis(N,sr,win_size_sec,hop_frac,...
    'hann_frac',hann_frac,'plot',true,'valid', valid);