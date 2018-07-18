clc
clear
%close all


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

resultsFull=[];

for i=1:length(theta1)
    for j = 1:length(theta2)
        for k = 1:length(theta3);
            
            THETA1=0+0.1*i;
            THETA2= 0+0.1*j;
            THETA3 = 0+0.1*k;
            
            
            X = (l1*cos(THETA1))+(l2*cos(THETA1+THETA2))+(l3*cos(THETA1+THETA2+THETA3));          % compute x coordinates 
            Y = (l1*sin(THETA1))+(l2*sin(THETA1+THETA2))+(l3*sin(THETA1+THETA2+THETA3)); % compute y coordinates
            
            resultsList(1)=THETA1;
            resultsList(2)=THETA2;
            resultsList(3)=THETA3;
            resultsList(4)=X;
            resultsList(5)=Y;
            
            resultsFull = [resultsFull;resultsList];
            
            

        end
    end
end




% X = (l1*cos(THETA1))+(l2*cos(THETA1+THETA2))+(l3*cos(THETA1+THETA2+THETA3));          % compute x coordinates 
% Y = (l1*sin(THETA1))+(l2*sin(THETA1+THETA2))+(l3*sin(THETA1+THETA2+THETA3)); % compute y coordinates
% phi = THETA1+THETA2+THETA3;


%%%create data sets - X and Y form inputs, THETA the output.
data1 = [resultsFull(:,4) resultsFull(:,5) resultsFull(:,1)]; % create x-y-theta dataset for all link angles
data2 = [resultsFull(:,4) resultsFull(:,5) resultsFull(:,2)]; 
data3 = [resultsFull(:,4) resultsFull(:,5) resultsFull(:,3)];

% data2 = sortrows(data2,3);  %sorts results by 
% data3 = sortrows(data3,3);


% [m,n] = size(data1) ;
% idx = randperm(n) ;
% b = data1 ;
% b(1,idx) = data1(1,:)  % first row arranged randomly 


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



  




ResultsArray1 = [];
ResultsArray2 = [];
ResultsArray3 = [];


    %%% 1st   %%%
    
    genOpt = genfisOptions('GridPartition');  %declare the use of the genfis options 
    genOpt.NumMembershipFunctions = 4;
    
    genOpt.InputMembershipFunctionType = ["trimf"];

    initFIS1 = genfis(TrainData1(:,1:2),TrainData1(:,3), genOpt);
    opt = anfisOptions('InitialFIS', initFIS1);
    opt.ValidationData = ValidData1;
    opt.DisplayFinalResults = 1;
    opt.DisplayStepSize = 0;
    opt.DisplayErrorValues = 0;
    eNum = 400;
    epochTally1 = (1:eNum)';
    opt.EpochNumber = eNum;
    [fis1,trainError1,~,chkFIS1,chkError1] = anfis(TrainData1,opt);
    ResultsArray1(i,1) = i;
    ResultsArray1(i,2) = min(chkError1);
    disp('iteration complete')
    pause(1);
    
            figure();
    plot(epochTally1,trainError1,  epochTally1, chkError1);
    legend('training error','validation error');
    title(['Theta Training and validation error, with ',num2str(i),' MFs'])
    
    
    %% 2nd  %%%
    genOpt = genfisOptions('GridPartition');  %declare the use of the genfis options 
    genOpt.NumMembershipFunctions = 4;

    genOpt.InputMembershipFunctionType = ["gaussmf"];
    initFIS2 = genfis(TrainData2(:,1:2),TrainData2(:,3), genOpt);
    
    opt = anfisOptions('InitialFIS', initFIS2);
    opt.ValidationData = ValidData2;
    eNum = 200;
    epochTally2 = (1:eNum)';
    opt.EpochNumber = eNum;
    [fis2,trainError2,~,chkFIS2,chkError2] = anfis(TrainData2,opt);
    ResultsArray2(i,1) = i;
    ResultsArray2(i,2) = min(chkError2);
    disp('iteration complete')
    pause(1);
    
            figure();
    plot(epochTally2,trainError2,  epochTally2, chkError2);
    legend('training error','validation error');
    title(['Theta 2 Training and validation error, with ',num2str(i),' MFs'])
    
    %% 3rd %%%
    
    genOpt = genfisOptions('GridPartition');  %declare the use of the genfis options          
    genOpt.NumMembershipFunctions = 4;

    genOpt.InputMembershipFunctionType = ["gaussmf"];
    initFIS3 = genfis(TrainData3(:,1:2),TrainData3(:,3), genOpt);
%     
    opt = anfisOptions('InitialFIS', initFIS3);
    opt.ValidationData = ValidData3;
    eNum = 400;
    epochTally3 = (1:eNum)';
    opt.EpochNumber = eNum;
    [fis3,trainError3,~,chkFIS3,chkError3] = anfis(TrainData3,opt);
    ResultsArray3(i,1) = i;
    ResultsArray3(i,2) = min(chkError3);
    disp('iteration complete')
    pause(1);
    
            figure();
    plot(epochTally3,trainError3,  epochTally3, chkError3);
    legend('training error','validation error');
    title(['Theta 3 Training and validation error, with ',num2str(i),' MFs'])
    
    
    

clear('initFIS1', 'initFIS2', 'initFIS3' );


% figure();
% [x,mf] = plotmf(chkFIS,'input',1);
% plot(x,mf);
% title('Membership Functions after ANFIS Training (Theta 1)');
% 
% figure();
% [x,mf] = plotmf(fis1,'input',1);
% plot(x,mf);
% title('Membership Functions after ANFIS Training (Theta 1)');

