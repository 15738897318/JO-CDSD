function [C, X] = block_descent(optimal_theta)
%block_descent �Ա��㷨�����½���
%   ����Lyapunov���̶�������վ�ϵĽ⣬��һ����վ�Ľ⣬����ȡ��С��ֵ
global K;
global N_agents;
global clus_all;
global typical_user;
global B;
global A;

% initialize
cur_C = zeros(1,N_agents);
X = zeros(K, N_agents);
min_fval = inf;
error_tol = 1e-3;
iter_max = 2000;
error = inf;
iter = 1;
last_min_fval = 0;
while error > error_tol && iter < iter_max
    ind_bs = randi(N_agents);
    cur_C(1,ind_bs) = 0;
    % �ж��Ƿ������վ�ش�СԼ�������ȫΪ0�򲻼���
    if sum(cur_C,2) ~= 0
        [X_ind_bs0, fval0] = solve_block_X(cur_C, ind_bs, X, optimal_theta);
    else
        X_ind_bs0 = zeros(K, 1);
        fval0 = inf;
    end
    cur_C(1,ind_bs) = 1;
    clus_all(typical_user,:) = cur_C;
    % �ж��Ƿ��������Լ����ֻ������Լ���Ľ�Żᱻ��¼
    if sum(cur_C,2) <= B && max(sum(clus_all,1)) <= A
        [X_ind_bs1, fval1] = solve_block_X(cur_C, ind_bs, X, optimal_theta);
    else
        X_ind_bs1 = zeros(K, 1);
        fval1 = inf;
    end
    clus_all(typical_user,:) = zeros(1, N_agents);
    if fval0 < fval1
        cur_fval = fval0;
        cur_C(1,ind_bs) = 0;
        cur_X_solu = X_ind_bs0;
    else
        cur_fval = fval1;
        cur_C(1,ind_bs) = 1;
        cur_X_solu = X_ind_bs1;
    end
    if min_fval > cur_fval
        min_fval = cur_fval;
        C = cur_C;
        X(:,ind_bs) = cur_X_solu;
        error = ((min_fval - last_min_fval) / last_min_fval)^2;
        last_min_fval = min_fval;
    end
    iter = iter + 1;
end
end

