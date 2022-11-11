clc;
clear;
%% global variables
global version;
% global H_t_single;
% global Q_t;
% global cost_th;
% ʱ϶����ȫ�ֱ���
global V;
global xi;
global size_se;
global comp_se;
global C_bs;
global S_bs;
global K;
global N_agents;
global B;
global B0;
global B0_size;
global A;
global P;
global U;
global typical_user;
global cost_th;
% ʱ϶�仯ȫ�ֱ���
global ch;
global clus_all;
global costq_t;
global costq_t_instant;
global costq_t_block;
global req_type;
global req_type_ind;
global delay_edge;
global delay_bkb;
global data_t;
global workld_t;
global theta;
% global R;
% rng(5,'twister');
V = 5;
%% parameters of BSs
% ����վ�������ĳ���û��Ļ�վ��,�û�վ���������߶�������û��źţ�������������
B = 4; % ��վ�صĴ�СԼ��
B0 = 3; % ����ͬһ��վ�ص�ж���û���
% B_max = 5;
A = 3; % ÿ����վ���߸���
P = 1; % user's transmit power
N_agents = 10; %number of BSs, i.e., M
% C_bs = randi([2,5],N_agents,1);
% S_bs = randi([2,5],N_agents,1);%computing and storage of BSs
C_bs = 3*ones(N_agents,1); %��λ��GB���仯��Χ[3-10]
S_bs = 3*ones(N_agents,1);%computing and storage of BSs����λ��GHz
U = 4; %number of users
typical_user = randi(U); % ָ��typical�û�
% sinr_th = 1;
distance = kron(0.1 * randi([1,10],N_agents,U), ones(A,1)); %��վ���û��ľ��룬��λ��Km
beta = 128.1 + 37.6 * log(distance);
pathLoss = 10 .^ (beta ./ 10);
%% parameters of task
K = 6; %number of service types
% size_se = randi([2,5],K,1); %size vector of services
% comp_se = randi([2,5],K,1); %computing requirement of services
% cost_coef = rand(K,1); %cost coefficient of caching services
size_se = 3 * ones(K,1); %��λ��GB
comp_se = 0.3 * ones(K,1); %��λ��GHz
data_se = linspace(1,K,K); %��λ��GB
workld_se = linspace(0.1,0.1*K,K); %����ÿ��λ������Ҫ��CPU cycles����λ��CPU cycles/GB��
cost_coef = linspace(0.1,0.1*K,K); %����ÿ��λ������Ҫ���ѵĿ�������λ��ǧԪ/GB
R = 0.05; %data rate of backbone����λ��Gbps
xi = cost_coef' .* size_se;
cost_th = 2;

