function Results = L1SFTL(TrainX,TrainY,TestX,TestY,alpha,beta,gamma,delta ,numK,similarK,numCircle)
similarK =  int32(similarK);
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
Gs = G0;

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

% 对Xs和Xt进行归一化
Xs = TrainX;
Xt = TestX;
for i = 1:size(TrainX,2)
    Xs(:,i) = Xs(:,i)/sum(Xs(:,i));
end
for i = 1:size(TestX,2)
    Xt(:,i) = Xt(:,i)/sum(Xt(:,i));
end

%F,S随机初始化开始
W = abs(randn(size(TrainX,1),numK));
for id=1:size(W,2)
    W(:,id) = W(:,id)/sum(W(:,id));
end

%%%NMF way
% r = numK;
% all = [TrainX TestX];
% [m,n] = size(all);
% Winit = abs(randn(m,r));
% Hinit = abs(randn(r,n));
% [W,H] = nmf(full(all),Winit,Hinit,0.0000000000001,25,8000);
% 
% for id=1:size(W,2)
%     W(:,id) = W(:,id)/sum(W(:,id));
% end
%%%%end NMF way
%%%Fss,Fsd
Fss = W(:,1:similarK);
Fsd = W(:,similarK+1:size(W,2));
Fts = Fss;
Ftd = Fsd;

%%%Init SS
SS = ones(size(W,2),size(Gs,2));
% SS = abs(randn(size(W,2),size(Gs,2)));
for i = 1:size(SS,1)
    SS(i,:) = SS(i,:)/sum(SS(i,:));
end
%%%Sss,Ssd
Sss = SS(1:similarK,:);
Ssd = SS(similarK+1:size(SS,1),:);
Sts = Sss;
Std = Ssd;

