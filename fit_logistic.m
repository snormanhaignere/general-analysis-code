function [S, Yp, logf] = fit_logistic(x,Y,varargin)

% logf = @(x,k,m)(1./(1+exp(-k.*(x-m))));
% x = randn(1000,1);
% k = [3, 1]';
% m = [0, 1]';
% s = [2, -3]';
% b = [1, 2]';
% Y = nan(1000,2);
% for i = 1:2
%     Y(:,i) = s(i)*logf(x, k(i), m(i))+b(i);
% end
% 
% [S,Yp] = fit_logistic(x, Y, 'kr', [0.1, 10], 'mr', [-5, 5]);
% k
% S.best_k
% m
% S.best_m
% s
% S.best_s
% b
% S.best_b
% 
% figure;
% h1 = plot(x,[Y(:,1),Yp(:,1)], 'o');
% hold on;
% h2 = plot(x,[Y(:,2),Yp(:,2)], 'o');
% legend([h1;h2], {'Data1','Pred1','Data2', 'Pred2'});

logf = @(x,k,m)(1./(1+exp(-k.*(x-m))));
[N,P] = size(Y);

clear I;
I.kr = [0.1, 10];
I.kn = 100;
I.mr = [-5, 5];
I.mn = 100;
I.pred = true;
I = parse_optInputs_keyvalue(varargin,I);

% fit
clear S;
S.k = 2.^(linspace(log2(I.kr(1)), log2(I.kr(2)), I.kn));
S.m = linspace(I.mr(1), I.mr(2), I.mn);
S.s = nan(I.kn, I.mn, P);
S.b = nan(I.kn, I.mn, P);
S.mse = nan(I.kn, I.mn, P);
for i = 1:I.kn
    for j = 1:I.mn
        lp = logf(x, S.k(i), S.m(j));
        F = [ones(N,1), lp];
        W = pinv(F)*Y;
        Yp = F*W;
        S.mse(i,j,:) = mean((Yp - Y).^2);
        S.b(i,j,:) = W(1,:);
        S.s(i,j,:) = W(2,:);
    end
end
clear F W;

% pick out best parameters
S.best_k = nan(P,1);
S.best_m = nan(P,1);
S.best_s = nan(P,1);
S.best_b = nan(P,1);
for p = 1:P
    [~,~,si] = myminall(S.mse(:,:,p));
    S.best_k(p) = S.k(si{1});
    S.best_m(p) = S.m(si{2});
    S.best_s(p) = S.s(si{1}, si{2}, p);
    S.best_b(p) = S.b(si{1}, si{2}, p);
    
    if si{1}==1 || si{1} == I.kn
        warning('Best solution k=%.4f for column %d on boundary', S.best_k(p), p);
    end
    
    if si{2}==1 || si{2} == I.mn
        warning('Best solution m=%.4f for column %d on boundary', S.best_m(p), p);
    end
end

% prediction
Yp = nan(N,P);
for p = 1:P
    Yp(:,p) = S.best_b(p) + S.best_s(p)*logf(x, S.best_k(p), S.best_m(p));
end
