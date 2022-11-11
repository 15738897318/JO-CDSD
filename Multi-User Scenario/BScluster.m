%% ��Ŀ���û���վ�صĻ��֣�ͬʱҲ����������û��Ļ�վ�ػ��ַ��ԣ�ͨ�������ʽ������
% ����;�ŵ�ϵ��
% ����������û��Ļ�վ�ػ��֣��Լ�Ŀ���û����Ÿ����
function [clus_all, sinr_u] = BScluster(ch)
    %% ����ȫ�ֱ���
    global N_agents;
    global B;
    global A;
    global typical_user;
    %% b&b
    clus = zeros(1,N_agents); % ��ʼ��������

    % ���������û��ķִ�
    % ����ÿ����վ�ĸ�������������л�վȫ�����أ���Ҫ��������
    overload = true;
    while overload
        clus_all = clus_state();
        overload = false;
        clus_all(typical_user,:) = clus;
        load = sum(clus_all);
        cnt = 0;
        for bs=1:N_agents
            if load(bs)>A
                overload = true;
                continue;
            end
            if load(bs)==A
                cnt = cnt+1;
            end
        end
        if cnt==N_agents
            overload = true;
        end
    end
    
    % ����������ʼ��
    max_sinr = 0;
    clus = zeros(1,N_agents);
    for ind = 1:1023
        node_solu = dec2bin(ind)-'0';
        if size(node_solu,2) < N_agents
            less_len = N_agents - size(node_solu,2);
            prex = zeros(1,less_len);
            node_solu = [prex, node_solu];
        end
        clus_all(typical_user,:) = node_solu;
        if sum(node_solu) > B || max(sum(clus_all,1)) > A
            continue;
        end
        cur_sinr = calcu_sinr(clus_all, node_solu, ch);
        if max_sinr < cur_sinr
            max_sinr = cur_sinr;
            clus = node_solu;
        end
    end
    sinr_u = max_sinr;
    clus_all(typical_user,:) = clus;
end
