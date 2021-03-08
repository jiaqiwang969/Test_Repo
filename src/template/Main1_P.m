clc
clear
close all
%% I.��������׼��
fpath='G:\HMM��·\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_��P_���������о� _tdata�ȽǶȲ���\data';
opath='G:\HMM��·\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_��P_���������о� _tdata�ȽǶȲ���\Output';

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
%% II.��ȡNormal_Data.mat������29����������Ȼ�󱣴�
%  tic
% % MyPar = parpool; 18�˲���
% for k=1:length(Normal_Data)
% feature_round{k}=features_diff_extract(Normal_Data{k});%11��ʱ������  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
% %���ｫfeatures��Ϊ���м��������������ٶȣ��������У�ֻ���޸�parforΪfor
% %����5�˲��У�����ѭ��Ϊparfor��120s��featuresΪparforѭ����112s��������Ϊ530s
% %8�˲���Ϊ72s��18��Ϊ35.693539 �롣
% %�ɲ鿴��̨���鿴�������
% 
% end
% toc
% delete(MyPar) 
% save(fullfile(opath,'feature_round_4_P.mat'),'feature_round')
load(fullfile(opath,'feature_round_4_P.mat'))
lie=800;%�������ӶԼ���ʱ��Ӱ��ʱ���Խ���

feature_point=cell(10,5);%10����㣬5�鹤��
for i=1:10
for k=1:5
    for j=1:length(feature_round{1, k})  
    feature_point{i, k}=[feature_point{i, k} feature_round{1, k}{1, j}(:,i)];  
    end
end
end    
%�õ�feature_pointΪ10x5
%cell�ṹ��10��ʾ10����㣬5��ʾ5��ת�ٹ�����
%ÿ��cell����һ��double����29x913,29��ʾ������913��ʾ������

%���������ѡ��50���й�������;��������ѡ�񣬱���resample������ƽ��
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
%% III.NAPcalculationͶӰ������� 
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
W=[B A A A A;A B A A A;A A B A A;A A A B A;A A A A B];%�������
I=ones(C*N,1);
%Z=diag(W*I)-W;
Z1=W*I;%����diag(W1)����
for i=1:C*N
    Z(i,i)=Z1(i);
end
Z=Z-W;
[V,D]=eig(data*Z*data');%D�Խ���Ԫ��Ϊ����ֵ��Vÿһ��Ϊ��Ӧ����ֵ����������
d=diag(D);%����ֵ
[d2,ind]=sort(d,'descend');%��d����������d2��indΪԭ�������
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
    












