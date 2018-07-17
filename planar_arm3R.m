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
[THETA1, THETA2, THETA3] = meshgrid(theta1, theta2, theta3); % generate a grid of theta1, theta2 and theta3 values


%%  FORWARD KINEMATICS %%

X = (l1*cos(THETA1))+(l2*cos(THETA1+THETA2))+(l3*cos(THETA1+THETA2+THETA3));          % compute x coordinates 
Y = (l1*sin(THETA1))+(l2*sin(THETA1+THETA2))+(l3*sin(THETA1+THETA2+THETA3)); % compute y coordinates
phi = THETA1+THETA2+THETA3;


%%%create data sets - X and Y form inputs, THETA the output.
data1 = [X(:) Y(:) THETA1(:)]; % create x-y-theta dataset for all link angles
data2 = [X(:) Y(:) THETA2(:)]; 
data3 = [X(:) Y(:) THETA3(:)]; 
 
%data1 = (1:200)';

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
indexToGroup1 = (idx<=valid_frac*datTot);  %validation data
indexToGroup2 = (idx<=comb_frac*datTot & idx>valid_frac*datTot);   % test data
indexToGroup3 = (idx>comb_frac*datTot); %training data
                                            
                                            
ValidData1 = data1(indexToGroup1,:); %creates validation data set using index and original data set
TrainData1 = data1(indexToGroup3,:); %creates training data set 
TestData1 = data1(indexToGroup2,:);

%-----%

dim=size(data2);
datTot=dim(1);

idx = randperm(datTot);
indexToGroup1 = (idx<=valid_frac*datTot);  %validation data
indexToGroup2 = (idx<=comb_frac*datTot & idx>valid_frac*datTot);   % test data
indexToGroup3 = (idx>comb_frac*datTot); %training data



ValidData2 = data2(indexToGroup1,:); %creates validation data set using index and original data set
TrainData2 = data2(indexToGroup3,:); %creates training data set 
TestData2 = data2(indexToGroup2,:);

%-----%

dim=size(data3);
datTot=dim(1);

idx = randperm(datTot);
indexToGroup1 = (idx<=valid_frac*datTot);  %validation data
indexToGroup2 = (idx<=comb_frac*datTot & idx>valid_frac*datTot);   % test data
indexToGroup3 = (idx>comb_frac*datTot); %training data



ValidData3 = data3(indexToGroup1,:); %creates validation data set using index and original data set
TrainData3 = data3(indexToGroup3,:); %creates training data set 
TestData3 = data3(indexToGroup2,:);

%% Generate fuzzy inference system (genfis) for theta 1 training and validation dataset
numMFs = 6;
mfType = 'gaussmf';
Tfis1 =genfis1(TrainData1,numMFs,mfType);
Vfis1 =genfis1(ValidData1,numMFs,mfType);


%% genfis for theta 2 dataset
numMFs = 4;
mfType = 'gaussmf';
Tfis2 =genfis1(TrainData2,numMFs,mfType);
Vfis2 =genfis1(ValidData2,numMFs,mfType);

%% genfis for theta 3 dataset
numMFs = 3;
mfType = 'gaussmf';
Tfis3 =genfis1(TrainData3,numMFs,mfType);
Vfis3 =genfis1(ValidData3,numMFs,mfType);

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


% opt.DisplayANFISInformation = 0;
% opt.DisplayErrorValues = 0;
% opt.DisplayStepSize = 0;
% opt.DisplayFinalResults = 0;
dispOpt = [1 1 1 1];



% trnOpt: a vector of training options. 
% trnOpt(1): maximum training epoch number (default: 10)
% trnOpt(2): training error goal (default: 0) 
% trnOpt(3): initial step size (default: 0.01) 
% trnOpt(4): step size decrease rate (default: 0.9)
% trnOpt(5): step size increase rate (default: 1.1)
trnOpt = [400 0.5 0.01 0.9 1.1];

%opt = anfisOptionsTest

disp('training first anfis network (for theta1)');


% [anfis_output, training_error, stepsize, val_fis,val_error] = anfis(training_data,fizzmat1,trnOpt,dispOpt,validation_data,optMethod);]

trnOpt = [100 0.1 0.01 0.9 1.1];
[anfis1,train_error1,~,Vanfis1,val_error1]=anfis(TrainData1,Tfis1,trnOpt,NaN,ValidData1);

figure('Name', 'Training Error Theta1'); 
hold on;
title('Training Error Theta 1');
plot(train_error1, val_error1);

figure('Name', 'Validation Error Theta1');
title('Validation Error Theta 1');
plot(val_error1);



disp('training 2nd anfis network (for theta2)');

trnOpt = [100 0.1 0.01 0.9 1.1];
[anfis2,train_error2,~,Vanfis2,val_error2]=anfis(TrainData2,Tfis2,trnOpt,NaN,ValidData2);

figure('Name', 'Training Error Theta1');
plot(train_error2);
title('Training Error Theta 2');

figure('Name', 'Validation Error Theta2');
plot(val_error2);
title('Validation Error Theta 2');




disp('training 3rd anfis network (for theta3)');

trnOpt = [100 0.1 0.01 0.9 1.1];

[anfis3,train_error3,~,Vanfis3,val_error3]=anfis(TrainData3,Tfis3,trnOpt,NaN,ValidData3);

figure('Name', 'Training Error Theta3');
plot(train_error3);
title('Training Error Theta 3');

figure('Name', 'Validation Error Theta3');
plot(val_error3);
title('Validation Error Theta 3');




%% Validation %%

% figure();
% [x,mf] = plotmf(Tanfis1,'input',1);
% plot(x,mf);
% title('Membership Functions after ANFIS Training (Theta 1)');
% % 
% figure();
% [x,mf] = plotmf(Tanfis2,'input',1);
% plot(x,mf);
% title('Membership Functions after ANFIS Training (Theta 2)');
% 
% figure();
% [x,mf] = plotmf(Tanfis3,'input',1);
% plot(x,mf);
% title('Membership Functions after ANFIS Training (Theta 3)');

%% Testing anfis output on the XY data

XY = [X(:) Y(:)];

predTHETA1 = evalfis(XY,anfis1); % theta1 predicted by anfis1
predTHETA2 = evalfis(XY,anfis2); % theta2 predicted by anfis2
predTHETA3 = evalfis(XY,anfis3);



plot(TestData1(1,:),TestData1(2,:),'r.');
  axis equal;
  xlabel('X','fontsize',10)
  ylabel('Y','fontsize',10)
  
  
  
 %% Create set of tasks for arm to complete, to check error in end effector position
 
 %Pick up and place
 
 %circular
 
 