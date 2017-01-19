fea = csvread('g:/sougou2500.tfidf.new.csv');
NMFGZH(fea,0.,1.0,0.0,100,100);

train_X = csvread('V.csv');%%%NMF
[m,n] = size(train_X);
[m,n]
train_labels = xlsread('g:/labels_s.xls')';
% [train_labels]
% return;
ind = randperm(size(train_X, 1));
train_X = train_X(ind(1:m),:);
train_labels = train_labels(ind(1:m));
[size(train_labels)]
% return;
% Set parameters
no_dims = 2;
initial_dims = 50;
perplexity = 30;
% Run t?SNE
mappedX = tsne(train_X, [], no_dims, initial_dims, perplexity);
[size(mappedX)]
% Plot results
gscatter(mappedX(:,1), mappedX(:,2), train_labels);