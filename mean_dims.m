function X = mean_dims(X, dims)

for i = 1:length(dims)
    X = mean(X, dims(i));
end