function [N, p] = myhist(x, bin_centers)

assert(isvector(x))
bin_edges = bin_centers - [(bin_centers(2)-bin_centers(1))/2, diff(bin_centers)/2];
bin_edges = [bin_edges, bin_centers(end) + (bin_centers(end)-bin_centers(end-1))/2];
N = histc(x, bin_edges);
N = N(1:end-1);
p = bsxfun(@times, N, 1./sum(N,1));

