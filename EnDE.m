function [gbest_pos,gbest_cost,gbest_fitness,curve] = EnDE(net_name,d,D,C,SearchAgents,Max_iteration)

%% 使用ROA算法进行优化

%获取管道数量
LinkCount = d.getLinkCount;
%获取管段长度
LinkLength =  d.getLinkLength;
%获取节点数量
NodeCount = d.getNodeCount;


%% 初始化参数
sizepop = SearchAgents; %种群数量
Max_iter = Max_iteration; % 最大迭代次数 
dim = LinkCount; %维度
F = 0.6*ones(sizepop,1); % 每个个体的F
CR = 0.5*ones(sizepop,1); % 每个个体的CR
st = 1;
no_update_count = 0;

% 初始化种群
gbest_pos = zeros(1, dim);
gbest_cost = inf; 
LinkVelocity = zeros(sizepop, dim);
NodePressure = zeros(sizepop, NodeCount);
pop = initialization(sizepop,dim,D);
Diameter=D(pop);%每个个体选择的管道直径
% numsp = 2;%子种群个数
% sizesp = sizepop/numsp;%每个子种群数量


%% 迭代计算最优解
for iter = 1:Max_iter
    %将每个个体初始化选择的管径传进水力模型进行模拟计算
    %开始水力运算
    d.openHydraulicAnalysis;  
    d.initializeHydraulicAnalysis;
    for i=1:sizepop
        %传入第i个个体选择的管径
        d.setLinkDiameter(Diameter(i,:));
        %存储当前管网结构为inp文件
        d.saveInputFile(net_name) ;
        %进行水力运算
        d.runHydraulicAnalysis;
        %获取管段流速
        LinkVelocity(i,:) =  d.getLinkVelocity;
        %获取节点压力
        NodePressure(i,:) =  d.getNodePressure;
        %获取水头损失
        LinkHeadLoss(i,:) = d.getLinkHeadloss;
    end
    %计算完成
    d.closeHydraulicAnalysis;

    % 计算个体选择的管径对应的适应度值
    for j = 1:sizepop      
        %第3条 节点自由水压约束：设置最小服务水头为30m
        if min(NodePressure(j,1:(NodeCount-1))) > 30
            %计算满足约束条件的目标函数的成本值
            [fitness(j), cost(j)] = objective(pop(j, :),C,LinkLength,LinkVelocity(j,:),LinkHeadLoss(j,:));
        else
            fitness(j) = inf;
            cost(j) = inf;
            %disp('⚠ 水头不足，成本无穷大');
        end
    end

     %按适应度值排序，找出适应度最低的个体
     [fit,pos]=sort(fitness,'descend');
     current_bestfitness=fit(sizepop);%适应度最低的个体的适应度值
     cost = cost(pos);
     current_bestcost=cost(sizepop);%适应度最低的个体的成本值
     current_bestpos=pop(pos(sizepop),:);%适应度最低的个体选择的管径序号
     pop = pop(pos,:);

     % 记录最优个体的F和CR
     f = F(1);
     cr = CR(1);
     gamma = 0.2;       % 控制柯西分布的尺度，越小越集中
     F = zeros(sizepop,1);
     for i = 1:sizepop
         while true
             % 生成柯西扰动
             x = f + gamma*tan(pi*(rand-0.5));
             y = cr + gamma*tan(pi*(rand-0.5));
             % 截尾到 [0,1]
             if x>0 && x<1
                 F(i) = x;
                 CR(i) = y;
                 break;
             end
         end
     end

     %记录最低的适应度值和成本值
     if iter == 1
         gbest_fitness=current_bestfitness;
         gbest_cost=current_bestcost;
         gbest_pos=current_bestpos;
     end
     
     if current_bestfitness < gbest_fitness
         gbest_fitness = current_bestfitness;
         gbest_cost = current_bestcost;
         gbest_pos = current_bestpos;
         no_update_count = 0;  % 重置计数器
     else
         no_update_count = no_update_count + 1;  % 未更新则累加
     end

     if no_update_count >= 10
         st = 2;
     end

     %% 更新种群
     for i=1:sizepop
         pop(i, :) = DE(pop(i, :),pop,gbest_pos,st,F(i),CR(i),dim,sizepop);
     end
        
     % %取整
     % for j = 1:sizepop
     %     for  k = 1:dim
     %         pop(j,k) = ceil(abs(pop(j,k)));
     %         if pop(j,k) > size(D,2)
     %             pop(j,k) = rem(pop(j,k),size(D,2));
     %         end
     %         if pop(j,k) == 0
     %             pop(j,k) = round(rand * (size(D,2)-1))+1;
     %         end
     %     end
     % end
     offsets = [0,1,2];              % 偏移量
     probs   = [0.6,0.3,0.1];        % 对应概率
     for j = 1:sizepop
         for k = 1:dim
             r = rand;
             c = cumsum(probs);           % 累积概率
             idx = find(r <= c,1);        % 选择偏移
             pop(j,k) = round(pop(j,k)) + offsets(idx)*(2*(rand>0.5)-1);
             % 限制范围
             pop(j,k) = max(1,min(size(D,2),pop(j,k)));
         end
     end



    %更新之后每个个体选择的管道直径
    Diameter=D(pop);
  
    % 输出迭代过程
    disp(['iteration: ' num2str(iter) ' 成本花费: ' num2str(gbest_cost)]);
    disp(['iteration: ' num2str(iter) ' 适应度值: ' num2str(gbest_fitness)]);
    disp(['iteration: ' num2str(iter) ' 管径选择: ' num2str(D(gbest_pos))]);
    
    %记录每次迭代的成本值
    curve(iter) = gbest_fitness;
end

end

