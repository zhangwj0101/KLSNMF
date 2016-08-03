clear all;
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
numK = 50;
numCircle = 180;
best = [];
index= 1;
Results = L1SFTL(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle);

