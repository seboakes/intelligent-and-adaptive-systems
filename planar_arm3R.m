%% Sebastian Oakes 2018 %%
%%% Program for generating an adaptive neuro-fuzzy inference system (ANFIS),
%%% designed for control of a planar, 3 link robot arm. Input  %%%


clc
clear
close all


%% library imports
import math.*
import pyplot.*

%% setting arm parameters

l1 = 10; % length of first arm link 
l2 = 7; % length of second arm link
l3 = 4;


theta1 = 0:0.1:pi/2; % joint ranges
theta2 = 0:0.1:pi; 
theta3 = 0:0.1:pi; 
[THETA1, THETA2, THETA3] = meshgrid(theta1, theta2, theta3); % generate a grid of theta1 and theta2 values


%%  FORWARD KINEMATICS %%

X = (l1*cos(THETA1))+(l2*cos(THETA1+THETA2))+(l3*cos(THETA1+THETA2+THETA3));          % compute x coordinates 
Y = (l1*sin(THETA1))+(l2*sin(THETA1+THETA2))+(l3*sin(THETA1+THETA2+THETA3)); % compute y coordinates
phi = THETA1+THETA2+THETA3;


%%%create data sets - X and Y form inputs, THETA the output.
data1 = [X(:) Y(:) THETA1(:)]; % create x-y-theta dataset for all link angles
data2 = [X(:) Y(:) THETA2(:)]; 
data3 = [X(:) Y(:) THETA3(:)]; 
 


%% Splitting data into training, validation and test sets
%Process ensures that data set is split randomly, but ensures no crossover
%between validation and training

valid_frac = 0.1;% values used to determine the fraction of total data to be used for validation and test, thus allowing me to vary it as necessary.
test_frac = 0.1; 
comb_frac = valid_frac+test_frac;

dim=size(data1);
datTot=dim(1);


%mulitplies by the fraction denoting the desired quantity of validation data points, and creates two distinct groups
%index used to denote either 1 or 0
idx = randperm(datTot);   % Randomise ordering of the data points, whilst retaining an index relating 
indexToGroup1 = (idx<=valid_frac*datTot);
indexToGroup2 = (idx<=valid_frac*datTot);  
indexToGroup3 = (idx);
                                            
                                            
Vdata1 = data1(indexToGroup1,:); %creates validation data set using index and original data set
Tdata1 = data1(indexToGroup2,:); %creates training data set 

%-----%

dim=size(data2);
datTot=dim(1);

idx = randperm(datTot);
indexToGroup1 = (idx<=valid_frac*datTot);
indexToGroup2 = (idx>valid_frac*datTot);
Vdata2 = data1(indexToGroup1,:);
Tdata2 = data1(indexToGroup2,:);

%-----%

dim=size(data3);
datTot=dim(1);

idx = randperm(datTot);
indexToGroup1 = (idx<=valid_frac*datTot);
indexToGroup2 = (idx>valid_frac*datTot);
Vdata3 = data1(indexToGroup1,:);
Tdata3 = data1(indexToGroup2,:);


%% Generate fuzzy inference system (genfis) for theta 1 training and validation dataset
numMFs = 6;
mfType = 'gaussmf';
Tfis1 =genfis1(Tdata1,numMFs,mfType);

Vfis1 =genfis1(Vdata1,numMFs,mfType);


%% genfis for theta 2 dataset
numMFs = 4;
mfType = 'gaussmf';
Tfis2 =genfis1(Tdata2,numMFs,mfType);
Vfis2 =genfis1(Vdata2,numMFs,mfType);

%% genfis for theta 3 dataset
numMFs = 3;
mfType = 'gaussmf';
Tfis3 =genfis1(Tdata3,numMFs,mfType);
Vfis3 =genfis1(Vdata3,numMFs,mfType);

% %% Plot membership functions (from fis) for reference
% figure
% [x,mf] = plotmf(Tfis1,'input',1);
% subplot(2,1,1);
% plot(x,mf);
% xlabel('input 1 (gbellmf)');
% [x,mf] = plotmf(Tfis1,'input',2);
% subplot(2,1,2);
% plot(x,mf);
% xlabel('input 2 (gbellmf)');
% 
% figure
% [x,mf] = plotmf(fis2,'input',1);
% subplot(2,1,1)
% plot(x,mf)
% xlabel('input 1 (gbellmf)')
% [x,mf] = plotmf(fis2,'input',2);
% subplot(2,1,2);
% plot(x,mf);
% xlabel('input 2 (gbellmf)');
% 
% figure
% [x,mf] = plotmf(Tfis3,'input',1);
% subplot(2,1,1);
% plot(x,mf);
% xlabel('input 1 (gbellmf)');
% [x,mf] = plotmf(Tfis3,'input',2);
% subplot(2,1,2);
% plot(x,mf);
% xlabel('input 2 (gbellmf)');
% 



%% build anfis networks based on the genfis data
numEpochs = 10;


% trnOpt: a vector of training options. 
% trnOpt(1): maximum training epoch number (default: 10)
% trnOpt(2): training error goal (default: 0) 
% trnOpt(3): initial step size (default: 0.01) 
% trnOpt(4): step size decrease rate (default: 0.9)
% trnOpt(5): step size increase rate (default: 1.1)
trnOpt = [400 0.5 0.01 0.9 1.1];
dispOpt = [1 1 1 1];

%opt = anfisOptions

disp('training first anfis network (for theta1)');


trnOpt = [10 0.1 0.01 0.9 1.1];
[Tanfis1,train_error1,stepsize1,Vanfis1,val_error1]=anfis(Tdata1,Tfis1,trnOpt,NaN,Vdata1);

figure('Name', 'Training Error Theta1'); 
title('Training Error Theta 1');
plot(train_error1);
figure('Name', 'Validation Error Theta1');
title('Validation Error Theta 1');
plot(val_error1);



disp('training 2nd anfis network (for theta2)');
%trnOpt = [450 0.1 0.01 0.9 1.1];
trnOpt = [10 0.1 0.01 0.9 1.1];
[Tanfis2,train_error2,stepsize1,Vanfis2,val_error2]=anfis(Tdata2,Tfis2,trnOpt,NaN,Vdata2);

figure('Name', 'Training Error Theta1');
plot(train_error2);
title('Training Error Theta 2');

figure('Name', 'Validation Error Theta2');
plot(val_error2);
title('Validation Error Theta 2');




disp('training 3rd anfis network (for theta3)');
%trnOpt = [120 0.1 0.01 0.9 1.1];
trnOpt = [10 0.1 0.01 0.9 1.1];
figure('Name', 'Training Error Theta3');
[Tanfis3,train_error3,stepsize1,Vanfis3,val_error3]=anfis(Tdata3,Tfis3,trnOpt,NaN,Vdata3);
plot(train_error3);
title('Training Error Theta 3');

figure('Name', 'Validation Error Theta3');
plot(val_error3);
title('Validation Error Theta 3');




%% Validation %%

figure();
[x,mf] = plotmf(Tanfis1,'input',1);
plot(x,mf);
title('Membership Functions after ANFIS Training (Theta 1)');

figure();
[x,mf] = plotmf(Tanfis2,'input',1);
plot(x,mf);
title('Membership Functions after ANFIS Training (Theta 2)');

figure();
[x,mf] = plotmf(Tanfis3,'input',1);
plot(x,mf);
title('Membership Functions after ANFIS Training (Theta 3)');


 