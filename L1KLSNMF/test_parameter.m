clear all;
addpath(genpath('lib\lightspeed'));
addpath(genpath('lib\logreg'));
addpath(genpath('lib\tSNE'));
base='E:\cls-acl10-processed_cutshortdoc\mydata_add_withtraintest\en_de_books_books\';
TrainX = load(strcat(base,'Train.data'));
TrainX = spconvert(TrainX);
TrainY = load(strcat(base,'Train.label'));
TrainY = TrainY';
TestX = load(strcat(base,'Test.data'));
TestX = spconvert(TestX);
%%
TestY = load(strcat(base,'Test.label'));
TestY = TestY';

for id = 1:length(TrainY)
    if TrainY(id) == 2
        TrainY(id) = -1;
    end
end

for id = 1:length(TestY)
    if TestY(id) == 2
        TestY(id) = -1;
    end
end

alpha = 1.5;
beta = 1.5;
gamma = 1.5;
delta= 1.5;
numK = 50;
similarK = 20;
numCircle = 180;
best = [];
index= 1;
xlswrite(strcat('paramter.xls'),['a','b','g','d','m']);

for alpha=1:0.5:3
    for beta=1:0.5:3
        for gamma=1:0.5:3
            for delta=1:0.5:3
                Results = L1SFTL(TrainX,TrainY,TestX,TestY,alpha,beta,gamma,delta,numK,similarK,numCircle);
                [res] = xlsread(strcat('paramter.xls'));
                temp = [alpha,beta,gamma,delta,max(Results(1,:))];
                xlswrite(strcat('paramter.xls'),[res;temp]);
            end
        end
    end
end

