function C = nanfastcorr(A,B)

% Wrapper for fastcorr but excludes NaN values
% 
% 2016-10-28: Created, Sam NH
% 
% 2019-11-18: Made faster

% assert(all(size(A) == size(B)));
% c = nan(1,size(A,2));
% for i = 1:size(A,2)
%     xi = ~isnan(A(:,i)) & ~isnan(B(:,i));
%     c(i) = fastcorr(A(xi,i), B(xi,i));
% end

assert(all(size(A) == size(B)));
xi = isnan(A) | isnan(B);
A(xi) = NaN;
B(xi) = NaN;
An=bsxfun(@minus,A,nanmean(A,1)); %%% zero-mean
Bn=bsxfun(@minus,B,nanmean(B,1)); %%% zero-mean
An=bsxfun(@times,An,1./sqrt(nansum(An.^2,1))); %% L2-normalization
Bn=bsxfun(@times,Bn,1./sqrt(nansum(Bn.^2,1))); %% L2-normalization
C=nansum(An.*Bn,1); %% correlation
