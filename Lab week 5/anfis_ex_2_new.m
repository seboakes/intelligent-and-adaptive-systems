clear all;
close all;
 numPts=51;
 x=linspace(-1,1,numPts)';
 y=0.6*sin(pi*x)+0.3*sin(3*pi*x)+0.1*sin(5*pi*x);
 data=[x y];
 trndata=data(1:2:numPts,:);
 chkdata=data(2:2:numPts,:);

plot(trndata(:,1),trndata(:,2),'o',chkdata(:,1),chkdata(:,2),'x')



%  numMFs=8;
%  mfType='gbellmf';
%  fismat = genfis1(trndata, numMFs,mfType);
 

opt = genfisOptions('GridPartition');
opt.NumMembershipFunctions = 7;
opt.InputMembershipFunctionType = "gaussmf";

 fismat=(genfis(trndata(:,1),trndata(:,2),opt))
 figure
 [x,mf]=plotmf(fismat,'input',1);
 plot(x,mf)

 numEpochs=40;

[fismat1,trnErr,ss,fismat2,chkErr]=anfis(trndata,fismat,numEpochs,NaN,chkdata);  % calling ANFIS, feeding in training and validation data
% note that validation data is simply an even split of data set, every even
% number

 trnOut=evalfis(trndata(:,1),fismat1);
 trnRMSE=norm(trnOut-trndata(:,2))/sqrt(length(trnOut))

 chkOut=evalfis(chkdata(:,1),fismat2);
 chkRMSE=norm(chkOut-chkdata(:,2))/sqrt(length(chkOut))
 epoch=1:numEpochs;

 figure
 plot(epoch,trnErr,'o',epoch,chkErr,'x')
 hold on;
 plot(epoch,[trnErr chkErr])
 hold off;

 figure
 plot(epoch,ss,'-',epoch,ss,'x')

 
 [x,mf]=plotmf(fismat1,'input',1);
 figure
 plot(x,mf)
 

 anfis_y=evalfis(x(:,1),fismat1);
 
 figure
 plot(trndata(:,1), trndata(:,2),'o',chkdata(:,1),chkdata(:,2),'x',x,anfis_y,'-')