tempFs = [Fss Fsd];
tempSs = [Sss;Ssd];
tempFt = [Fts Ftd];
tempSt = [Sts;Std];
v1 = trace(Xs'*Xs-2*Xs'*tempFs*tempSs*Gs'+Gs*tempSs'*tempFs'*tempFs*tempSs*Gs');
v2 = trace(Xt'*Xt-2*Xt'*tempFt*tempSt*Gt'+Gt*tempSt'*tempFt'*tempFt*tempSt*Gt');
v3 = alpha*trace(Fss'*Fss-2*Fss'*Fts+Fts'*Fts);
v4 = beta*trace(Sss'*Sss-2*Sss'*Sts+Sts'*Sts);
v5 = gamma *sum(sum(Fsd))+gamma *sum(sum(Ftd)) + delta * sum(sum(Ssd))+ delta * sum(sum(Std));
fvalue = v1+v2+v3+v4+v5;
tempf = 0;
gradient = 1;
% 开始进行迭代
for circleID = 1:numCircle
    
    %%%Fss
    tempM = (Fss*Sss+Fsd*Ssd)*(Gs'*Gs)*Sss' + alpha*Fss;
    tempM1 = (Xs*Gs)*Sss' + alpha*Fts;
    for i = 1:size(Fss,1)
        for j = 1:size(Fss,2)
            if tempM(i,j)~=0
                Fss(i,j) = Fss(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fss(i,j) = 0;
            end
        end
    end
    for i = 1:size(Fss,2)
        if sum(Fss(:,i))~= 0
            Fss(:,i) = Fss(:,i)/sum(Fss(:,i));
        else
            for j = 1:size(Fss,2)
                Fss(i,j) = 1/(size(Fss,2));
            end
        end
    end
    %%Sss
    tempM = Fss'*(Fss*Sss+ Fsd*Ssd)*(Gs'*Gs) + beta *Sss;
    tempM1 = Fss'*(Xs*Gs) + beta*Sts;
    for i = 1:size(Sss,1)
        for j = 1:size(Sss,2)
            if tempM(i,j)~=0
                Sss(i,j) = Sss(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                 fprintf('the Sss is %g\n',tempM(i,j));
                Sss(i,j) = 0;
            end
        end
    end
    
    %%Fsd
    tempM = 2*(Fss*Sss+Fsd*Ssd)*(Gs'*Gs)*Ssd';
    tempM1 = 2*(Xs)*Gs*Ssd';
    for i = 1:size(Fsd,1)
        for j = 1:size(Fsd,2)
%             if Fsd(i,j) > Ftd(i,j)
%                 gradient = 1;
%             else
%                 gradient = -1;
%             end
            tempMu = tempM(i,j) +gamma*gradient;
            if tempMu > 0
                Fsd(i,j) = Fsd(i,j)*(tempM1(i,j)/tempMu)^(0.5);
            else
                fprintf('the Fsd is %g\n',tempMu(i,j));
                Fsd(i,j) = 0;
            end
        end
    end
    for i = 1:size(Fsd,2)
        if sum(Fsd(:,i))~= 0
            Fsd(:,i) = Fsd(:,i)/sum(Fsd(:,i));
        else
            for j = 1:size(Fsd,2)
                Fsd(i,j) = 1/(size(Fsd,2));
            end
        end
    end
    
    %%Ssd
    tempM = 2*(Fsd'*(Fss*Sss+Fsd*Ssd)*Gs'*Gs);
    tempM1 = 2*Fsd'*(Xs)*Gs;
    for i = 1:size(Ssd,1)
        for j = 1:size(Ssd,2)
%             if Ssd(i,j) >= Std(i,j)
%                 gradient = 1;
%             else
%                 gradient = -1;
%             end
            tempMu = tempM(i,j) + delta*gradient;
            if tempMu > 0
                Ssd(i,j) = Ssd(i,j)*(tempM1(i,j)/tempMu)^(0.5);
            else
                fprintf('the Ssd is %g\n',tempMu);
                Ssd(i,j) = 0;
            end
        end
    end
    
    %%  Fts
    tempM = (Fts*Sts+Ftd*Std)*Gt'*Gt*Sts' + alpha*Fts;
    tempM1 = Xt*Gt*Sts'+alpha*Fss;
    for i = 1:size(Fts,1)
        for j = 1:size(Fts,2)
            if tempM(i,j)~=0
                Fts(i,j) = Fts(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                fprintf('the Fts is %g\n',tempM(i,j));
                Fts(i,j) =0;
            end
        end
    end
    for i = 1:size(Fts,2)
        if sum(Fts(:,i))~= 0
            Fts(:,i) = Fts(:,i)/sum(Fts(:,i));
        else
            for j = 1:size(Fts,2)
                Fts(i,j) = 1/(size(Fts,2));
            end
        end
    end
    
    %%Sts
    tempM = Fts'*(Fts*Sts+Ftd*Std)*Gt'*Gt + beta * Sts;
    tempM1 = Fts'*Xt*Gt + beta*Sss;
    for i = 1:size(Sts,1)
        for j = 1:size(Sts,2)
            if tempM(i,j)~=0
                Sts(i,j) = Sts(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                fprintf('the Sts is %g\n',tempM(i,j));
                Sts(i,j) = 0;
            end
        end
    end
    
    %%  Ftd
    tempM = 2*(Fts*Sts+Ftd*Std)*Gt'*Gt*Std';
    tempM1 = 2*(Xt)*Gt*Std';
    for i = 1:size(Ftd,1)
        for j = 1:size(Ftd,2)
%             if Ftd(i,j) > Fsd(i,j)
%                 gradient = 1;
%             else
%                 gradient = -1;
%             end
            tempMu = tempM(i,j) + gamma*gradient;
            if tempMu > 0
                Ftd(i,j) = Ftd(i,j)*(tempM1(i,j)/tempMu)^(0.5);
            else
                fprintf('the Ftd is %g\n',tempMu);
                Ftd(i,j) =0;
            end
        end
    end
    for i = 1:size(Ftd,2)
        if sum(Ftd(:,i))~= 0
            Ftd(:,i) = Ftd(:,i)/sum(Ftd(:,i));
        else
            for j = 1:size(Ftd,2)
                Ftd(i,j) = 1/(size(Ftd,2));
            end
        end
    end
    
    %%Std
    tempM = 2*Ftd'*(Fts*Sts+Ftd*Std)*Gt'*Gt;
    tempM1 = 2*Ftd'*(Xt)*Gt;
    for i = 1:size(Std,1)
        for j = 1:size(Std,2)
%             if Std(i,j) >= Ssd(i,j)
%                 gradient = 1;
%             else
%                 gradient = -1;
%             end
            tempMu = tempM(i,j) + delta*gradient;
            if tempMu > 0
                Std(i,j) = Std(i,j)*(tempM1(i,j)/tempMu)^(0.5);
            else
                fprintf('the Std is %g\n',tempMu);
                Std(i,j) = 0;
            end
        end
    end
    
    %% Gt
    tempFS = Fts*Sts+Ftd*Std;
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
    
    tempFs = [Fss Fsd];
    tempSs = [Sss;Ssd];
    tempFt = [Fts Ftd];
    tempSt = [Sts;Std];
    v1 = trace(Xs'*Xs-2*Xs'*tempFs*tempSs*Gs'+Gs*tempSs'*tempFs'*tempFs*tempSs*Gs');
    v2 = trace(Xt'*Xt-2*Xt'*tempFt*tempSt*Gt'+Gt*tempSt'*tempFt'*tempFt*tempSt*Gt');
    v3 = alpha*trace(Fss'*Fss-2*Fss'*Fts+Fts'*Fts);
    v4 = beta*trace(Sss'*Sss-2*Sss'*Sts+Sts'*Sts);
    v5 = gamma *sum(sum(Fsd))+gamma *sum(sum(Ftd)) + delta * sum(sum(Ssd))+ delta * sum(sum(Std));
    fvalue = v1+v2+v3+v4 + v5;
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
