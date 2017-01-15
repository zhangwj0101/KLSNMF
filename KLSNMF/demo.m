clear all;

TrainX = load('E:\cls-acl10-processed_cutshortdoc\mydata_add_withtraintest\en_fr_books_dvd/Train.data');
TrainX = spconvert(TrainX);
TrainY = load('E:\cls-acl10-processed_cutshortdoc\mydata_add_withtraintest\en_fr_books_dvd/Train.label');
TrainY = TrainY';
TestX = load('E:\cls-acl10-processed_cutshortdoc\mydata_add_withtraintest\en_fr_books_dvd/Test.data');
TestX = spconvert(TestX);
%%
TestY = load('E:\cls-acl10-processed_cutshortdoc\mydata_add_withtraintest\en_fr_books_dvd/Test.label');
TestY = TestY';
[size(TrainX)]
[size(TestX)]
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
Results = LSFTL(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle);

return ;
% for tempalph=0:0.5:10
%     Results = MTrick(TrainX,TrainY,TestX,TestY,tempalph,beta,numK,numCircle);
%     [res] = xlsread(strcat('Results_alpha.xls'));
%     xlswrite(strcat('Results_alpha.xls'),[res;Results]);
% end
% return ;

Results = LSFTL(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle);
[res] = xlsread(strcat('Results.xls'));
xlswrite(strcat('Results.xls'),[res;Results]);
% x = 0:1:numCircle-1;
% figure
% plot(x,Results,'r');
% grid on
% xlabel('x');
% ylabel('Results');