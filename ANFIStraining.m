function [anfis, train_error,valid_anfis,val_error] = ANFIStraining(trainData,Tfis1,trnOpt,valid_data)

%function for training anfis network using input data


[anfis,train_error,~,valid_anfis,val_error]=anfis(train_data,train_fis,trnOpt,NaN,valid_data);


end