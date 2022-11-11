function [clus, cach_policy, feasible_flag] = instant_optimal()
%% ��ٷ�Ѱ�ҵ�ǰʱ϶ÿһ���ִ��µ����Ŵ洢���ԣ��Ƚϵõ�������Ž⡣
global costq_t_instant;
global data_t;
global ch;
global xi;
global V;
global K;
global cost_th;
global N_agents;
global clus_all;
global typical_user;
global B;
global A;
global theta;
global B0_size;

opti_clus = zeros(1,N_agents);
opti_cach_policy = zeros(K,N_agents);
ind = 1;
min_val = inf;
while ind < 1024
    cur_clus = dec2bin(ind)-'0';
    if size(cur_clus,2) < N_agents
        less_len = N_agents - size(cur_clus,2);
        prex = zeros(1,less_len);
        cur_clus = [prex, cur_clus];
    end
    clus_all(typical_user,:) = zeros(1,N_agents);
    if sum(cur_clus) > B || max(sum(clus_all,1) + cur_clus) > A
        ind = ind + 1;
        continue;
    end
    %% ��⵱ǰ�ִ��µ��Ż�����
    delay_ucn = sum(data_t / log2(1 + calcu_sinr(clus_all, cur_clus, ch))) / B0_size;
    func = @(X)costq_t_instant * (cur_clus * (xi' * X)' - cost_th) +...
        V / B0_size * delay_ucn + V * theta; 
    X_init = zeros(K,N_agents);
    VLB = zeros(K,N_agents);
    VUB = ones(K,N_agents);
    options = optimoptions('fmincon','MaxIter',100000,'MaxFunEvals',100000);
    [cur_cach_policy, cur_val, exitflag] = fmincon(func,...
        X_init,[],[],[],[],VLB,VUB,@(X) consPrimal(X, cur_clus), options);
    if exitflag <= 0  %���ⲻ���У�������ǰ�ִ�
        ind = ind + 1;
        continue;
    end
    if min_val > cur_val
        min_val = cur_val;
        opti_clus = cur_clus;
        opti_cach_policy = cur_cach_policy;
    end
    ind = ind + 1;
end
if min_val < inf
    feasible_flag = 1;
    clus = opti_clus;
    cach_policy = opti_cach_policy;
else 
    feasible_flag = 0;
    clus = [];
    cach_policy = [];
end
end