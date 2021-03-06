clear all;
str = 'E:\cls-acl10-processed_cutshortdoc\mydata_add_withtraintest\en_de_books_books/';
TrainX = load(strcat(str,'Train.data'));
TrainX = spconvert(TrainX);
TrainY = load(strcat(str,'Train.label'));
TrainY = TrainY';
TestX = load(strcat(str,'Test.data'));
TestX = spconvert(TestX);
%%
TestY = load(strcat(str,'Test.label'));
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
beta = 0.5;
numK = 50;
numCircle = 180;
best = [];
index= 1;
Results = KLSNMF(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle);