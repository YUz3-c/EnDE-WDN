%用于初始化种群
function X=initialization(SearchAgents_no,dim,D)
%随机选择管径
    for i=1:SearchAgents_no
        X(i,:)=round(rand(1,dim).*(size(D,2)-1))+1;
    end
end
