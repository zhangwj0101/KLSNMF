function [U_final,V_final] = NMFGZH(TrainX,lambda,gamma,sigma,numK,numCircle)
%%% 联合训练 列为一

r = numK;
U = abs(randn(size(TrainX,1),r));
V = abs(randn(size(TrainX,2),r));
for id=1:size(U,2)
    U(:,id) = U(:,id)/sum(U(:,id));
end
X = TrainX;
for i = 1:size(TrainX,2)
    X(:,i) = X(:,i)/sum(X(:,i));
end

options = [];
options.WeightMode = 'Cosine';
Wu = constructW(X,options);
Wv = constructW(X',options);
Du = zeros(size(Wu));
Dv = zeros(size(Wv));
for i = 1:size(Wu,1)
    Du(i,i) = sum(Du(i,:));
end
for i = 1:size(Wv,1)
    Dv(i,i) = sum(Dv(i,:));
end
par = 1.5;
for circleID = 1:numCircle
    
    %%U
    tempM = U*V'*V+lambda*Du*U;
    tempM1 = X*V + lambda * Wu*U;
    for i = 1:size(U,1)
        for j = 1:size(U,2)
            if tempM(i,j)~=0
                U(i,j) = U(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                U(i,j) = 0;
            end
        end
    end
%     for i = 1:size(U,2)
%         if sum(U(:,i))~= 0
%             U(:,i) = U(:,i)/sum(U(:,i));
%         else
%             for j = 1:size(U,2)
%                 U(i,j) = 1/(size(U,2));
%             end
%         end
%     end
    
    %%V
    tempM = V*U'*U+gamma*Dv*V+sigma*V*V'*V;
    tempM1 = X'*U +gamma*Wv*V+sigma*V;
    for i = 1:size(V,1)
        for j = 1:size(V,2)
            if tempM(i,j)~=0
                V(i,j) = V(i,j)*(tempM1(i,j)/tempM(i,j))^(0.5);
            else
                V(i,j) = 0;
            end
        end
    end
%      for i = 1:size(V,1)
%         if sum(V(i,:))~= 0
%             V(i,:) = V(i,:)/sum(V(i,:));
%         else
%             for j = 1:size(V,1)
%                 V(i,j) = 1/(size(V,1));
%             end
%         end
%     end
    fprintf('iter %g\n',circleID);
end
csvwrite('U.csv',U);
csvwrite('V.csv',V);
U_final = U;
V_final = V;
