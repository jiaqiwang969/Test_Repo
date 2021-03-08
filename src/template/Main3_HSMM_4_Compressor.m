%Main3_HSMM_4_Compressor.m, ��������2018-1-15
%������diff
%�ó�����Ҫ10�˲��м���
clear all;close all;clc
fpath='F:\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_��P_���������о� _tdata�ȽǶȲ���\data';
opath='F:\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_��P_���������о� _tdata�ȽǶȲ���\Output';

Sepa=1*ones(10,1);
%if_without_P=1;  %1Ϊ��P������������
Ch_name=['10000rpm';'11000rpm';'12000rpm';'12500rpm';'13000rpm';];
Famen{1}=[100;95;90;85;80;75;70;65;60;55;50;45;40;35;30;29;28;27;26-1;26;25];
Famen{2}=[100;90;80;60;50;40;35;30;29;28;27;26];
Famen{3}=[100;95;90;85;80;75;70;65;60;55;50;45;40;35;32;30;29;28-2;28-1;28;];
Famen{4}=[100;80;60;50;40;35;32;30;29;28-1;28];
Famen{5}=[100;80;60;50;45;40;35;34;33;32;31;30;29-1;29];
Famen{6}=[2;2;2;1;1];%ʧ�ٹ���˵�����ֱ�Ϊ��3������3����3����2����2

%% I.���벻ͬת�ٺͲ�ͬ���ſ��ȵ�feature����

load(fullfile(opath,'feature_resample600_point_less_rotorspeed_10000.mat')) %����в�ͬ��ת�٣����ϳ̶�Ϊ1����Ӧѹ������ͬ��ת�٣����ſ���Ϊ100%��
feature1=feature_point_less;
clear feature_point_less
load(fullfile(opath,'feature_resample600_point_less_rotorspeed_11000.mat')) %����в�ͬ�Ĺ��ϳ̶ȣ����ϳ̶�1-4����Ӧѹ������ͬ�ķ��ſ��ȣ�100%-->28%��
feature2=feature_point_less;
clear feature_point_less
load(fullfile(opath,'feature_resample600_point_less_rotorspeed_12000.mat'))
feature3=feature_point_less;
clear feature_point_less
load(fullfile(opath,'feature_resample600_point_less_rotorspeed_12500.mat'))
feature4=feature_point_less;
clear feature_point_less
load(fullfile(opath,'feature_resample600_point_less_rotorspeed_13000.mat'))
feature5=feature_point_less;
clear feature_point_less
for kk=0
load(fullfile(opath,['P_rotorspeed_10000_13000_k_',num2str(kk),'.mat']))

%load P_rotorspeed_10000_13000.mat
% load feature_more_point_rotorspeed_10000.mat %����в�ͬ��ת�٣����ϳ̶�Ϊ1����Ӧѹ������ͬ��ת�٣����ſ���Ϊ100%��
% feature1=feature_point;
% clear feature_point
% load feature_more_point_rotorspeed_11000.mat %����в�ͬ�Ĺ��ϳ̶ȣ����ϳ̶�1-4����Ӧѹ������ͬ�ķ��ſ��ȣ�100%-->28%��
% feature2=feature_point;
% clear feature_point
% load feature_more_point_rotorspeed_12000.mat
% feature3=feature_point;
% clear feature_point
% load feature_more_point_rotorspeed_12500.mat
% feature4=feature_point;
% clear feature_point
% load feature_more_point_rotorspeed_13000.mat
% feature5=feature_point;
% clear feature_point

Q=4;
M=2;
IterationNo=20;
for con=[1 2 3 4 5]  %ѵ��HMM�Ĺ���-����Ϊ�޸Ĳ�����1-5��5��ת�٣�
for hh=1 %:length(Famen{1,con})    %ѵ�����Ź���
for num=1:29%��ʾ��ѡȡ����������
  
for q=1:10
P_no{q, 1}=eye(length(num));  
end
if kk==0
P=P_no;%����P
end

%% II.����P����������ת�١���������
    NAPfeature{1,1}=Multiply(P,feature1,num); %����P����������ͬת�ٵ�Ӱ��
    NAPfeature{2,1}=Multiply(P,feature2,num);
    NAPfeature{3,1}=Multiply(P,feature3,num);
    NAPfeature{4,1}=Multiply(P,feature4,num);
    NAPfeature{5,1}=Multiply(P,feature5,num);
%     NAPfeature_train{1,1}=Multiply(P,feature6,num); %����P����������ͬת�ٵ�Ӱ��
%     NAPfeature_train{2,1}=Multiply(P,feature7,num);
%     NAPfeature_train{3,1}=Multiply(P,feature8,num);
%     NAPfeature_train{4,1}=Multiply(P,feature9,num);
%     NAPfeature_train{5,1}=Multiply(P,feature10,num);
   
%% III.����һ������ת�ٵ�100%��������ѵ��HMMmodel{10�鲻ͬ���ͨ��}
%con4tr_stall=[20;10;18;11;14];%ʧ�ٹ���

[O,lie4training]=size(NAPfeature{con,1}{1,hh}); %��ѵ������Ϊʧ�ٹ���
parfor i=1:10
traindata{i}=NAPfeature{con,1}{i,hh}(:,1:lie4training);%����һ�鿪��Ϊ100��ת��Ϊ10000�Ĺ���ѵ��HMMģ��
[PAI{i,1},Ae{i,1},Pe{i,1},mu{i,1},...
    Sigma{i,1},mixmat{i,1},stateseq{i,1},LL{i,1}]=hsmm_jhm_timeseries(Q,M,traindata{i},IterationNo);
