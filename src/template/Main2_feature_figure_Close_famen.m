clc
 clearvars -except fpath opath
close all
fpath='F:\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_��P_���������о� _tdata�ȽǶȲ���\data';
opath='F:\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_��P_���������о� _tdata�ȽǶȲ���\Output';
if ~exist(opath)
    mkdir(opath)
end
load(fullfile(fpath,'filename.mat'));

tic
for oo=1
%% I.��������׼��
load(fullfile(fpath,'tdata_resample600_10000.mat')) %ȫ���滻����Ϊ����ת�٣����ı�i_file
s=1;
for i_file=fliplr(1:21)

Normal_10000_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.��ȡNormal_Data.mat������29����������Ȼ�󱣴�

%MyPar = parpool; 
for k=1:length(Normal_10000_Data)-1
feature_round{k}=features_diff_extract(Normal_10000_Data{k});%11��ʱ������  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_10000.mat
lie=50;%����������ȡ50������
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n����㣬con�鹤��
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%�õ�feature_pointΪ10x21
%cell�ṹ��10��ʾ10����㣬21��ʾ5�鷧�ŴӴ�С����������
%ÿ��cell����һ��double����29x913,29��ʾ������913��ʾ������

%���������ѡ��50���й�������;��������ѡ�񣬱���resample(ò������̫��)������ƽ��
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
%% I.��������׼��
load(fullfile(fpath,'tdata_resample600_11000.mat')) %ȫ���滻����Ϊ����ת�٣����ı�i_file
s=1;
for i_file=fliplr(22:33)

Normal_11000_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.��ȡNormal_Data.mat������29����������Ȼ�󱣴�

%MyPar = parpool; 
for k=1:length(Normal_11000_Data)
feature_round{k}=features_diff_extract(Normal_11000_Data{k});%11��ʱ������  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_11000.mat
lie=50;%����������ȡ50������
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n����㣬con�鹤��
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%�õ�feature_pointΪ10x21
%cell�ṹ��10��ʾ10����㣬21��ʾ5�鷧�ŴӴ�С����������
%ÿ��cell����һ��double����29x913,29��ʾ������913��ʾ������

%���������ѡ��50���й�������;��������ѡ�񣬱���resample(ò������̫��)������ƽ��
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
%% I.��������׼��
load(fullfile(fpath,'tdata_resample600_12000.mat')) %ȫ���滻����Ϊ����ת�٣����ı�i_file
s=1;
for i_file=fliplr(34:53)

Normal_12000_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.��ȡNormal_Data.mat������29����������Ȼ�󱣴�

%MyPar = parpool; 
for k=1:length(Normal_12000_Data)
feature_round{k}=features_diff_extract(Normal_12000_Data{k});%11��ʱ������  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_12000.mat
lie=50;%����������ȡ50������
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n����㣬con�鹤��
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%�õ�feature_pointΪ10x21
%cell�ṹ��10��ʾ10����㣬21��ʾ5�鷧�ŴӴ�С����������
%ÿ��cell����һ��double����29x913,29��ʾ������913��ʾ������

%���������ѡ��50���й�������;��������ѡ�񣬱���resample(ò������̫��)������ƽ��
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
%% I.��������׼��
load(fullfile(fpath,'tdata_resample600_12500.mat')) %ȫ���滻����Ϊ����ת�٣����ı�i_file
s=1;
for i_file=fliplr(54:64)

Normal_12500_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.��ȡNormal_Data.mat������29����������Ȼ�󱣴�

%MyPar = parpool; 
for k=1:length(Normal_12500_Data)
feature_round{k}=features_diff_extract(Normal_12500_Data{k});%11��ʱ������  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_12500.mat
lie=50;%����������ȡ50������
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n����㣬con�鹤��
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%�õ�feature_pointΪ10x21
%cell�ṹ��10��ʾ10����㣬21��ʾ5�鷧�ŴӴ�С����������
%ÿ��cell����һ��double����29x913,29��ʾ������913��ʾ������

%���������ѡ��50���й�������;��������ѡ�񣬱���resample(ò������̫��)������ƽ��
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
%% I.��������׼��
load(fullfile(fpath,'tdata_resample600_13000.mat')) %ȫ���滻����Ϊ����ת�٣����ı�i_file
s=1;
for i_file=fliplr(65:78)

Normal_13000_Data{s}=tdata(i_file).surfaces;
s=s+1;
end


%% II.��ȡNormal_Data.mat������29����������Ȼ�󱣴�

%MyPar = parpool; 
for k=1:length(Normal_13000_Data)
feature_round{k}=features_diff_extract(Normal_13000_Data{k});%11��ʱ������  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
end

%delete(MyPar) 

%load feature_round_13000.mat
lie=50;%����������ȡ50������
[m,n]=size(feature_round{1, 1}{1, 1});
con=length(feature_round);
feature_point=cell(n,con);%n����㣬con�鹤��
for i=1:n
for k=1:con
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%�õ�feature_pointΪ10x21
%cell�ṹ��10��ʾ10����㣬21��ʾ5�鷧�ŴӴ�С����������
%ÿ��cell����һ��double����29x913,29��ʾ������913��ʾ������

%���������ѡ��50���й�������;��������ѡ�񣬱���resample(ò������̫��)������ƽ��
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
    












