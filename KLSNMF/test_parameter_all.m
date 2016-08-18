
str = 'C:\mydata_add_withtraintest_cutshortdoc_for_wdq/';

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
xlswrite(strcat('paramter.csv'),['a','b','g','d','k','m']);
numK = 50;
numCircle = 180;
for tie=1:1:30
    alpha  =getRand(0.5,10);
    beta = getRand(0.5,10);
    gamma = getRand(0.5,10);
    delta = getRand(0.5,10);
    similarK = getRand(10,numK);
    [alpha,beta,gamma,delta,similarK]
    index= 1;
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
        lvalues(index) = max(Results(1,:));
        index = index+1;
    end
    [res] = xlsread(strcat('paramter.xls'));
    temp = [alpha,beta,gamma,delta,similarK,lvalues];
    xlswrite(strcat('paramter.xls'),[res;temp]);
end




