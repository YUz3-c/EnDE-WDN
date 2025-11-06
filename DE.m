function ui=DE(popold,pop,bm,st,F,CR,n,NP)
global xl xu
xl = 1 * ones(1, n);
xu = 14* ones(1, n);

r1=round(rand*NP); r2=round(rand*NP); r3=round(rand*NP);
while (r1==j|r1==0),r1=ceil(round(rand*NP));end
while (r2==j|r2==r1|r2==0),r2=ceil(round(rand*NP));end
while (r3==j|r3==r1|r3==r2|r3==0),r3=ceil(round(rand*NP));end

pm1=pop(r1,1:n);
pm2=pop(r2,1:n);
pm3=pop(r3,1:n);
rotd= (0:1:n-1); 

mui = rand(1,n) < CR;     
if mui==zeros(1,n),nn=randperm(n);mui(nn(1))=1;end
if st>5
    st=st-5;
    mui=sort(mui');
    nn=floor(rand.*n);
    if nn>0
        rtd = rem(rotd+nn,n);
        mui(:) = mui(rtd+1);  
    end
    mui=mui';
end
mpo = mui < 0.5;      

if (st == 1)      
    ui = bm + F*(pm1 - pm2);   
    ui = popold.*mpo + ui.*mui;   
elseif (st == 2)     
    ui = pm3 + F*(pm1 - pm2);     
    ui = popold.*mpo + ui.*mui;    
end
if rand>0.5
    ui=(ui<xl).*xl+(ui>=xl).*ui;
    ui=(ui>xu).*xu+(ui<=xu).*ui;
else
    ui=(ui<xl).*(xl+rand(1,n).*(xu-xl))+(ui>=xl).*ui;
    ui=(ui>xu).*(xl+rand(1,n).*(xu-xl))+(ui<=xu).*ui;  
end