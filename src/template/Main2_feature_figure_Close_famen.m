clc
 clearvars -except fpath opath
close all
fpath='F:\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_无P_特征单独研究 _tdata等角度采样\data';
opath='F:\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_无P_特征单独研究 _tdata等角度采样\Output';
if ~exist(opath)
    mkdir(opath)
end
load(fullfile(fpath,'filename.mat'));

tic
for oo=1
%% I.仿真数据准备
load(fullfile(fpath,'tdata_resample600_10000.mat')) %全部替换数据为其他转速，并改变i_file
s=1;
for i_file=fliplr(1:21)

Normal_10000_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.提取Normal_Data.mat数据中29个特征量，然后保存

%MyPar = parpool; 
for k=1:length(Normal_10000_Data)-1
feature_round{k}=features_diff_extract(Normal_10000_Data{k});%11个时域特征  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_10000.mat
lie=50;%各个工况抽取50个样本
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n个测点，con组工况
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%得到feature_point为10x21
%cell结构，10表示10个测点，21表示5组阀门从大到小渐进工况，
%每个cell都是一个double矩阵，29x913,29表示特征，913表示样本数

%从中随机挑选出50个列构成向量;还有其他选择，比如resample(貌似数据太乱)，比如平均
for i=1:n
for k=1:con
      add=floor(length(feature_point{i, k})/lie);
      b=(1:lie)*add;
      feature_point_less{i, k}=feature_point{i, k}(:,b);
    
%     b=randperm(length(feature_point{i, k}));%resample
%     feature_point_less{i, k}=feature_point{i, k}(:,b(1:lie));
end
end
% 

save(fullfile(opath,'feature_resample600_point_less_rotorspeed_10000.mat'),'feature_point_less')
save(fullfile(opath,'feature_resample600_point_rotorspeed_10000.mat'),'feature_point')
end
 clearvars -except fpath opath
toc
tic
for oo=2
%% I.仿真数据准备
load(fullfile(fpath,'tdata_resample600_11000.mat')) %全部替换数据为其他转速，并改变i_file
s=1;
for i_file=fliplr(22:33)

Normal_11000_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.提取Normal_Data.mat数据中29个特征量，然后保存

%MyPar = parpool; 
for k=1:length(Normal_11000_Data)
feature_round{k}=features_diff_extract(Normal_11000_Data{k});%11个时域特征  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_11000.mat
lie=50;%各个工况抽取50个样本
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n个测点，con组工况
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%得到feature_point为10x21
%cell结构，10表示10个测点，21表示5组阀门从大到小渐进工况，
%每个cell都是一个double矩阵，29x913,29表示特征，913表示样本数

%从中随机挑选出50个列构成向量;还有其他选择，比如resample(貌似数据太乱)，比如平均
for i=1:n
for k=1:con
      add=floor(length(feature_point{i, k})/lie);
      b=(1:lie)*add;
      feature_point_less{i, k}=feature_point{i, k}(:,b);
    
%     b=randperm(length(feature_point{i, k}));%resample
%     feature_point_less{i, k}=feature_point{i, k}(:,b(1:lie));
end
end
% 
save(fullfile(opath,'feature_resample600_point_less_rotorspeed_11000.mat'),'feature_point_less')
save(fullfile(opath,'feature_resample600_point_rotorspeed_11000.mat'),'feature_point')

end
 clearvars -except fpath opath
toc
tic
for oo=3
%% I.仿真数据准备
load(fullfile(fpath,'tdata_resample600_12000.mat')) %全部替换数据为其他转速，并改变i_file
s=1;
for i_file=fliplr(34:53)

Normal_12000_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.提取Normal_Data.mat数据中29个特征量，然后保存

%MyPar = parpool; 
for k=1:length(Normal_12000_Data)
feature_round{k}=features_diff_extract(Normal_12000_Data{k});%11个时域特征  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_12000.mat
lie=50;%各个工况抽取50个样本
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n个测点，con组工况
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%得到feature_point为10x21
%cell结构，10表示10个测点，21表示5组阀门从大到小渐进工况，
%每个cell都是一个double矩阵，29x913,29表示特征，913表示样本数