end

%% IV. ����ѵ����HMMmodel{10�鲻ͬ���ͨ��}��Ԥ��
%����
parfor dae=1:length(NAPfeature)  
    tic
    Loglik{dae,1}=Loglik_HSMM_Calulation(Sepa,NAPfeature{dae,1},PAI,Ae,Pe,mu,Sigma,mixmat);
    toc
end

 Loglik_con1_5_without_P{con}=Loglik;clear Loglik;

%��ͼ
save_directory = ['ʧ��Ԥ��-k',num2str(kk),'�ز���600�ز���-P-1-5-',Ch_name(con,:),num2str(Famen{con}(hh)),'%ѵ������',date];  %Ƶ��ͼ�洢�ļ���
if ~exist(save_directory)
    mkdir(save_directory)
end
directory=[cd,'/',save_directory,'/']; 

for testnum=1:5 %
[fig]=createfigure( Loglik_con1_5_without_P{con}{testnum,1},num,con,hh,testnum,Ch_name,Famen)
saveas(fig,[directory,num2str(num(1)),'-29������-',Ch_name(con,:),num2str(Famen{con}(hh)),'%ѵ������-����HSMM��',Ch_name(testnum,:),'���������Ĳ�ͬ���PI����ͼ','.fig'])
saveas(fig,[directory,num2str(num(1)),'-29������-',Ch_name(con,:),num2str(Famen{con}(hh)),'%ѵ������-����HSMM��',Ch_name(testnum,:),'���������Ĳ�ͬ���PI����ͼ','.png'])
end
%close all
%save  Loglik_con1_5_without_P.mat Loglik_con1_5_without_P
%eval(['!rename', ',Loglik_con1_5_without_P.mat', ',Loglik_',Ch_name(con,:),'_No_P_Charac',num2str(num),'_Famen',num2str(Famen{con}(hh)),'.mat']);%�¼��ܣ�������

end
end
end
end
 




function cell_A=Multiply(cell_P,cell_feature,num)
%������ͬ��ʽ��cell�������
[m1 n1]=size(cell_P);
[m2 n2]=size(cell_feature);
if m1~=m2 | n1~=1
    disp('��cell�����ʽ��һ�£��޷���ˣ�')
    puase
end
for j=1:n2
for k=1:m1
    cell_A{k,j}=cell_P{k, 1}*cell_feature{k,j}(num,:);
end
end

end

function Loglik=Loglik_HSMM_Calulation(Sepa,feature,PAI,A,P,mu,Sigma,mixmat);

[m,n]=size(feature);
Loglik=[]; 
for i=1:n %��ʾ5�鹤������
for j=1:m%��ʾ10�����
%for k=1:length(NAPfeature0{j,i}) %�ڲ���������kѭ�������ٵ��ó�����ɵ�ʱ���˷�
[state,state2,stateseq1,Temp_lik(j,:)]= hsmm_jhm_timeseries_prob(feature{j,i},PAI{j,1},A{j,1},P{j,1},mu{j,1},Sigma{j,1},mixmat{j,1}); 
%end    
end
    Loglik=[Loglik Temp_lik];
    Temp_lik=[];
end
end   
 
function [figure1]=createfigure(YMatrix1,num,con,hh,testnum,Ch_name,Famen)
%CREATEFIGURE(YMATRIX1)
%  YMATRIX1:  y ���ݵľ���


% ���� figure
figure1 = figure;

% ���� axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% ʹ�� plot �ľ������봴������
plot1 = plot(YMatrix1','Marker','+','LineWidth',2,'Parent',axes1);
set(plot1(1),'DisplayName','B���','Color',[0 0 0]);
set(plot1(2),'DisplayName','R-1���','Color',[0 0 1]);
set(plot1(3),'DisplayName','R-2���');
set(plot1(4),'DisplayName','R-3���','Color',[0 1 0]);
set(plot1(5),'DisplayName','R-4���');
set(plot1(6),'DisplayName','R-5���');
set(plot1(7),'DisplayName','R-6���');
set(plot1(8),'DisplayName','R-7���',...
    'Color',[0.749019622802734 0 0.749019622802734]);
set(plot1(9),'DisplayName','R-8���','Color',[1 1 0]);
set(plot1(10),'DisplayName','C���','Color',[1 0 0]);

% ���� xlabel
xlabel('��������');

% ���� title
title({['����HSMM��',num2str(num),'������-',Ch_name(con,:),num2str(Famen{con}(hh)),'%ѵ������','-'];[Ch_name(testnum,:),'���������Ĳ�ͬ���PI����ͼ']});

% ���� ylabel
ylabel('PI�ۼ�ֵ');

box(axes1,'on');
% ���� legend
legend1 = legend(axes1,'show');
set(legend1,'Location','southwest');%eastoutside
hold on
cellnum=length(Famen{testnum});
stallnum=Famen{6}(testnum);
maxstall=max(max(YMatrix1(:,end-stallnum:end)));
minstall=min(min(YMatrix1(:,end-stallnum:end)));
diffstall=(maxstall-minstall)*0.25;
ann=[cellnum-0.5-stallnum minstall-diffstall;cellnum+0.5 minstall-diffstall;cellnum+0.5 maxstall+diffstall;cellnum-0.5-stallnum maxstall+diffstall;cellnum-0.5-stallnum minstall-diffstall;];
plot(ann(:,1),ann(:,2),'--')


end    