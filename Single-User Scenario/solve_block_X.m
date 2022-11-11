function [solu, val] = solve_block_X(clus, ind_bs, X_all)
%solve_block_X ��⵱ǰ��վ�ϵĲ������
global K;

%% ��⵱ǰ�ִ��µ��Ż�����
X_init = zeros(K,1);
VLB = zeros(K,1);
VUB = ones(K,1);
options = optimoptions('fmincon','MaxIter',100000,'MaxFunEvals',100000);
[solu, val] = fmincon(@(X) funBlock(X, X_all, ind_bs, clus),...
    X_init,[],[],[],[],VLB,VUB,@(X) consBlock(X, X_all, ind_bs, clus), options);
end

