
TrainX = load('E:\mydata_add_2\en_jp_dvd_dvd/Train.data');
TrainX = spconvert(TrainX);
TrainY = load('E:\mydata_add_2\en_jp_dvd_dvd/Train.label');
TrainY = TrainY';
TestX = load('E:\mydata_add_2\en_jp_dvd_dvd/Test.data');
TestX = spconvert(TestX);
%%
TestY = load('E:\mydata_add_2\en_jp_dvd_dvd/Test.label');
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
Gs = [];
for i = 1:length(TrainY)
    if TrainY(i) == 1
        Gs(i,1) = 1;
        Gs(i,2) = 0;
    else
        Gs(i,1) = 0;
        Gs(i,2) = 1;
    end
end

Gt = [];
for i = 1:length(TestY)
    if TrainY(i) == 1
        Gt(i,1) = 1;
        Gt(i,2) = 0;
    else
        Gt(i,1) = 0;
        Gt(i,2) = 1;
    end
end
Xs = TrainX;
Xt = TestX;
% Xs = Xs/sum(sum(Xs));
% Xt = Xt/sum(sum(Xt));

for i = 1:size(TrainX,2)
    Xs(:,i) = Xs(:,i)/sum(Xs(:,i));
end
for i = 1:size(TestX,2)
    Xt(:,i) = Xt(:,i)/sum(Xt(:,i));
end

%%NMF
r = 50;
all = [TrainX];
[m,n] = size(all);
Winit = abs(randn(m,r));
Hinit = abs(randn(r,n));
[Fs,H] = nmf(full(all),Winit,Hinit,0.0000000000001,25,8000);
for id=1:size(Fs,2)
    Fs(:,id) = Fs(:,id)/sum(Fs(:,id));
end
all = [TestX];
[m,n] = size(all);
Winit = abs(randn(m,r));
Hinit = abs(randn(r,n));
[Ft,H] = nmf(full(all),Winit,Hinit,0.0000000000001,25,8000);
for id=1:size(Ft,2)
    Ft(:,id) = Ft(:,id)/sum(Ft(:,id));
end
Ss = ones(size(Fs,2),size(Gs,2));
for i = 1:size(Ss,1)
    Ss(i,:) = Ss(i,:)/sum(Ss(i,:));
end
St = ones(size(Ft,2),size(Gt,2));
for i = 1:size(St,1)
    St(i,:) = St(i,:)/sum(St(i,:));
end
for circleID = 1:numCircle
    %%Fs
    tempM = (Fs*Ss*Gs'*Gs*Ss');
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
    tempM = (Fs'*Fs*Ss*Gs'*Gs);
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
    
    %% Gt
    tempM = (Gs*Ss'*Fs'*Fs*Ss);
    tempM1 = Xs'*Fs*Ss;
    for i = 1:size(Gs,1)
        for j = 1:size(Gs,2)
            if tempM(i,j)~=0
                Gs(i,j) = Gs(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Gs(i,j) = 0;
            end
        end
    end
    for i = 1:size(Gs,1)
        if sum(Gs(i,:))~= 0
            Gs(i,:) = Gs(i,:)/sum(Gs(i,:));
        else
            for j = 1:size(Gs,2)
                Gs(i,j) = 1/(size(Gs,2));
            end
        end
    end
end
xlswrite(strcat('Fs.xls'),Fs);
xlswrite(strcat('Ss.xls'),Ss);
xlswrite(strcat('Gs.xls'),Gs);
for circleID = 1:numCircle
    %%Fs
    tempM = (Ft*St*Gt'*Gt*St');
    tempM1 = Xt*Gt*St';
    for i = 1:size(Ft,1)
        for j = 1:size(Ft,2)
            if tempM(i,j)~=0
                Ft(i,j) = Ft(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                Ft(i,j) = 0;
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
    %%Ss
    tempM = (Ft'*Ft*St*Gt'*Gt);
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
    tempM = (Gt*St'*Ft'*Ft*St);
    tempM1 = Xt'*Ft*St;
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
end
xlswrite(strcat('Ft.xls'),Ft);
xlswrite(strcat('St.xls'),St);
xlswrite(strcat('Gt.xls'),Gt);
return;
% SS = ones(size(Xs,2),50);
% for i = 1:size(SS,1)
%     SS(i,:) = SS(i,:)/sum(SS(i,:));
% end
% HH = xlsread(strcat('H.xls'));
% [m,n] = size(HH');
% [S,G] = nmf(full(HH'),abs(randn(m,2)),abs(randn(2,n)),0.0000000000001,25,8000);
% xlswrite(strcat('S.xls'),S);
% xlswrite(strcat('G.xls'),G');
% Gp = G';
% right = 0;
% for id=1:size(Gp,1)
%     if Gp(id,1) > Gp(id,2) && TrainY(id) == 1
%         right = right+1;
%     end
%     if Gp(id,1) < Gp(id,2) && TrainY(id) == -1
%         right = right+1;
%     end
% end
% [right/size(TrainX,2)]
% return ;


% for id=1:size(W,2)
%     W(:,id) = W(:,id)/sum(W(:,id));
% end
xlswrite(strcat('W.xls'),W);
xlswrite(strcat('H.xls'),H');