
str = 'E:\cls-acl10-processed_cutshortdoc\test_iteration/';
basetypePath='k/';
FileList=dir(str);
ff = 1;
for rr=1:length(FileList)
    if(FileList(rr).isdir==1&&~strcmp(FileList(rr).name,'.')&&~strcmp(FileList(rr).name,'..'))
        filedors{ff} = strcat(str,FileList(rr).name);
        ff= ff+1;
    end
end
xlswrite(strcat('dirs.xls'),filedors');
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
    wname = strcat(basetypePath,char(filename(size(filename,2))));
    xlswrite(strcat(wname,'.xls'),[1:1:numCircle]);
    for numK=10:10:100
        Results = L1SFTL(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle);
        [res] = xlsread(strcat(wname,'.xls'));
        xlswrite(strcat(wname,'.xls'),[res;Results(1,:)]);
    end
end
