clear all;
base='C:\NMTFUtils\';
TrainX = load(strcat(base,'Train.data'));
TrainX = spconvert(TrainX);
TrainY = load(strcat(base,'Train.label'));
TrainY = TrainY';

TestX = load(strcat(base,'Test.data'));
TestX = spconvert(TestX);
TestY = load(strcat(base,'Test.label'));
TestY = TestY';

IntermididateX = load(strcat(base,'imediate.data'));
IntermididateX = spconvert(IntermididateX);
IntermididateY = load(strcat(base,'imediate.label'));
IntermididateY = IntermididateY';

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

for id = 1:length(IntermididateY)
    if IntermididateY(id) == 2
        IntermididateY(id) = -1;
    end
end

alpha = 1.5;
beta = 1.5;
gamma = 1.5;
delta= 1.5;
numK = 50;
similarK = 20;
numCircle = 280;
best = [];
index= 1;
Results = TTL(TrainX,TrainY,TestX,TestY,IntermididateX,IntermididateY,alpha,beta,gamma,delta,numK,similarK,numCircle);

