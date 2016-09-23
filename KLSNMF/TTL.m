function Results = TTL(TrainX,TrainY,TestX,TestY,IntermididateX,IntermididateY,alpha,beta,gamma,delta ,numK,similarK,numCircle)
similarK =  int32(similarK);
G0 = [];
Gi = [];
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

for i = 1:length(IntermididateY)
    if IntermididateY(i) == 1
        Gi(i,1) = 1;
        Gi(i,2) = 0;
    else
        Gi(i,1) = 0;
        Gi(i,2) = 1;
    end
end

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

%%%%%%%%%%for imedate
ptemp = 1./(1 + exp(-wbest'*IntermididateX));
oriA = getResult(ptemp,IntermididateY);
fprintf('Test accuracy on imddate domain is :%g\n',oriA);
for i = 1:length(IntermididateY)
    Gi(i,1) = ptemp(i);
    Gi(i,2) = 1 - ptemp(i);
end

%%%%逻辑回归结束

% 对Xs和Xt进行归一化
Xs = TrainX;
Xi = IntermididateX;
Xt = TestX;
for i = 1:size(TrainX,2)
    Xs(:,i) = Xs(:,i)/sum(Xs(:,i));
end

for i = 1:size(Xi,2)
    Xi(:,i) = Xi(:,i)/sum(Xi(:,i));
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

Fsic = W(:,1:similarK);
Fsisd = W(:,similarK+1:size(W,2));
Fsiid = Fsisd;

Fitc = Fsic;
Fitid = Fsisd;
Fittd = Fitid;


%%%Init SS
SS = ones(size(W,2),size(Gs,2));
% SS = abs(randn(size(W,2),size(Gs,2)));
for i = 1:size(SS,1)
    SS(i,:) = SS(i,:)/sum(SS(i,:));
end
%%%Sss,Ssd
Asic = SS(1:similarK,:);
Asisd = SS(similarK+1:size(SS,1),:);
Asiid = Asisd;

Aitc = Asic;
Aitid = Asisd;
Aittd = Aitid;

tempFs = [Fsic Fsisd];
tempSs = [Asic;Asisd];
tempFi = [Fsic Fsiid];
tempSi = [Asic;Asiid];
tempFit = [Fitc Fitid];
tempSit = [Aitc;Aitid];
tempFt = [Fitc Fittd];
tempSt = [Aitc;Aittd];

% df = Xs-tempFs*tempSs*Gs';
% [df]
% return;
% xlswrite('fs.xls',tempFs);
% xlswrite('ss.xls',tempSs);
% xlswrite('gs.xls',Gs);

sds =Xs'*Xs-2*Xs'*tempFs*tempSs*Gs'+Gs*tempSs'*tempFs'*tempFs*tempSs*Gs';
v1 = trace(sds);
v2 = trace(Xi'*Xi-2*Xi'*tempFi*tempSi*Gi'+Gi*tempSi'*tempFi'*tempFi*tempSi*Gi');
v3 = trace(Xi'*Xi-2*Xi'*tempFit*tempSit*Gi'+Gi*tempSit'*tempFit'*tempFit*tempSit*Gi');
v4 = trace(Xt'*Xt-2*Xt'*tempFt*tempSt*Gt'+Gt*tempSt'*tempFt'*tempFt*tempSt*Gt');
fprintf(' the value of objective v1 is %g\n',v1);
fprintf(' the value of objective v2 is %g\n',v2);
fprintf(' the value of objective v3 is %g\n',v3);
fprintf(' the value of objective v4 is %g\n',v4);
fvalue = v1+v2+v3+v4;
fprintf(' the value of objective is %g\n',fvalue);
tempf = 0;
gradient = 1;
% 开始进行迭代
for circleID = 1:numCircle
    
    %%%Fsic
    tempM = (Fsic*Asic+Fsisd*Asisd)*Gs'*Gs*Asic' +  (Fsic*Asic+Fsiid*Asiid)*Gi'*Gi*Asic';
    tempM1 = Xs*Gs*Asic' + Xi*Gi*Asic';
    for i = 1:size(Fsic,1)
        for j = 1:size(Fsic,2)
            if tempM(i,j)~=0
                Fsic(i,j) = Fsic(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fsic(i,j) = 0;
            end
        end
    end
    
    %% Asic
    tempM = Fsic'*(Fsic*Asic+Fsisd*Asisd)*Gs'*Gs +  Fsic'*(Fsic*Asic+Fsiid*Asiid)*Gi'*Gi;
    tempM1 = Fsic'*Xs*Gs  + Fsic'*Xi*Gi;
    for i = 1:size(Asic,1)
        for j = 1:size(Asic,2)
            if tempM(i,j)~=0
                Asic(i,j) = Asic(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Asic(i,j) = 0;
            end
        end
    end
    
    %%Fsisd
    tempM = (Fsic*Asic+Fsisd*Asisd)*Gs'*Gs*Asisd';
    tempM1 = Xs*Gs*Asisd';
    for i = 1:size(Fsisd,1)
        for j = 1:size(Fsisd,2)
            if tempM(i,j) > 0
                Fsisd(i,j) = Fsisd(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fsisd(i,j) = 0;
            end
        end
    end
    
    
    %%Asisd
    tempM = Fsisd'*(Fsic*Asic+Fsisd*Asisd)*Gs'*Gs;
    tempM1 = Fsisd'*Xs*Gs;
    for i = 1:size(Asisd,1)
        for j = 1:size(Asisd,2)
            if tempM(i,j) > 0
                Asisd(i,j) = Asisd(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Asisd(i,j) = 0;
            end
        end
    end
    
    
    %%Fsiid
    tempM = (Fsic*Asic+Fsiid*Asiid)*Gi'*Gi*Asiid';
    tempM1 = Xi*Gi*Asiid';
    for i = 1:size(Fsiid,1)
        for j = 1:size(Fsiid,2)
            if tempM(i,j) > 0
                Fsiid(i,j) = Fsiid(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fsiid(i,j) = 0;
            end
        end
    end
    
    %%Asiid
    tempM = Fsiid'*(Fsic*Asic+Fsiid*Asiid)*Gi'*Gi;
    tempM1 = Fsiid'*Xi*Gi;
    for i = 1:size(Asiid,1)
        for j = 1:size(Asiid,2)
            if tempM(i,j) > 0
                Asiid(i,j) = Asiid(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Asiid(i,j) = 0;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%% fi end
    
    
    
    %%%Fitc
    tempM = (Fitc*Aitc+Fitid*Aitid)*Gi'*Gi*Aitc' +  (Fitc*Aitc+Fittd*Aittd)*Gt'*Gt*Aitc';
    tempM1 = Xt*Gt*Aitc' + Xi*Gi*Aitc';
    for i = 1:size(Fitc,1)
        for j = 1:size(Fitc,2)
            if tempM(i,j)~=0
                Fitc(i,j) = Fitc(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fitc(i,j) = 0;
            end
        end
    end
    
    %% Aitc
    tempM = Fitc'*(Fitc*Aitc+Fitid*Aitid)*Gi'*Gi +  Fitc'*(Fitc*Aitc+Fittd*Aittd)*Gt'*Gt;
    tempM1 = Fitc'*Xi*Gi  + Fitc'*Xt*Gt;
    for i = 1:size(Aitc,1)
        for j = 1:size(Aitc,2)
            if tempM(i,j)~=0
                Aitc(i,j) = Aitc(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Aitc(i,j) = 0;
            end
        end
    end
    
    %%Fitid
    tempM = (Fitc*Aitc+Fitid*Aitid)*Gi'*Gi*Aitid';
    tempM1 = Xi*Gi*Aitid';
    for i = 1:size(Fitid,1)
        for j = 1:size(Fitid,2)
            if tempM(i,j) > 0
                Fitid(i,j) = Fitid(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fitid(i,j) = 0;
            end
        end
    end
    
    
    %%Aitid
    tempM = Fitid'*(Fitc*Aitc+Fitid*Aitid)*Gi'*Gi;
    tempM1 = Fitid'*Xi*Gi;
    for i = 1:size(Aitid,1)
        for j = 1:size(Aitid,2)
            if tempM(i,j) > 0
                Aitid(i,j) = Aitid(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Aitid(i,j) = 0;
            end
        end
    end
    
    %%Fittd
    tempM = (Fitc*Aitc+Fittd*Aittd)*Gt'*Gt*Aittd';
    tempM1 = Xt*Gt*Aittd';
    for i = 1:size(Fittd,1)
        for j = 1:size(Fittd,2)
            if tempM(i,j) > 0
                Fittd(i,j) = Fittd(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Fittd(i,j) = 0;
            end
        end
    end
    
    
    %%Aittd
    tempM = Fittd'*(Fitc*Aitc+Fittd*Aittd)*Gt'*Gt;
    tempM1 = Fittd'*Xt*Gt;
    for i = 1:size(Aittd,1)
        for j = 1:size(Aittd,2)
            if tempM(i,j) > 0
                Aittd(i,j) = Aittd(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Aittd(i,j) = 0;
            end
        end
    end
    
    %%norm Fsic
    for i = 1:size(Fsic,2)
        if sum(Fsic(:,i))~= 0
            Fsic(:,i) = Fsic(:,i)/sum(Fsic(:,i));
        else
            for j = 1:size(Fsic,2)
                Fsic(i,j) = 1/(size(Fsic,2));
            end
        end
    end
    
    %%norm Fsisd
    for i = 1:size(Fsisd,2)
        if sum(Fsisd(:,i))~= 0
            Fsisd(:,i) = Fsisd(:,i)/sum(Fsisd(:,i));
        else
            for j = 1:size(Fsisd,2)
                Fsisd(i,j) = 1/(size(Fsisd,2));
            end
        end
    end
    
    %% norm Fsiid
    for i = 1:size(Fsiid,2)
        if sum(Fsiid(:,i))~= 0
            Fsiid(:,i) = Fsiid(:,i)/sum(Fsiid(:,i));
        else
            for j = 1:size(Fsiid,2)
                Fsiid(i,j) = 1/(size(Fsiid,2));
            end
        end
    end
    %% norm Fitc
    for i = 1:size(Fitc,2)
        if sum(Fitc(:,i))~= 0
            Fitc(:,i) = Fitc(:,i)/sum(Fitc(:,i));
        else
            for j = 1:size(Fitc,2)
                Fitc(i,j) = 1/(size(Fitc,2));
            end
        end
    end
    %%norm Fitid
    for i = 1:size(Fitid,2)
        if sum(Fitid(:,i))~= 0
            Fitid(:,i) = Fitid(:,i)/sum(Fitid(:,i));
        else
            for j = 1:size(Fitid,2)
                Fitid(i,j) = 1/(size(Fitid,2));
            end
        end
    end
    %%norm Fittd
    for i = 1:size(Fittd,2)
        if sum(Fittd(:,i))~= 0
            Fittd(:,i) = Fittd(:,i)/sum(Fittd(:,i));
        else
            for j = 1:size(Fittd,2)
                Fittd(i,j) = 1/(size(Fittd,2));
            end
        end
    end
    
    %% Gi
    temp1 = Fsic*Asic+Fsiid*Asiid;
    temp2 = Fitc*Aitc+Fitid*Aitid;
    tempM = Gi*temp1'*temp1 + Gi*temp2'*temp2;
    tempM1 = Xi'*temp1+Xi'*temp2;
    for i = 1:size(Gi,1)
        for j = 1:size(Gi,2)
            if tempM(i,j)~=0
                Gi(i,j) = Gi(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Gi(i,j) = 0;
            end
        end
    end
    for i = 1:size(Gi,1)
        if sum(Gi(i,:))~= 0
            Gi(i,:) = Gi(i,:)/sum(Gi(i,:));
        else
            for j = 1:size(Gi,2)
                Gi(i,j) = 1/(size(Gi,2));
            end
        end
    end
    
    %% Gt
    tempFS = Fitc*Aitc+Fittd*Aittd;
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
    
    
    tempFs = [Fsic Fsisd];
    tempSs = [Asic;Asisd];
    tempFi = [Fsic Fsiid];
    tempSi = [Asic;Asiid];
    tempFit = [Fitc Fitid];
    tempSit = [Aitc;Aitid];
    tempFt = [Fitc Fittd];
    tempSt = [Aitc;Aittd];
    v1 = trace(Xs'*Xs-2*Xs'*tempFs*tempSs*Gs'+Gs*tempSs'*tempFs'*tempFs*tempSs*Gs');
    v2 = trace(Xi'*Xi-2*Xi'*tempFi*tempSi*Gi'+Gi*tempSi'*tempFi'*tempFi*tempSi*Gi');
    v3 = trace(Xi'*Xi-2*Xi'*tempFit*tempSit*Gi'+Gi*tempSit'*tempFit'*tempFit*tempSit*Gi');
    v4 = trace(Xt'*Xt-2*Xt'*tempFt*tempSt*Gt'+Gt*tempSt'*tempFt'*tempFt*tempSt*Gt');
    fvalue = v1+v2+v3+v4;
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
