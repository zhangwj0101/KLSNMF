clear all;
bestFs = xlsread(strcat('Fs.xls'));
[sA index] = sort(bestFs,'descend');
csvwrite('indexs.csv',index');

bestFt = xlsread(strcat('Ft.xls'));
[sA index] = sort(bestFt,'descend');
csvwrite('indext.csv',index');