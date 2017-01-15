clear all;
bestFt = xlsread(strcat('F.xls'));
[sA index] = sort(bestFt,'descend');
csvwrite('index.csv',index');