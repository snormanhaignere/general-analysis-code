function X = mean_squeeze_dims(X, dims)

X = squeeze_dims(mean_dims(X,dims),dims);