%% ���ݷִ�����Լ���ǰ�ŵ�����tipical�û����Ÿ����
function sinr_u=calcu_sinr(clus_all, clus_u, ch)
global N_agents;
global A;
global P;
global U;
global typical_user;

clus_all(typical_user,:) = clus_u;
if clus_all(typical_user,:)==zeros(1,N_agents)
    sinr_u = 0;
    return;
end
clus_size = sum(clus_all(typical_user,:));
I = eye(A*clus_size, A*clus_size);
% ���G(phi_u,omega_u)����ά��Ϊ|phi_u|*A,|omega_u|-1���������û�u
G_u = ch;
for bs=N_agents:-1:1
    if clus_all(typical_user,bs)==0
        G_u((bs-1)*A+1:bs*A,:) = [];
    end
end
for user=U:-1:1
    if sum(clus_all(user,:).*clus_all(typical_user,:))==0 || user==typical_user
        G_u(:,user) = [];
    end
end
% ��g_u^u=g_u(typical_user)��ά��Ϊ|phi_u|*A,U
g_u = ch;
for bs=N_agents:-1:1
    if clus_all(typical_user,bs)==0
        g_u((bs-1)*A+1:bs*A,:) = [];
    end
end
% ���û�u�Ĳ�������ʸ��
temp = (I-G_u*pinv(G_u))*g_u(:,typical_user);
beamform_u = temp./norm(temp);
% test
test = beamform_u' * G_u; %���Ӧ��ʮ�ֽӽ�0����ʾintra��������   
% ���û�u���Ÿ����
signal = P*abs(beamform_u'*g_u(:,typical_user))^2;
interf = 0;
for user=1:U
    if sum(clus_all(user,:).*clus_all(typical_user,:))==0
        interf = interf + P*abs(beamform_u'*g_u(:,user))^2;
    end
end
noise = 10^(-3.5);
sinr_u = signal/(interf+noise^2);
end