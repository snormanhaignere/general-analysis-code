function C = fastcorr(A,B)
% function C = fastcorr(A,B)
% 
% Computes the correlation coefficient between corresponding column vectors 
% in matrices A and B more quickly than the built-in matlab function. 
% Equivalent to diag(corr(A,B))';
% 
% Matrices A and B must have the same dimensions.
% 
% Example:
% X = rand(100,1000);
% Y = rand(100,1000);
% tic;
% r1 = fastcorr(X,Y);
% toc;
% tic;
% r2 = diag(corr(X,Y))';
% toc;
% plot(r1,r2);
% 
% Downloaded from the matlab file exchange.
% Commented by Sam Norman-Haignere on 12/26/14

An=bsxfun(@minus,A,mean(A,1)); %%% zero-mean
Bn=bsxfun(@minus,B,mean(B,1)); %%% zero-mean
An=bsxfun(@times,An,1./sqrt(sum(An.^2,1))); %% L2-normalization
Bn=bsxfun(@times,Bn,1./sqrt(sum(Bn.^2,1))); %% L2-normalization
C=sum(An.*Bn,1); %% correlation