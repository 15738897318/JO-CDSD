%% ��Ŀ���û���վ�صĻ��֣�ͬʱҲ����������û��Ļ�վ�ػ��ַ��ԣ�ͨ�������ʽ������
% ����;�ŵ�ϵ��
% ����������û��Ļ�վ�ػ��֣��Լ�Ŀ���û����Ÿ����
function [clus_u, sinr_u] = opti_cluster(ch)
    %% ����ȫ�ֱ���
    global N_agents;
    global B;
    global A;
    global typical_user;
    global clus_all;

    % ����������ʼ��
    max_sinr = 0;
    clus = zeros(1,N_agents);
    ori_solu = clus_all(typical_user,:);
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
    clus_u = clus;
    clus_all(typical_user,:) = ori_solu;
end
