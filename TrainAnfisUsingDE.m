
%% Training anfis using DE

function bestfis=TrainAnfisUsingDE(fis,data)

    %% Problem Definition
    
    p0=GetFISParams(fis);
    
    Problem.CostFunction=@(x) TrainFISCost(x,fis,data);
    
    Problem.nVar=numel(p0);
    
    Problem.VarMin=-25;
    Problem.VarMax=25;

    %% GA Params
    Params.MaxIt=500;
    Params.nPop=50;

    %% Run GA
    results=RunEA(Problem,Params);
    
    %% Get Results
    
    p=results.BestSol.Position.*p0;
    bestfis=SetFISParams(fis,p);
    
end

%% Problem Definition
function results=RunDE(Problem,Params)
CostFunction = Problem.CostFunction;  % Objective Function

    nVar = Problem.nVar;           % Number of Decision Variables
    VarSize = [1 nVar]; % Decision Variables Matrix Size

    VarMin = Problem.VarMin;       % Lower Bound of Decision Variables
    VarMax = Problem.VarMax;        % Upper Bound of Decision Variables

%% DE Parameters

MaxIt=Params.MaxIt;      % Maximum Number of Iterations

nPop=Params.nPop;        % Population Size

beta_min=0.2;   % Lower Bound of Scaling Factor
beta_max=0.8;   % Upper Bound of Scaling Factor

pCR=0.2;        % Crossover Probability

%% Initialization

empty_individual.Position=[];
empty_individual.Cost=[];

BestSol.Cost=inf;

pop=repmat(empty_individual,nPop,1);

for i=1:nPop

    pop(i).Position=unifrnd(VarMin,VarMax,VarSize);
    
    pop(i).Cost=CostFunction(pop(i).Position);
    
    if pop(i).Cost<BestSol.Cost
        BestSol=pop(i);
    end
    
end

BestCost=zeros(MaxIt,1);

%% DE Main Loop

for it=1:MaxIt
    
    for i=1:nPop
        
        x=pop(i).Position;
        
        A=randperm(nPop);
        
        A(A==i)=[];
        
        a=A(1);
        b=A(2);
        c=A(3);
        
        % Mutation
        %beta=unifrnd(beta_min,beta_max);
        beta=unifrnd(beta_min,beta_max,VarSize);
        y=pop(a).Position+beta.*(pop(b).Position-pop(c).Position);
        y = max(y, VarMin);
		y = min(y, VarMax);
		
        % Crossover
        z=zeros(size(x));
        j0=randi([1 numel(x)]);
        for j=1:numel(x)
            if j==j0 || rand<=pCR
                z(j)=y(j);
            else
                z(j)=x(j);
            end
        end
        
        NewSol.Position=z;
        NewSol.Cost=CostFunction(NewSol.Position);
        
        if NewSol.Cost<pop(i).Cost
            pop(i)=NewSol;
            
            if pop(i).Cost<BestSol.Cost
               BestSol=pop(i);
            end
        end
        
    end
    
    % Update Best Cost
    BestCost(it)=BestSol.Cost;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    
end

%% Show Results
  results.BestSol=BestSol;
     results.BestCost=BestCost;
% figure;
%plot(BestCost);
plot(BestCost, 'LineWidth', 2);
xlabel('Iteration');
ylabel('Best Cost');
grid on;
end
