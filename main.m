clc, close all, clear all; 
net_name='TLN.inp';
d=epanet(net_name);
disp('成功加载EPANET的.inp文件成功！');
disp('***************************************************')
disp(['当前管网：',net_name]);
disp('***************************************************')

SearchAgents = 50;
Max_iteration = 150;
D = [25.4, 50.8, 76.2, 101.6, 152.4, 203.2, 254, 304.8, 355.6, 406.4, 457.2, 508, 558.8, 609.6];
C = [2, 5, 8, 11, 16, 23, 32, 50, 60, 90, 130, 170, 300, 550];

%[gbest_pos,gbest_cost,gbest_fitness,de_curve]=EnDE(net_name,d,D,C,SearchAgents,Max_iteration);
[gbest_pos,gbest_cost,gbest_fitness,de_curve]=original_DE(net_name,d,D,C,SearchAgents,Max_iteration);

disp([ '最优成本花费: ' num2str(gbest_cost)]);
disp([ '最优适应度值: ' num2str(gbest_fitness)]);
disp(['最优管道直径选择: ' num2str(D(gbest_pos))]);
d.openHydraulicAnalysis; 
d.initializeHydraulicAnalysis;
d.setLinkDiameter(D(gbest_pos));
d.saveInputFile(net_name) ; 
d.runHydraulicAnalysis;
Velocity =  d.getLinkVelocity;
Pressure =  d.getNodePressure;
LinkHeadLoss = d.getLinkHeadloss; 
TotalHeadLoss = sum(LinkHeadLoss);  
d.closeHydraulicAnalysis;  
disp('Velocity：');
disp(Velocity);
disp('Pressure：');
disp(Pressure);
disp('每条管道水头损失：'); disp(LinkHeadLoss);
disp(['水头损失总和：', num2str(TotalHeadLoss)]);

plot(de_curve,'b','LineWidth',1.5);
title('Convergence curve','FontSize',15)
xlabel('iteration','FontSize',15);
ylabel('optimal fitness','FontSize',15);
box on
legend('DE')
