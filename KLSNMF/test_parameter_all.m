
str = 'E:\cls-acl10-processed_cutshortdoc\test_iteration/';

basetypePath='iteration/';
FileList=dir(str);
ff = 1;
for rr=1:length(FileList)
    if(FileList(rr).isdir==1&&~strcmp(FileList(rr).name,'.')&&~strcmp(FileList(rr).name,'..'))
        filedors{ff} = strcat(str,FileList(rr).name);
        ff= ff+1;
    end
end
xlswrite(strcat('dirs.xls'),filedors');
xlswrite(strcat('paramter.xls'),['a','b','g','d','k','m']);
numK = 50;
numCircle = 180;
for tie=1:1:30
    alpha  =10*rand();
    beta = 10*rand();
    gamma = 10*rand();
    delta = 10*rand();
    similarK = int32(numK*rand());
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
        
        Results = L1SFTL(TrainX,TrainY,TestX,TestY,alpha,beta,gamma,delta,numK,similarK,numCircle);
        [res] = xlsread(strcat('paramter.xls'));
        temp = [alpha,beta,gamma,delta,similarK,max(Results(1,:))];
        xlswrite(strcat('paramter.xls'),[res;temp]);
    end
end




