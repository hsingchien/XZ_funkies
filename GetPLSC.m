function [PLS1, PLS2, USV] = GetPLSC(N1,N2)
% Get PLSCs, N1, N2, t x n, make sure same length
zN1 = zscore(N1);
zN2 = zscore(N2);

cov_mat = zN1'*zN2;
[U,S,V] = svd(cov_mat);
PLS1 = zN1 * U;
PLS2 = zN2 * V;
USV = struct('U',U, 'S',S, 'V',V);

end