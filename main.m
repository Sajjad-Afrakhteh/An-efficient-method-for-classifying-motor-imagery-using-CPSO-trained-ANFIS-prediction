hold on
clc;
clear;
% close all;

%% Load Data
load MYdata_calib_ds1a.txt;
Inputs=MYdata_calib_ds1a(:,1:10);
Targets=MYdata_calib_ds1a(:,11);
nSample=size(Inputs,1);
S=randperm(nSample);
Inputs=Inputs(S,:);
Targets=Targets(S,:);
pTrain=1;
nTrain=round(pTrain*nSample);
TrainInputs=Inputs(1:nTrain,:);
TrainTargets=Targets(1:nTrain,:);
TestInputs=Inputs(nTrain+1:end,:);
TestTargets=Targets(nTrain+1:end,:);
data.TrainInputs=TrainInputs;
data.TrainTargets=TrainTargets;
data.TestInputs=TestInputs;
data.TestTargets=TestTargets;
%% Generate Basic FIS

fis=CreateInitialFIS(data,10);

%% Train Using PSO

Options = {'Genetic Algorithm', 'Particl Swarm Optimization','CPSO algorithm','Differential Evolution algorithm',...
    'BBO algorithm'};

[Selection, Ok] = listdlg('PromptString', 'Select training method for ANFIS:', ...
                          'SelectionMode', 'single', ...
                          'ListString', Options);

pause(0.01);
          
if Ok==0
    return;
end

switch Selection
    case 1, fis=TrainAnfisUsingGA(fis,data);        
    case 2, fis=TrainAnfisUsingPSO(fis,data);   
    case 3, fis=TrainAnfisUsingCPSO(fis,data);        
    case 4, fis=TrainAnfisUsingDE(fis,data);        
    case 5, fis=TrainAnfisUsingBBO(fis,data);               

end

%% Results

TrainOutputs=evalfis(data.TrainInputs,fis);
PlotResults(data.TrainTargets,TrainOutputs,'Train Data');