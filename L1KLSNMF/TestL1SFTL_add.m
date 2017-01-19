
str = 'D:\zwj\20NG_matlabformat/';
addpath(genpath('lib\lightspeed'));
addpath(genpath('lib\logreg'));
addpath(genpath('lib\tSNE'));
FileList=dir(str);
ff = 1;
for rr=1:length(FileList)
    if(FileList(rr).isdir==1&&~strcmp(FileList(rr).name,'.')&&~strcmp(FileList(rr).name,'..'))
        filedors{ff} = strcat(str,FileList(rr).name);
        ff= ff+1;
    end
end
% xlswrite(strcat('dirs.xls'),filedors');
csvwrite(strcat('average.csv'),0);
for rr=1:length(filedors)
    base = filedors{rr};
    trainPath = strcat(base,'/Train.data');
    trainLabelPath =strcat(base,'/Train.label');
    testPath = strcat(base,'/Test.data');
    testLabelPath = strcat(base,'/Test.label');
    fprintf('%s\n',base);
    %     clear all;
    TrainX = load(trainPath);
    TrainX = spconvert(TrainX);
    TrainY = load(trainLabelPath);
    TrainY = TrainY';
    TestX = load(testPath);
    TestX = spconvert(TestX);
    %%
    TestY = load(testLabelPath);
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
    alpha = 1.5;
    beta = 0.5;
    gamma = 1.5;
    delta = 1.5;
    numK = 50;
    numCircle = 150;
    best = [];
    index= 1;
    iternum = 1;
    similarK = 20;
    filename = regexp(base, '/', 'split');
    wname = char(filename(size(filename,2)));
    average = 0.0;
    csvwrite(strcat(wname,'.csv'),[1:1:numCircle]);
    for time=1:iternum
        Results = L1SFTL(TrainX,TrainY,TestX,TestY,alpha,beta,gamma,delta,numK,similarK,numCircle,base);
        [res] = csvread(strcat(wname,'.csv'));
        average = average + max(Results(1,:));
        csvwrite(strcat(wname,'.csv'),[res;Results]);
    end
    [res] = csvread(strcat('average.csv'));
    csvwrite(strcat('average.csv'),[res;average/iternum]);
end

% x = 0:1:numCircle-1;
% figure
% plot(x,Results,'r');
% grid on
% xlabel('x');
% ylabel('Results');