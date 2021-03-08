clc
clear
close all
%% I.仿真数据准备
fpath='G:\HMM心路\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_无P_特征单独研究 _tdata等角度采样\data';
opath='G:\HMM心路\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_无P_特征单独研究 _tdata等角度采样\Output';

% load(fullfile(fpath,'tdata_resample600_10000.mat'))
% Normal_10000=tdata(end).surfaces;  clear tdata;
% load(fullfile(fpath,'tdata_resample600_11000.mat'))
% Normal_11000=tdata(end).surfaces;  clear tdata;
% load(fullfile(fpath,'tdata_resample600_12000.mat'))
% Normal_12000=tdata(end).surfaces;  clear tdata;
% load(fullfile(fpath,'tdata_resample600_12500.mat'))
% Normal_12500=tdata(end).surfaces;  clear tdata;
% load(fullfile(fpath,'tdata_resample600_13000.mat'))
% Normal_13000=tdata(end).surfaces;  clear tdata;
% Normal_Data{1}=Normal_10000;
% Normal_Data{2}=Normal_11000;
% Normal_Data{3}=Normal_12000;
% Normal_Data{4}=Normal_12500;
% Normal_Data{5}=Normal_13000;

% load(fullfile(fpath,'Normal_Data_4_P.mat'))
%% II.提取Normal_Data.mat数据中29个特征量，然后保存
%  tic
% % MyPar = parpool; 18核并行
% for k=1:length(Normal_Data)
% feature_round{k}=features_diff_extract(Normal_Data{k});%11个时域特征  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
% %这里将features设为并行计算以增加运算速度，若不并行，只需修改parfor为for
% %测试5核并行，若主循环为parfor：120s；features为parfor循环：112s；不并行为530s
% %8核并行为72s；18核为35.693539 秒。
% %可查看后台，查看并行情况
% 
% end
% toc
% delete(MyPar) 
% save(fullfile(opath,'feature_round_4_P.mat'),'feature_round')
load(fullfile(opath,'feature_round_4_P.mat'))
lie=800;%列数增加对计算时间影响时可以接受

feature_point=cell(10,5);%10个测点，5组工况
for i=1:10
for k=1:5
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%得到feature_point为10x5
%cell结构，10表示10个测点，5表示5组转速工况，
%每个cell都是一个double矩阵，29x913,29表示特征，913表示样本数

%从中随机挑选出50个列构成向量;还有其他选择，比如resample，比如平均
for i=1:10
for k=1:5
      add=floor(length(feature_point{i, k})/lie);
      b=(1:lie)*add;
      feature_point_less{i, k}=feature_point{i, k}(:,b);
      
%     b=randperm(length(feature_point{i, k}));
%     feature_point_less{i, k}=feature_point{i, k}(:,b(1:lie));
end
end

for k=21:30
%% III.NAPcalculation投影矩阵计算 
tic
for point=1:10
    feature=feature_point_less(point,:);
%NAP

num=[1:29];
[O,N]=size(feature{1}(num,:));
C=length(feature);
data=zeros(O,C*N);
data=[feature{1}(num,:) feature{2}(num,:) feature{3}(num,:) feature{4}(num,:) feature{5}(num,:)];
W=zeros(C*N,C*N);
A=ones(N,N);
B=zeros(N,N);
W=[B A A A A;A B A A A;A A B A A;A A A B A;A A A A B];%方块矩阵
I=ones(C*N,1);
%Z=diag(W*I)-W;
Z1=W*I;%生成diag(W1)矩阵
for i=1:C*N
    Z(i,i)=Z1(i);
end
Z=Z-W;
[V,D]=eig(data*Z*data');%D对角线元素为特征值，V每一列为对应特征值的特征向量
d=diag(D);%特征值
[d2,ind]=sort(d,'descend');%将d降序排列于d2，ind为原排列序号
U=V(:,ind(1:k));
[a,b]=size(U*U');
for i=1:a
    P_temp(i,i)=1;
end
P{point,:}=P_temp-U*U';
end   

save(fullfile(opath,['P_rotorspeed_10000_13000_k_',num2str(k),'.mat']),'P')
toc
end
    