T = 30;
%% ��ʼ��
time = datetime;
version = [num2str(time.Year) num2str(time.Month) num2str(time.Day) num2str(time.Hour)];
% new_folder = sprintf('%s', ['output\' version 'gibbs_conver']);
% mkdir(new_folder);
% new_folder = sprintf('%s', ['output\' version 'admm_conver']);
% mkdir(new_folder);

% ��ʼ��
% proposed
theta = 1;
C_t = zeros(1,N_agents);
X_t = zeros(K, N_agents);
costq_last = 0.1; 
costq_t = 0.1;
delay_T = zeros(2,T);
delay_uplink_T = zeros(2,T);
cach_cost_T = zeros(2,T);
% comparison: instant optimal
C_t_instant = zeros(1,N_agents);
X_t_instant = zeros(K, N_agents);
costq_last_instant = 0.1; 
costq_t_instant = 0.1;
delay_T_instant = zeros(2,T);
delay_uplink_T_instant = zeros(2,T);
cach_cost_T_instant = zeros(2,T);
% comparison: block descent
C_t_block = zeros(1,N_agents);
X_t_block = zeros(K, N_agents);
costq_last_block = 0.1; 
costq_t_block = 0.1;
delay_T_block = zeros(2,T);
delay_uplink_T_block = zeros(2,T);
cach_cost_T_block = zeros(2,T);

% ��ʱ϶��״̬�洢
% data_T = rand(1,T)*10;
% workld_T = rand(1,T);
req_type_all_T = zeros(B0,T);
zipf_B0 = 0.1 * randi([1,10],1,B0);
for user=1:B0
    req_type_T = gener_req(T, K, zipf_B0(1,user));
    req_type_all_T(user,:) = req_type_T;
end
ch_T = zeros(N_agents*A, U, T);
clus_all_T = zeros(U, N_agents, T);
S_bs_T = zeros(N_agents,T);
C_bs_T = zeros(N_agents,T);
for t = 1:T
    ch = sqrt(1/2) * (randn(N_agents*A, U) + 1i * randn(N_agents*A, U));
    ch_T(:,:,t) = ch .* sqrt(pathLoss);
    S_bs_T(:,t) = round(rand(N_agents,1)) * 3;
    C_bs_T(:,t) = round(rand(N_agents,1)) * 3;
end
for t = 1:T
    [clus_all_T(:,:,t),~] = BScluster(sum(ch_T(:,:,t),3));
end
B0_size_T = zeros(1,T);
% begin long term optimization 
for t = 1:T
    %% ��ǰstates (���з���ͳһʹ�õ�)
    req_type_ind = req_type_all_T(:,t); % B0*1
    req_type = zeros(K,1); % ����B0�û����������ͣ�������ظ��ģ�����ϵ����Ϊ1
    for ii=1:B0
        req_type(req_type_ind(ii)) = req_type(req_type_ind(ii)) + 1;
    end
    B0_size = sum(req_type~=0);
    B0_size_T(1,t) = B0_size;
    data_t = zeros(K,1);
    workld_t = zeros(K,1);
    for ii=1:B0
        data_t(req_type_ind(ii)) = data_t(req_type_ind(ii)) + data_se(1,req_type_ind(ii));
        workld_t(req_type_ind(ii)) = workld_t(req_type_ind(ii)) + workld_se(1,req_type_ind(ii));
    end
    S_bs = S_bs_T(:,t);
    C_bs = C_bs_T(:,t);
    % ���������ڱ�Ե������Ҫ��ʱ��
    delay_edge = data_t .* workld_t ./ comp_se;
    delay_bkb = 10 .* delay_edge;
    % ���ɵ�ǰʱ϶�ŵ�ϵ������СΪMA*U�����������ֲ�
    ch = sum(ch_T(:,:,t),3);
    % generate the clustering state of other users (independent from the typical user)
    clus_all = clus_all_T(:,:,t);
    %% proposed algorithm
    a_t = xi' * X_t * (C_t');
    costq_t = max(costq_last + a_t - cost_th, 0.1);
    % ��ǰʱ϶�������
    [C_t, X_t] = bina_benders()
    disp('request types:');
    disp(req_type_ind);
    % ����������·ʱ��
    delay_uplink = 0;
    for kk=1:K
        delay_uplink = delay_uplink + data_t(kk) / log2(1 + calcu_sinr(clus_all, C_t, ch));
    end
    delay_uplink = delay_uplink / B0_size;
    delay_uplink_T(1,t) = delay_uplink;
    delay_uplink_T(2,t) = sum(delay_uplink_T(1,:),2)/t;

    costq_last = costq_t;

    % ���㵱ǰʱ϶ƽ�����û����������ʱ���Լ���վ�Ļ��濪�����ø��º�Ļ���״̬���㣩
    delay_pro = 0;
    for kk=1:K
        delay_pro = delay_pro + max(C_t .* (req_type(kk) * X_t(kk,:))) * (delay_edge(kk) - delay_bkb(kk)) + delay_bkb(kk);
    end
    delay_pro = delay_pro / B0_size;
    delay_t = delay_pro + delay_uplink;
    delay_T(1,t) = delay_t;
    delay_T(2,t) = sum(delay_T(1,:),2)/t;
    cach_cost_T(1,t) = sum(xi'*X_t,2);
    cach_cost_T(2,t) = sum(cach_cost_T(1,:),2)/t;
    
     %% �Ա��㷨��Lyapunov-based ˲ʱ����
    a_t_instant = xi' * X_t_instant * (C_t_instant');
    costq_t_instant = max(costq_last_instant + a_t_instant - cost_th, 0.1);
    % ��ǰʱ϶�������
    [C_t_instant, X_t_instant, optimal_theta] = bina_instant()
    % ����������·ʱ��
    delay_uplink_instant = 0;
    for kk=1:K
        delay_uplink_instant = delay_uplink_instant + data_t(kk) / log2(1 + calcu_sinr(clus_all, C_t_instant, ch));
    end
    delay_uplink_instant = delay_uplink_instant / B0_size;
    delay_uplink_T_instant(1,t) = delay_uplink_instant;
    delay_uplink_T_instant(2,t) = sum(delay_uplink_T_instant(1,:),2)/t;

    costq_last_instant = costq_t_instant;

    % ���㵱ǰʱ϶�û����������ʱ���Լ���վ�Ļ��濪�����ø��º�Ļ���״̬���㣩
    delay_pro_instant = 0;
    for kk=1:K
        delay_pro_instant = delay_pro_instant + max(C_t_instant .* (req_type(kk) * X_t_instant(kk,:))) * (delay_edge(kk) - delay_bkb(kk)) + delay_bkb(kk);
    end
    delay_pro_instant = delay_pro_instant / B0_size;
    delay_t_instant = delay_pro_instant + delay_uplink_instant;
    delay_T_instant(1,t) = delay_t_instant;
    delay_T_instant(2,t) = sum(delay_T_instant(1,:),2)/t;
    cach_cost_T_instant(1,t) = sum(xi'*X_t_instant,2);
    cach_cost_T_instant(2,t) = sum(cach_cost_T_instant(1,:),2)/t;
    
    %% �Ա��㷨��block descent
    a_t_block = xi' * X_t_block * (C_t_block');
    costq_t_block = max(costq_last_block + a_t_block - cost_th, 0.1);
    % ��ǰʱ϶�������
    [C_t_block, X_t_block] = block_descent(optimal_theta)
    % ����������·ʱ��
    delay_uplink_block = 0;
    for kk=1:K
        delay_uplink_block = delay_uplink_block + data_t(kk) / log2(1 + calcu_sinr(clus_all, C_t_block, ch));
    end
    delay_uplink_block = delay_uplink_block / B0_size;
    delay_uplink_T_block(1,t) = delay_uplink_block;
    delay_uplink_T_block(2,t) = sum(delay_uplink_T_block(1,:),2)/t;

    costq_last_block = costq_t_block;

    % ���㵱ǰʱ϶�û����������ʱ���Լ���վ�Ļ��濪�����ø��º�Ļ���״̬���㣩
    delay_pro_block = 0;
    for kk=1:K
        delay_pro_block = delay_pro_block + max(C_t_block .* (req_type(kk) * X_t_block(kk,:))) * (delay_edge(kk) - delay_bkb(kk)) + delay_bkb(kk);
    end
    delay_pro_block = delay_pro_block / B0_size;
    delay_t_block = delay_pro_block + delay_uplink_block;
    delay_T_block(1,t) = delay_t_block;
    delay_T_block(2,t) = sum(delay_T_block(1,:),2)/t;
    cach_cost_T_block(1,t) = sum(xi'*X_t_block,2);
    cach_cost_T_block(2,t) = sum(cach_cost_T_block(1,:),2)/t;

end
%% ������������
% path = sprintf('%s', ['output\' 'diffclus_size' version]);
% save(path, 'delay_B','cach_cost_B','delay_uplink_B');
disp(time);
time = datetime;
disp(time);
%% ��ͼ
figure;
%subplot(2,1,1)
plot(delay_T(2,:),'r-o','Linewidth',1);
hold on;
plot(delay_uplink_T(2,:),'r--o','Linewidth',1);
hold on;
plot(delay_T_instant(2,:),'b-*','Linewidth',1);
hold on;
plot(delay_uplink_T_instant(2,:),'b--*','Linewidth',1);
hold on;
plot(delay_T_block(2,:),'g-v','Linewidth',1);
hold on;
plot(delay_uplink_T_block(2,:),'g--v','Linewidth',1);
grid on;
xlabel('time slots');
ylabel('averaged delay');
legend('proposed(total)', 'proposed(uplink)','instant(total)', 'instant(uplink)','block(total)', 'block(uplink)');

%subplot(2,1,2)
%bar(B0_size_T);
%grid on;
%xlabel('time slots');
%ylabel('types');
%legend('number of requested service types');

figure;
plot(cach_cost_T(2,:),'r-o','Linewidth',1);
hold on;
plot(cach_cost_T_instant(2,:),'b--*','Linewidth',1);
hold on;
plot(cost_th*ones(1,T),'k-','Linewidth',1);
hold on;
plot(cach_cost_T_block(2,:),'g--v','Linewidth',1);
grid on;
xlabel('time slots');
ylabel('averaged cost');
legend('cost', 'instant optimal', 'threshold', 'block descent');

for user=1:B0
    figure; 
    histogram(req_type_all_T(user,:));
    xlabel('service types');
    ylabel('frequency');
    legend(['user' num2str(user) ': ' num2str(zipf_B0(1,user))]);
end