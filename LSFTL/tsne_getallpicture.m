
str = 'E:\cls-acl10-processed_cutshortdoc\mydata_add_withtraintest/';
FileList=dir(str);
ff = 1;
no_dims = 2;
initial_dims = 50;
perplexity = 30;
alpha = 1.5;
beta = 1.5;
numK = 50;
numCircle = 1;
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
    tsne_label = TestY;
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
    filename = regexp(base, '/', 'split');
    wname = char(filename(size(filename,2)));
    Results = LSFTL(TrainX,TrainY,TestX,TestY,alpha,beta,numK,numCircle);
    S = xlsread('S.xls');
    G = xlsread('G.xls');
    train_X = G*S';
    mappedX = tsne(train_X, [], no_dims, initial_dims, perplexity);
    fcg = figure('Visible', 'off');
    h = gscatter(mappedX(:,1), mappedX(:,2), tsne_label);
    saveas(fcg,wname,'jpg')
    close(fcg);
    
end
% x = 0:1:numCircle-1;
% figure
% plot(x,Results,'r');
% grid on
% xlabel('x');
% ylabel('Results');