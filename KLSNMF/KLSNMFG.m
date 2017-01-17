function Results = KLSNMFG(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle)
%%% 联合训练 列为一
G0 = [];

for i = 1:length(TrainY)
    if TrainY(i) == 1
        G0(i,1) = 1;
        G0(i,2) = 0;
    else
        G0(i,1) = 0;
        G0(i,2) = 1;
    end
end

Gt = [];
for i = 1:length(TestY)
    if TestY(i) == 1
        Gt(i,1) = 1;
        Gt(i,2) = 0;
    else
        Gt(i,1) = 0;
        Gt(i,2) = 1;
    end
end
% %%%逻辑回归
% TrainXY = scale_cols(TrainX,TrainY);
% fprintf('......start to train logistic regression model.........\n');
% w00 = zeros(size(TrainXY,1),1);
% lambda = exp(linspace(-0.5,6,20));
% wbest = [];
% f1max = -inf;
% for i = 1:length(lambda)
%     w_0 = train_cg(TrainXY,w00,lambda(i));
%     f1 = logProb(TrainXY,w_0);
%     if f1 > f1max
%         f1max = f1;
%         wbest = w_0;
%         se_lambda = lambda(i);
%     end
% end
% ptemp = 1./(1 + exp(-wbest'*TrainX));
% oriA = getResult(ptemp,TrainY);
% fprintf('Test accuracy on source domain is :%g\n',oriA);
% ptemp = 1./(1 + exp(-wbest'*TestX));
%
% oriA = getResult(ptemp,TestY);
% fprintf('Test accuracy on target domain is :%g\n',oriA);
% Gt = [];
% for i = 1:length(TestY)
%     Gt(i,1) = ptemp(i);
%     Gt(i,2) = 1 - ptemp(i);
% end
%%%%逻辑回归结束

r = numK;
U = abs(randn(size(TrainX,1),r));
Vs = abs(randn(size(TrainX,2),r));
Vt = abs(randn(size(TestX,2),r));
for id=1:size(U,2)
    U(:,id) = U(:,id)/sum(U(:,id));
end
Us = U;
Ut = Us;
Gs = G0;
Xs = TrainX;
Xt = TestX;
for i = 1:size(TrainX,2)
    Xs(:,i) = Xs(:,i)/sum(Xs(:,i));
end
for i = 1:size(TestX,2)
    Xt(:,i) = Xt(:,i)/sum(Xt(:,i));
end
options = [];
options.WeightMode = 'Cosine';  
Ws = constructW(Xs',options);
Wt = constructW(Xt',options);
Ds = zeros(size(Ws));
Dt = zeros(size(Wt));
for i = 1:size(Ws,1)
    Ds(i,i) = sum(Ws(i,:));
end
for i = 1:size(Wt,1)
    Dt(i,i) = sum(Wt(i,:));
end
par = 1.5;
for circleID = 1:numCircle
    
    %%Us
    tempM = Us*Vs'*Vs+par*Us;
    tempM1 = Xs*Vs + par * Ut;
    for i = 1:size(Us,1)
        for j = 1:size(Us,2)
            if tempM(i,j)~=0
                Us(i,j) = Us(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Us(i,j) = 0;
            end
        end
    end
    for i = 1:size(Us,2)
        if sum(Us(:,i))~= 0
            Us(:,i) = Us(:,i)/sum(Us(:,i));
        else
            for j = 1:size(Us,2)
                Us(i,j) = 1/(size(Us,2));
            end
        end
    end
    
    %%Vs
    tempM = Vs*Us'*Us+par*Ds*Vs;
    tempM1 = Xs'*Us +par*Ws*Vs;
    for i = 1:size(Vs,1)
        for j = 1:size(Vs,2)
            if tempM(i,j)~=0
                Vs(i,j) = Vs(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Vs(i,j) = 0;
            end
        end
    end
    
    %%  Ut
    tempM = Ut*Vt'*Vt+par*Ut;
    tempM1 = Xt*Vt + par * Us;
    for i = 1:size(Ut,1)
        for j = 1:size(Ut,2)
            if tempM(i,j)~=0
                Ut(i,j) = Ut(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Ut(i,j) = 0;
            end
        end
    end
     for i = 1:size(Ut,2)
        if sum(Ut(:,i))~= 0
            Ut(:,i) = Ut(:,i)/sum(Ut(:,i));
        else
            for j = 1:size(Ut,2)
                Ut(i,j) = 1/(size(Ut,2));
            end
        end
    end
    %%Vt
    tempM = Vt*Ut'*Ut+par*Dt*Vt;
    tempM1 = Xt'*Ut +par*Wt*Vt;
    for i = 1:size(Vt,1)
        for j = 1:size(Vt,2)
            if tempM(i,j)~=0
                Vt(i,j) = Vt(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Vt(i,j) = 0;
            end
        end
    end
    
    %%%逻辑回归
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
    fprintf('%g: Test accuracy on source domain is :%g ,Test accuracy on target domain is :%g\n',circleID,oriA,oritest);
end
tempRes = [Results;lvalues]
Results = tempRes;
