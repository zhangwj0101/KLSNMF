addpath(genpath('lib\lightspeed'));
addpath(genpath('lib\logreg'));
addpath(genpath('lib\tSNE'));
str = 'C:\mydata_add_withtraintest_cutshortdoc/';
FileList=dir(str);
ff = 1;
for rr=1:length(FileList)
    if(FileList(rr).isdir==1&&~strcmp(FileList(rr).name,'.')&&~strcmp(FileList(rr).name,'..'))
        filedors{ff} = strcat(str,FileList(rr).name);
        ff= ff+1;
    end
end
% xlswrite(strcat('dirs.xls'),filedors');
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
    numK = 50;
    numCircle = 180;
    best = [];
    index= 1;
    filename = regexp(base, '/', 'split');
    wname = char(filename(size(filename,2)));

    csvwrite(strcat(wname,'.csv'),[1:1:numCircle]);
    for time=1:10
        Results = KLSNMF(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle);
        [res] = csvread(strcat(wname,'.csv'));
        csvwrite(strcat(wname,'.csv'),[res;Results(1,:)]);
    end
end
% x = 0:1:numCircle-1;
% figure
% plot(x,Results,'r');
% grid on
% xlabel('x');
% ylabel('Results');