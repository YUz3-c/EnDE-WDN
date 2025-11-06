function [gbest_pos,gbest_cost,gbest_fitness,curve] = original_DE(net_name,d,D,C,SearchAgents,Max_iteration)

LinkCount = d.getLinkCount;
LinkLength =  d.getLinkLength;
NodeCount = d.getNodeCount;


sizepop = SearchAgents;
Max_iter = Max_iteration;
dim = LinkCount;
F = 0.6;
CR = 0.5;
st = 1;

gbest_pos = zeros(1, dim);
gbest_cost = inf; 
LinkVelocity = zeros(sizepop, dim);
NodePressure = zeros(sizepop, NodeCount);
pop = initialization(sizepop,dim,D);
Diameter=D(pop);

for iter = 1:Max_iter
    d.openHydraulicAnalysis;  
    d.initializeHydraulicAnalysis;
    for i=1:sizepop
        d.setLinkDiameter(Diameter(i,:));
        d.saveInputFile(net_name) ;
        d.runHydraulicAnalysis;
        LinkVelocity(i,:) =  d.getLinkVelocity;
        NodePressure(i,:) =  d.getNodePressure;
        LinkHeadLoss(i,:) = d.getLinkHeadloss;
    end
    d.closeHydraulicAnalysis;

    for j = 1:sizepop      
        if min(NodePressure(j,1:(NodeCount-1))) > 30
            [fitness(j), cost(j)] = objective(pop(j, :),C,LinkLength,LinkVelocity(j,:),LinkHeadLoss(j,:));
        else
            fitness(j) = inf;
            cost(j) = inf;
        end
    end

     [fit,pos]=sort(fitness,'descend');
     current_bestfitness=fit(sizepop);
     cost = cost(pos);
     current_bestcost=cost(sizepop);
     current_bestpos=pop(pos(sizepop),:);
     pop = pop(pos,:);

     if iter == 1
         gbest_fitness=current_bestfitness;
         gbest_cost=current_bestcost;
         gbest_pos=current_bestpos;
     end
     
     if current_bestfitness < gbest_fitness
         gbest_fitness = current_bestfitness;
         gbest_cost = current_bestcost;
         gbest_pos = current_bestpos;
     end

     for i=1:sizepop
         pop(i, :) = DE(pop(i, :),pop,gbest_pos,st,F,CR,dim,sizepop);
     end
        
     for j = 1:sizepop
         for  k = 1:dim
             pop(j,k) = ceil(abs(pop(j,k)));
             if pop(j,k) > size(D,2)
                 pop(j,k) = rem(pop(j,k),size(D,2));
             end
             if pop(j,k) == 0
                 pop(j,k) = round(rand * (size(D,2)-1))+1;
             end
         end
     end


    Diameter=D(pop);
  
    disp(['iteration: ' num2str(iter) ' 成本花费: ' num2str(gbest_cost)]);
    disp(['iteration: ' num2str(iter) ' 适应度值: ' num2str(gbest_fitness)]);
    disp(['iteration: ' num2str(iter) ' 管径选择: ' num2str(D(gbest_pos))]);
    
    curve(iter) = gbest_fitness;
end

end

