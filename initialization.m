function X=initialization(SearchAgents_no,dim,D)
    for i=1:SearchAgents_no
        X(i,:)=round(rand(1,dim).*(size(D,2)-1))+1;
    end
end
