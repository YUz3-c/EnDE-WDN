%% 在优化中使用的目标函数
function [fitness, cost] = objective(swarm,C,LinkLength,LinkVelocity,LinkHeadLoss)
    cost = 0;
    for i=1:size(swarm,2)        
        index = round(swarm(i));
        cost = cost + C(index)*LinkLength(i);
    end
    %第5条 管段流速约束：管段中水流流速不能超过3m/s
    if max(LinkVelocity) > 3
        cost = cost + 100000;
    end
    LinkHeadLoss = sum(LinkHeadLoss);
    fitness = 0.9*cost +0.1*LinkHeadLoss;
end