%从中随机挑选出50个列构成向量;还有其他选择，比如resample(貌似数据太乱)，比如平均
for i=1:n
for k=1:con
      add=floor(length(feature_point{i, k})/lie);
      b=(1:lie)*add;
      feature_point_less{i, k}=feature_point{i, k}(:,b);
    
%     b=randperm(length(feature_point{i, k}));%resample
%     feature_point_less{i, k}=feature_point{i, k}(:,b(1:lie));
end
end
% 
save(fullfile(opath,'feature_resample600_point_less_rotorspeed_12000.mat'),'feature_point_less')
save(fullfile(opath,'feature_resample600_point_rotorspeed_12000.mat'),'feature_point')
end
 clearvars -except fpath opath
toc
tic
for oo=4
%% I.仿真数据准备
load(fullfile(fpath,'tdata_resample600_12500.mat')) %全部替换数据为其他转速，并改变i_file
s=1;
for i_file=fliplr(54:64)

Normal_12500_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.提取Normal_Data.mat数据中29个特征量，然后保存

%MyPar = parpool; 
for k=1:length(Normal_12500_Data)
feature_round{k}=features_diff_extract(Normal_12500_Data{k});%11个时域特征  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_12500.mat
lie=50;%各个工况抽取50个样本
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n个测点，con组工况
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%得到feature_point为10x21
%cell结构，10表示10个测点，21表示5组阀门从大到小渐进工况，
%每个cell都是一个double矩阵，29x913,29表示特征，913表示样本数

%从中随机挑选出50个列构成向量;还有其他选择，比如resample(貌似数据太乱)，比如平均
for i=1:n
for k=1:con
      add=floor(length(feature_point{i, k})/lie);
      b=(1:lie)*add;
      feature_point_less{i, k}=feature_point{i, k}(:,b);
    
%     b=randperm(length(feature_point{i, k}));%resample
%     feature_point_less{i, k}=feature_point{i, k}(:,b(1:lie));
end
end
% 
save(fullfile(opath,'feature_resample600_point_less_rotorspeed_12500.mat'),'feature_point_less')
save(fullfile(opath,'feature_resample600_point_rotorspeed_12500.mat'),'feature_point')
end
 clearvars -except fpath opath
toc
tic
for oo=5
%% I.仿真数据准备
load(fullfile(fpath,'tdata_resample600_13000.mat')) %全部替换数据为其他转速，并改变i_file
s=1;
for i_file=fliplr(65:78)

Normal_13000_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.提取Normal_Data.mat数据中29个特征量，然后保存

%MyPar = parpool; 
for k=1:length(Normal_13000_Data)
feature_round{k}=features_diff_extract(Normal_13000_Data{k});%11个时域特征  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_13000.mat
lie=50;%各个工况抽取50个样本
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n个测点，con组工况
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%得到feature_point为10x21
%cell结构，10表示10个测点，21表示5组阀门从大到小渐进工况，
%每个cell都是一个double矩阵，29x913,29表示特征，913表示样本数

%从中随机挑选出50个列构成向量;还有其他选择，比如resample(貌似数据太乱)，比如平均
for i=1:n
for k=1:con
      add=floor(length(feature_point{i, k})/lie);
      b=(1:lie)*add;
      feature_point_less{i, k}=feature_point{i, k}(:,b);
    
%     b=randperm(length(feature_point{i, k}));%resample
%     feature_point_less{i, k}=feature_point{i, k}(:,b(1:lie));
end
end
% 
save(fullfile(opath,'feature_resample600_point_less_rotorspeed_13000.mat'),'feature_point_less')
save(fullfile(opath,'feature_resample600_point_rotorspeed_13000.mat'),'feature_point')
end
toc
 clearvars -except fpath opath
    












