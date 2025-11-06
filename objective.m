function [fitness, cost] = objective(swarm,C,LinkLength,LinkVelocity,LinkHeadLoss)
    cost = 0;
    for i=1:size(swarm,2)        
        index = round(swarm(i));
        cost = cost + C(index)*LinkLength(i);
    end

    if max(LinkVelocity) > 3
        cost = cost + 100000;
    end
    LinkHeadLoss = sum(LinkHeadLoss);
    fitness = 0.9*cost +0.1*LinkHeadLoss;
end