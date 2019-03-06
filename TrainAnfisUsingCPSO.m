%% Training anfis using CPSO


function bestfis=TrainAnfisUsingCPSO(fis,data)

    %% Problem Definition
    
    p0=GetFISParams(fis);
    
    Problem.CostFunction=@(x) TrainFISCost(x,fis,data);
    
    Problem.nVar=numel(p0);
    
    Problem.VarMin=-25;
    Problem.VarMax=25;

    %% PSO Params
    Params.MaxIt=500;
    Params.nPop=25;

    %% Run PSO
    results=RunCPSO(Problem,Params);
    
    %% Get Results
    
    p=results.BestSol.Position.*p0;
    bestfis=SetFISParams(fis,p);
    
end

function results=RunCPSO(Problem,Params)

    disp('Starting CPSO ...');

    %% Problem Definition

    CostFunction=Problem.CostFunction;        % Cost Function

    nVar=Problem.nVar;          % Number of Decision Variables

    VarSize=[1 nVar];           % Size of Decision Variables Matrix

    VarMin=Problem.VarMin;      % Lower Bound of Variables
    VarMax=Problem.VarMax;      % Upper Bound of Variables

    %% CPSO Parameters

    MaxIt=Params.MaxIt;      % Maximum Number of Iterations

    nPop=Params.nPop;        % Population Size (Swarm Size)

    w=1;            % Inertia Weight
    wdamp=0.99;     % Inertia Weight Damping Ratio

    % Velocity Limits
  VelMax=0.1*(VarMax-VarMin);
  VelMin=-VelMax;

    %% Initialization

    empty_particle.Position=[];
    empty_particle.Cost=[];
    empty_particle.Velocity=[];
    empty_particle.Best.Position=[];
    empty_particle.Best.Cost=[];

    particle=repmat(empty_particle,nPop,1);

    BestSol.Cost=inf;

    for i=1:nPop

        % Initialize Position
        if i>1
            particle(i).Position=unifrnd(VarMin,VarMax,VarSize);
        else
            particle(i).Position=ones(VarSize);
        end

        % Initialize Velocity
        particle(i).Velocity=zeros(VarSize);

        % Evaluation
        particle(i).Cost=CostFunction(particle(i).Position);

        % Update Personal Best
        particle(i).Best.Position=particle(i).Position;
        particle(i).Best.Cost=particle(i).Cost;

        % Update Global Best
        if particle(i).Best.Cost<BestSol.Cost

            BestSol=particle(i).Best;

        end

    end

    BestCost=zeros(MaxIt,1);

    %% PSO Main Loop

c1=zeros(1,500);
c2=zeros(1,500)

    for it=1:MaxIt
 %% updating cognitive coefiecents
  c1(it)=3-c2(it);
  c2(it)=min(c2)*log((max(c2)/min(c2))^(2/(1+20*(it/MaxIt)))); 
  
  for i=1:nPop

            % Update Velocity
            particle(i).Velocity = w*particle(i).Velocity ...
                +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
                +c2*rand(VarSize).*(BestSol.Position-particle(i).Position);

            % Apply Velocity Limits
            particle(i).Velocity = max(particle(i).Velocity,VelMin);
            particle(i).Velocity = min(particle(i).Velocity,VelMax);

            % Update Position
            particle(i).Position = particle(i).Position + particle(i).Velocity;

            % Velocity Mirror Effect
            IsOutside=(particle(i).Position<VarMin | particle(i).Position>VarMax);
            particle(i).Velocity(IsOutside)=-particle(i).Velocity(IsOutside);

            % Apply Position Limits
            particle(i).Position = max(particle(i).Position,VarMin);
            particle(i).Position = min(particle(i).Position,VarMax);

            % Evaluation
            particle(i).Cost = CostFunction(particle(i).Position);

            % Update Personal Best
            if particle(i).Cost<particle(i).Best.Cost

                particle(i).Best.Position=particle(i).Position;
                particle(i).Best.Cost=particle(i).Cost;

                % Update Global Best
                if particle(i).Best.Cost<BestSol.Cost

                    BestSol=particle(i).Best;

                end

            end

        end

        BestCost(it)=BestSol.Cost;

        disp(['Iteration ' num2str(it) ': ClassificationAccuracy = ' num2str(1-BestCost(it))]);

        w=w*wdamp;

    end

    disp('End of CPSO.');
    disp(' ');
%     semilogy('BestCost')
    %% Results
    plot(BestCost,'LineWidth',2);
    xlabel('Iteration');
    ylabel('Best Cost');
    grid on;
    results.BestSol=BestSol;
    results.BestCost=BestCost;
    
end