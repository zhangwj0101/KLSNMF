function Results = LSFTL(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle)
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
K1 = 40;
%%%逻辑回归
TrainXY = scale_cols(TrainX,TrainY);
fprintf('......start to train logistic regression model.........\n');
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
ptemp = 1./(1 + exp(-wbest'*TrainX));
oriA = getResult(ptemp,TrainY);
fprintf('Test accuracy on source domain is :%g\n',oriA);
ptemp = 1./(1 + exp(-wbest'*TestX));

oriA = getResult(ptemp,TestY);
fprintf('Test accuracy on target domain is :%g\n',oriA);
Gt = [];
for i = 1:length(TestY)
    Gt(i,1) = ptemp(i);
    Gt(i,2) = 1 - ptemp(i);
end

%%%%逻辑回归结束

%%%NMF way
r = numK;
all = [TrainX TestX];
[m,n] = size(all);
Winit = abs(randn(m,r));
Hinit = abs(randn(r,n));
[W,H] = nmf(full(all),Winit,Hinit,0.0000000000001,25,8000);

for id=1:size(W,2)
    W(:,id) = W(:,id)/sum(W(:,id));
end
%%%%end NMF way
Fs = W;
Ft = Fs;
Gs = G0;
Xs = TrainX;
Xt = TestX;

for i = 1:size(TrainX,2)
    Xs(:,i) = Xs(:,i)/sum(Xs(:,i));
end
for i = 1:size(TestX,2)
    Xt(:,i) = Xt(:,i)/sum(Xt(:,i));
end



b = 1/(size(Gs,1));
%%%Init SS
SS = ones(size(Fs,2),size(Gs,2));
for i = 1:size(SS,1)
    SS(i,:) = SS(i,:)/sum(SS(i,:));
end
Ss = SS;
St = SS;

%%%Fs1,Fs,Ss1,Ss
Fs1 = W(:,1:K1);
Fs = W(:,K1+1:size(W,2));
Ft1 = Fs1;
Ft = Fs;

Ss1 = SS(1:K1,:);
Ss = SS(K1+1:size(SS,1),:);
St1 = Ss1;
St = Ss;

tempFs = [Fs1 Fs];
tempSs = [Ss1;Ss];
tempFt = [Ft1 Ft];
tempSt = [St1;St];

fvalue = 0;
v1 = trace(Xs'*Xs-2*Xs'*tempFs*tempSs*Gs'+Gs*tempSs'*tempFs'*tempFs*tempSs*Gs');
v2 = trace(Xt'*Xt-2*Xt'*tempFt*tempSt*Gt'+Gt*tempSt'*tempFt'*tempFt*tempSt*Gt');
v3 = alpha*trace(Fs1'*Fs1-2*Fs1'*Ft1+Ft1'*Ft1);
v4 = alpha*trace(Ss1'*Ss1-2*Ss1'*St1+St1'*St1);
fvalue = v1+v2+v3+v4;
tempf = 0;
for circleID = 1:numCircle
    
    %%%Fs1,Fs,Ss1,Ss
    %%%Fs1
    tempM = (Fs1*Ss1+Fs*Ss)*(Gs'*Gs)*Ss1' + alpha*Fs1;
    tempM1 = (Xs*Gs)*Ss1' + alpha*Ft1;
    for i = 1:size(Fs1,1)
        for j = 1:size(Fs1,2)
            if tempM(i,j)~=0
                Fs1(i,j) = Fs1(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fs1(i,j) = 0;
            end
        end
    end
    for i = 1:size(Fs1,2)
        if sum(Fs1(:,i))~= 0
            Fs1(:,i) = Fs1(:,i)/sum(Fs1(:,i));
        else
            for j = 1:size(Fs1,2)
                Fs1(i,j) = 1/(size(Fs1,2));
            end
        end
    end
    
    %%Ss1
    tempM = Fs1'*(Fs1*Ss1+ Fs*Ss)*(Gs'*Gs) + alpha *Ss1;
    tempM1 = Fs1'*(Xs*Gs) + alpha*St1;
    for i = 1:size(Ss1,1)
        for j = 1:size(Ss1,2)
            if tempM(i,j)~=0
                Ss1(i,j) = Ss1(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Ss1(i,j) = 0;
            end
        end
    end
    
    %%Fs
    tempM = (Fs1*Ss1+Fs*Ss)*(Gs'*Gs)*Ss';
    tempM1 = Xs*Gs*Ss';
    for i = 1:size(Fs,1)
        for j = 1:size(Fs,2)
            if tempM(i,j)~=0
                Fs(i,j) = Fs(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fs(i,j) = 0;
            end
        end
    end
    for i = 1:size(Fs,2)
        if sum(Fs(:,i))~= 0
            Fs(:,i) = Fs(:,i)/sum(Fs(:,i));
        else
            for j = 1:size(Fs,2)
                Fs(i,j) = 1/(size(Fs,2));
            end
        end
    end
    
    %%Ss
    tempM = (Fs'*(Fs1*Ss1+Fs*Ss)*Gs'*Gs);
    tempM1 = Fs'*Xs*Gs;
    for i = 1:size(Ss,1)
        for j = 1:size(Ss,2)
            if tempM(i,j)~=0
                Ss(i,j) = Ss(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Ss(i,j) = 0;
            end
        end
    end
    
    
    %%  Ft1
    tempM = (Ft1*St1+Ft*St)*Gt'*Gt*St1' + alpha*Ft1;
    tempM1 = Xt*Gt*St1'+alpha*Fs1;
    for i = 1:size(Ft1,1)
        for j = 1:size(Ft1,2)
            if tempM(i,j)~=0
                Ft1(i,j) = Ft1(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Ft1(i,j) =0;
            end
        end
    end
    for i = 1:size(Ft1,2)
        if sum(Ft1(:,i))~= 0
            Ft1(:,i) = Ft1(:,i)/sum(Ft1(:,i));
        else
            for j = 1:size(Ft1,2)
                Ft1(i,j) = 1/(size(Ft1,2));
            end
        end
    end
    
    %%St1
    %%将Ss直接给St然后再迭代操作
    %     St = Ss;
    %%%新加
    tempM = Ft1'*(Ft1*St1+Ft*St)*Gt'*Gt + alpha * St1;
    tempM1 = Ft1'*Xt*Gt + alpha*Ss1;
    for i = 1:size(St1,1)
        for j = 1:size(St1,2)
            if tempM(i,j)~=0
                St1(i,j) = St1(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                St1(i,j) = 0;
            end
        end
    end
    
    
    %%  Ft
    tempM = (Ft1*St1+Ft*St)*Gt'*Gt*St';
    tempM1 = Xt*Gt*St';
    for i = 1:size(Ft,1)
        for j = 1:size(Ft,2)
            if tempM(i,j)~=0
                Ft(i,j) = Ft(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Ft(i,j) =0;
            end
        end
    end
    for i = 1:size(Ft,2)
        if sum(Ft(:,i))~= 0
            Ft(:,i) = Ft(:,i)/sum(Ft(:,i));
        else
            for j = 1:size(Ft,2)
                Ft(i,j) = 1/(size(Ft,2));
            end
        end
    end
    
    %%St
    %%将Ss直接给St然后再迭代操作
    %     St = Ss;
    %%%新加
    tempM = Ft'*(Ft1*St1+Ft*St)*Gt'*Gt;
    tempM1 = Ft'*Xt*Gt;
    for i = 1:size(St,1)
        for j = 1:size(St,2)
            if tempM(i,j)~=0
                St(i,j) = St(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                St(i,j) = 0;
            end
        end
    end
    
    %% Gt
    tempFS = Ft1*St1+Ft*St;
    tempM = (Gt*tempFS'*tempFS);
    tempM1 = Xt'*tempFS;
    for i = 1:size(Gt,1)
        for j = 1:size(Gt,2)
            if tempM(i,j)~=0
                Gt(i,j) = Gt(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Gt(i,j) = 0;
            end
        end
    end
    for i = 1:size(Gt,1)
        if sum(Gt(i,:))~= 0
            Gt(i,:) = Gt(i,:)/sum(Gt(i,:));
        else
            for j = 1:size(Gt,2)
                Gt(i,j) = 1/(size(Gt,2));
            end
        end
    end
    
    tempFs = [Fs1 Fs];
    tempSs = [Ss1;Ss];
    tempFt = [Ft1 Ft];
    tempSt = [St1;St];
    v1 = trace(Xs'*Xs-2*Xs'*tempFs*tempSs*Gs'+Gs*tempSs'*tempFs'*tempFs*tempSs*Gs');
    v2 = trace(Xt'*Xt-2*Xt'*tempFt*tempSt*Gt'+Gt*tempSt'*tempFt'*tempFt*tempSt*Gt');
    v3 = alpha*trace(Fs1'*Fs1-2*Fs1'*Ft1+Ft1'*Ft1);
    v4 = alpha*trace(Ss1'*Ss1-2*Ss1'*St1+St1'*St1);
    fvalue = v1+v2+v3+v4;
    tempf = 0;
    if circleID == 1
        tempf = fvalue;
    end
    if circleID > 1
        if abs(tempf - fvalue) < 10^(-12)
            break;
        end
        tempf = fvalue;
    end
    
    pp = [];
    for i = 1:length(TestY)
        if sum(Gt(i,:))~= 0
            pp(1,i) = Gt(i,1)/sum(Gt(i,:));
        else
            pp(1,i) = 0.5;
        end
    end
    Results(circleID) = getResult(pp,TestY)*100;
    lvalues(circleID) = fvalue;
    
    fprintf('the %g iteration is %g, the max is %g. the value of objective is %g\n',circleID,getResult(pp,TestY),max(Results),fvalue);
end
tempRes = [Results;lvalues]
Results = tempRes;

% [res] = xlsread(strcat('iteration_F.xls'));
% xlswrite(strcat('iteration_F.xls'),[res;Results;lvalues]);
% x = 0:1:numCircle-1;
% figure
% plot(x,lvalues,'r');
% grid on
% xlabel('x');
% ylabel('Results');