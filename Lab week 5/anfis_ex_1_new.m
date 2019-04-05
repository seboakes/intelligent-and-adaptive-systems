% Set up training data
noiseAmplitude = 5;
numPts=51;
x=linspace(-10,10,numPts)';
y= -2*x - x.^2 + noiseAmplitude*rand;
data=[x y];

% Split into training and validation data
trndata=data(1:2:numPts,:);
chkdata=data(2:2:numPts,:);

% Specify Membership Functions
%  numMFs=5;
%  mfType='gbellmf';

opt = genfisOptions('GridPartition');
opt.NumMembershipFunctions = 2;
opt.InputMembershipFunctionType = "gbellmf";

% Generate initial FIS
%  fismat=(genfis1(trndata,numMFs,mfType))
 
  fismat=(genfis(trndata(:,1),trndata(:,2),opt))  %generates initial membership functions 
 numEpochs=200;
 
% Train the FIS
[fismat1,trnErr,ss,fismat2,chkErr]=anfis(trndata,fismat,numEpochs,NaN,chkdata);
%Compare training and checking data to the fuzzy approximation:
anfis_y = evalfis(x(:,1),fismat1); % fismat = fuzzy inference system matrix

% so always do genfis - anfis - evalfis, in that order

%note that using fismat2 (generated using evalfis) will give you the FIS for the minimum validation
%error

figure
plot(trndata(:,1),trndata(:,2),'o',chkdata(:,1),chkdata(:,2),'x',x,anfis_y,'-')

figure
plot(chkErr)
hold on
plot(trnErr)
hold off

