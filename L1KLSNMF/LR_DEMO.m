clear all;
str = 'E:\cls-acl10-processed_cutshortdoc\test_iteration\en_de_books_music/';
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

Vs = csvread('amazon-GNMF-v.csv');
Vt = csvread('amazon-GNMF-tv.csv');
%%%Âß¼­»Ø¹é
TrainXY = scale_cols(Vs',TrainY);
%     fprintf('......start to train logistic regression model.........\n');
w00 = zeros(size(TrainXY,1),1);
lambda = exp(linspace(-0.5,6,20));
wbest = [];
f1max = -inf;
for i = 1:length(lambda)
    w_0 = train_cg(TrainXY,w00,lambda(i));
    f1 = logProb(TrainXY,w_0);
    if f1 > f1max
        f1max = f1;
        wbest = w_0;
        se_lambda = lambda(i);
    end
end
ptemp = 1./(1 + exp(-wbest'*Vs'));
oriA = getResult(ptemp,TrainY);
%     fprintf('Test accuracy on source domain is :%g\n',oriA);
%%TEst
ptemp = 1./(1 + exp(-wbest'*Vt'));
oritest = getResult(ptemp,TestY);
fprintf(' Test accuracy on source domain is :%g ,Test accuracy on target domain is :%g\n',oriA,oritest);