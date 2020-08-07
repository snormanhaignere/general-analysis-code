function AB = unravel_matmul(A, B, split_dim_A, split_dim_B)

% split into the two dimension
dA = size(A);
dB = size(B);
dA1 = dA(1:split_dim_A-1);
dA2 = dA(split_dim_A:end);
dB1 = dB(1:split_dim_B-1);
dB2 = dB(split_dim_B:end);

% unwrap multiple rewrap
AB = reshape(reshape(A, prod(dA1), prod(dA2)) * reshape(B, prod(dB1), prod(dB2)), [dA1, dB2]);
