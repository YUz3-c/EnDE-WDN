clc, close all, clear all; 
tic
% 定义问题；双环管网
% 设计管道网络，将最小化其成本作为目标
% 约束条件包括稳定的水压、给定的最小和最大流量，以及一些其他约束条件
% 设置决策变量
% 决策变量为要选择的管道直径在集合中对应的位置

%% 加载EPANET的.inp文件，并获取水力模型基本信息
net_name='TLN.inp';
d=epanet(net_name);
disp('成功加载EPANET的.inp文件成功！');
disp('***************************************************')
disp(['当前管网：',net_name]);
disp('***************************************************')

%% 调用算法进行管径选择优化
%参数定义
SearchAgents = 50; % 粒子数
Max_iteration = 150; % 最大迭代次数
%第4条 最小管径与标准管径约束：管径从市场可购买到的管径中选择
D = [25.4, 50.8, 76.2, 101.6, 152.4, 203.2, 254, 304.8, 355.6, 406.4, 457.2, 508, 558.8, 609.6];%管径，单位：m
C = [2, 5, 8, 11, 16, 23, 32, 50, 60, 90, 130, 170, 300, 550];%管径对应的管道造价，单位：美元/m

%调用算法进行优化
% [gbest_pos,gbest_cost,gbest_fitness,de_curve]=EnDE(net_name,d,D,C,SearchAgents,Max_iteration);
[gbest_pos,gbest_cost,gbest_fitness,de_curve]=original_DE(net_name,d,D,C,SearchAgents,Max_iteration);

%% 根据最优解进行模型验证和合理性检查
disp([ '最优成本花费: ' num2str(gbest_cost)]);
disp([ '最优适应度值: ' num2str(gbest_fitness)]);
disp(['最优管道直径选择: ' num2str(D(gbest_pos))]);
%开始水力运算
d.openHydraulicAnalysis; 
d.initializeHydraulicAnalysis;
d.setLinkDiameter(D(gbest_pos));
%存储当前管网结构为inp文件
d.saveInputFile(net_name) ; 
%进行水力运算
d.runHydraulicAnalysis;
%获取管段流速
Velocity =  d.getLinkVelocity;
%获取节点压力
Pressure =  d.getNodePressure;
% 获取管段水头损失
LinkHeadLoss = d.getLinkHeadloss;          % 每条管道水头损失
TotalHeadLoss = sum(LinkHeadLoss);         % 总水头损失
%计算完成
d.closeHydraulicAnalysis;  
 %输出管段流速Z
disp('Velocity：');
disp(Velocity);
 %输出节点压力
disp('Pressure：');
disp(Pressure);
disp('每条管道水头损失：'); disp(LinkHeadLoss);
disp(['水头损失总和：', num2str(TotalHeadLoss)]);
elapsedTime = toc;  % 结束计时，并返回运行时间（单位：秒）
fprintf('算法运行时间: %.2f 秒\n', elapsedTime);

% 收敛曲线图
plot(de_curve,'b','LineWidth',1.5);
title('Convergence curve','FontSize',15)
xlabel('iteration','FontSize',15);
ylabel('optimal fitness','FontSize',15);
box on
legend('DE')
