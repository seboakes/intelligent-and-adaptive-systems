clc
clear
close all


%% library imports
import math.*
import pyplot.*



l1 = 10; % length of first arm link 
l2 = 10; % length of second arm link
l3 = 10;

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

%% Simple even data split into training and validation

dim=size(data1);
datTot=dim(1);

TrainData1=[];
ValidData1=[];

TrainData1 = data1(1,:);
ValidData1 = data1(2,:);

for i = 3:datTot
     
    if mod(i,2)==0   %check if i is even/odd
       TrainData1 = [TrainData1;data1(i,:)];
    else
       ValidData1 = [ValidData1;data1(i,:)];
    end
    
end


dim=size(data2);
datTot=dim(1);

TrainData2=[];
ValidData2=[];

% TrainData2 = data2(1,:);
% ValidData2 = data2(2,:);

for i = 1:datTot
     
    if mod(i,2)==0   %check if i is even/odd
       TrainData2 = [TrainData2;data2(i,:)];
    else
       ValidData2 = [ValidData2;data2(i,:)];
    end
    
end


dim=size(data3);
datTot=dim(1);

TrainData3=[];
ValidData3=[];

TrainData3 = data3(1,:);
ValidData3 = data3(2,:);

for i = 3:datTot
     
    if mod(i,2)==0   %check if i is even/odd
       TrainData3 = [TrainData3;data3(i,:)];
    else
       ValidData3 = [ValidData3;data3(i,:)];
    end
    
end


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
genOpt.InputMembershipFunctionType = ["trimf" "trimf"];   %set MF types
genOpt.NumMembershipFunctions = 4;    %set MF number
initFIS = genfis(TrainData1(:,1:2),TrainData1(:,3), genOpt);


opt = anfisOptions('InitialFIS', initFIS);
opt.DisplayANFISInformation = 1;  
opt.ValidationData = ValidData1;   %set validation data set

eNum = 200;
epochTally1 = (1:eNum)';
opt.EpochNumber = eNum;
disp('training first anfis network (for theta1)');
[fis1,trainError1,~,chkFIS,chkError1] = anfis(TrainData1,opt);   %begin anfis training





% In the above:
% fis1 is the tuned FIS at the end of training
% trainError is the RMS error in training set.
% stepSize is the step size at each epoch, returned as a list.
% chkFIS is a FIS with parameters that match the point of lowest validation error.
% chkError is the validation RMS error

% 
% disp('training second anfis network (for theta2)');
% genOpt.NumMembershipFunctions = 2;
% initFIS = genfis(TrainData2(:,1:2),TrainData2(:,3), genOpt);
% opt = anfisOptions('InitialFIS', initFIS);
% opt.ValidationData = ValidData2;
% eNum = 200;
% epochTally2 = (1:eNum)';
% opt.EpochNumber = eNum;
% [fis2,trainError2,~,chkFIS2,chkError2] = anfis(TrainData2,opt);


% disp('training third anfis network (for theta3)');
% genOpt.NumMembershipFunctions = 2;
% initFIS = genfis(TrainData3(:,1:2),TrainData3(:,3), genOpt);
% opt = anfisOptions('InitialFIS', initFIS);
% opt.ValidationData = ValidData3;
% eNum = 280;
% epochTally3 = (1:eNum)';
% opt.EpochNumber = eNum;
% [fis3,trainError3,~,chkFIS3,chkError3] = anfis(TrainData3,opt);

% figure();
% [x,mf] = plotmf(chkFIS,'input',1);
% plot(x,mf);
% title('Membership Functions after ANFIS Training (Theta 1)');
% 
% figure();
% [x,mf] = plotmf(fis1,'input',1);
% plot(x,mf);
% title('Membership Functions after ANFIS Training (Theta 1)');

figure();
plot(epochTally1,trainError1,  epochTally1, chkError1);
legend('training error','validation error');
title('Training vs Validation Error for data set 1');

% figure();
% plot(epochTally2,trainError2,  epochTally2, chkError2);
% legend('training error','validation error');
% title('Training vs Validation Error for data set 2');
% 
% figure();
% plot(epochTally3,trainError3,  epochTally3, chkError3);
% legend('training error','validation error');
% title('Training vs Validation Error for data set 3');

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

