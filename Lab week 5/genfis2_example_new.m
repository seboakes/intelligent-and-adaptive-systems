
% In this example we apply the genfis function with Subtractive Clustering to model the relationship between the number of automobile trips generated from an area and the area's 
% demographics.
% Demographic and trip data are from 100 traffic analysis zones in New Castle County, Delaware. Five demographic factors are considered:
% population, number of dwelling units, vehicle ownership, median household income, and total employment.
% Hence the model has five input variables and one output variable. 


mytripdata
subplot(2,1,1), plot(datin)
subplot(2,1,2), plot(datout)
 
opt = genfisOptions('SubtractiveClustering',...
                    'ClusterInfluenceRange',0.5);
                
% fismat=genfis2(datin,datout,0.5); % this was the old version

fismat=genfis(datin,datout,opt); % generate initial FIS using subtractive clustering to reduce the number of membership functions


fuzout=evalfis(datin,fismat);
trnRMSE=norm(fuzout-datout)/sqrt(length(fuzout));
chkfuzout=evalfis(chkdatin,fismat);
chkRMSE=norm(chkfuzout-chkdatout)/sqrt(length(chkfuzout))

figure
plot(chkdatout)
hold on
plot(chkfuzout,'o')
hold off

%At this point, we can use the optimization capability of anfis to improve the model.
% First, we will try using a relatively short anfis training (20 epochs) 
% without implementing the checking data option, but test the resulting FIS model against the test data.
%  The command-line version of this is as follows.

fismat2=anfis([datin datout],fismat,[20 0 0.1]);

%After the training is done, we type

    fuzout2=evalfis(datin,fismat2);
    trnRMSE2=norm(fuzout2-datout)/sqrt(length(fuzout2));
   
    chkfuzout2=evalfis(chkdatin,fismat2);
    chkRMSE2=norm(chkfuzout2-chkdatout)/sqrt(length(chkfuzout2));

 figure
 plot(chkdatout)
 hold on
 plot(chkfuzout2,'o')
 hold off


% what happens if we carry out a longer (200 epoch) training of this system using anfis, including its checking data option.

[fismat3,trnErr,stepSize,fismat4,chkErr]= ...
        anfis([datin datout],fismat2,[200 0 0.1],[], ...
        [chkdatin chkdatout]);

    figure
plot(trnErr)
title('Training Error')
xlabel('Number of Epochs')
ylabel('Training Error')

figure
plot(chkErr)
title('Checking Error')
xlabel('Number of Epochs')
ylabel('Checking Error')

