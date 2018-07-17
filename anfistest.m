clc
clear
close all


%% library imports
import math.*
import pyplot.*



l1 = 10; % length of first arm link 
l2 = 7; % length of second arm link
l3 = 4;

% 
theta1 = 0:0.1:pi/2; % joint ranges
theta2 = 0:0.1:pi; 
theta3 = 0:0.1:pi; 


% theta1 = 0:0.2:pi/2; % joint ranges
% theta2 = 0:0.2:pi; 
% theta3 = 0:0.2:pi; 
[THETA1, THETA2, THETA3] = meshgrid(theta1, theta2, theta3); % generate a grid of theta1, theta2 and theta3 values




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

valid_frac = 0.5;% values used to determine the fraction of total data to be used for validation and test, thus allowing me to vary it as necessary.
test_frac = 0.1; 
comb_frac = valid_frac+test_frac;

dim=size(data1);
datTot=dim(1);


%mulitplies by the fraction denoting the desired quantity of validation data points, and creates two distinct groups
%index used to denote either 1 or 0
idx = randperm(datTot);   % Randomise ordering of the data points, whilst retaining an index relating 
indexToGroup1 = (idx<=valid_frac*datTot);  %validation data
indexToGroup2 = (idx<=comb_frac*datTot & idx>valid_frac*datTot);   % test data
%indexToGroup3 = (idx>comb_frac*datTot); %training data
indexToGroup3 = (idx>valid_frac*datTot);
                                            
                                            
ValidData1 = data1(indexToGroup1,:); %creates validation data set using index and original data set
TrainData1 = data1(indexToGroup3,:); %creates training data set 
TestData1 = data1(indexToGroup2,:);

%-----%

dim=size(data2);
datTot=dim(1);

idx = randperm(datTot);   % Randomise ordering of the data points, whilst retaining an index relating 
indexToGroup1 = (idx<=valid_frac*datTot);  %validation data
indexToGroup2 = (idx<=comb_frac*datTot & idx>valid_frac*datTot);   % test data
%indexToGroup3 = (idx>comb_frac*datTot); %training data
indexToGroup3 = (idx>valid_frac*datTot);



ValidData2 = data2(indexToGroup1,:); %creates validation data set using index and original data set
TrainData2 = data2(indexToGroup3,:); %creates training data set 
TestData2 = data2(indexToGroup2,:);

%-----%

dim=size(data3);
datTot=dim(1);

idx = randperm(datTot);   % Randomise ordering of the data points, whilst retaining an index relating 
indexToGroup1 = (idx<=valid_frac*datTot);  %validation data
indexToGroup2 = (idx<=comb_frac*datTot & idx>valid_frac*datTot);   % test data
%indexToGroup3 = (idx>comb_frac*datTot); %training data
indexToGroup3 = (idx>valid_frac*datTot);



ValidData3 = data3(indexToGroup1,:); %creates validation data set using index and original data set
TrainData3 = data3(indexToGroup3,:); %creates training data set 
TestData3 = data3(indexToGroup2,:);

%% Plot data sets to ensure full coverage of workspace
%  figure();
%  plot(TrainData1(:,1),TrainData1(:,2),'r.');
%   axis equal;
%   xlabel('X','fontsize',10);
%   ylabel('Y','fontsize',10);
%   title('All training data points');
% 
%   figure();
%    plot(ValidData1(:,1),ValidData1(:,2),'r.');
%   axis equal;
%   xlabel('X','fontsize',10);
%   ylabel('Y','fontsize',10);
%   title('All validation data points');

%%

genOpt = genfisOptions('GridPartition');  %declare the use of the genfis options 

genOpt.InputMembershipFunctionType = ["trimf" "trimf"];
genOpt.NumMembershipFunctions = 2;
initFIS = genfis(TrainData1(:,1:2),TrainData1(:,3), genOpt);


opt = anfisOptions('InitialFIS', initFIS);

opt.DisplayANFISInformation = 1;  
opt.ValidationData = ValidData1;  






opt.ValidationData = ValidData1;
eNum = 200;
epochTally1 = (1:eNum)';
opt.EpochNumber = eNum;
disp('training first anfis network (for theta1)');

[fis1,trainError1,~,chkFIS,chkError1] = anfis(TrainData1,opt);
% In the above:
% fis1 is the tuned FIS at the end of training
% trainError is the RMS error in training set.
% stepSize is the step size at each epoch, returned as a list.
% chkFIS is a FIS with parameters that match the point of lowest validation error.
% chkError is the validation RMS error


disp('training second anfis network (for theta2)');
genOpt.NumMembershipFunctions = 2;
initFIS = genfis(TrainData2(:,1:2),TrainData2(:,3), genOpt);
opt = anfisOptions('InitialFIS', initFIS);
opt.ValidationData = ValidData2;
eNum = 200;
epochTally2 = (1:eNum)';
opt.EpochNumber = eNum;
[fis2,trainError2,~,chkFIS2,chkError2] = anfis(TrainData2,opt);


disp('training third anfis network (fortheta3)');
genOpt.NumMembershipFunctions = 2;
initFIS = genfis(TrainData3(:,1:2),TrainData3(:,3), genOpt);
opt = anfisOptions('InitialFIS', initFIS);
opt.ValidationData = ValidData3;
eNum = 280;
epochTally3 = (1:eNum)';
opt.EpochNumber = eNum;
[fis3,trainError3,~,chkFIS3,chkError3] = anfis(TrainData3,opt);

figure();
plot(epochTally1,trainError1,  epochTally1, chkError1);
legend('training error','validation error');
title('Training vs Validation Error for data set 1');

figure();
plot(epochTally2,trainError2,  epochTally2, chkError2);
legend('training error','validation error');
title('Training vs Validation Error for data set 2');

figure();
plot(epochTally3,trainError3,  epochTally3, chkError3);
legend('training error','validation error');
title('Training vs Validation Error for data set 3');

% figure();
% [x,mf] = plotmf(chkFIS,'input',1);
% plot(x,mf);
% title('Membership Functions after ANFIS Training (Theta 1)');
% 
% figure();
% [x,mf] = plotmf(fis1,'input',1);
% plot(x,mf);
% title('Membership Functions after ANFIS Training (Theta 1)');


%% Test data trials
% 
% xpos = linspace(-5,10,100);
% ypos = linspace(5,15,100);
% testPath = [xpos' ypos'];
% 
% figure();
% predTHETA1 = evalfis(testPath, chkFIS);
% 
% theta1diff = testPath - predTHETA1;
% plot(theta1diff);

