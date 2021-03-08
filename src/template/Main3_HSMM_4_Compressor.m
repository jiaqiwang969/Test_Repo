%Main3_HSMM_4_Compressor.m, 王佳琪，2018-1-15
%数据用diff
%该程序需要10核并行计算
clear all;close all;clc
fpath='F:\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_无P_特征单独研究 _tdata等角度采样\data';
opath='F:\Compressor_new_ver6_4Stall_detction_4include-2018-1-14\HMM_simulation_4_Compressor_ver2_2018_1_15_无P_特征单独研究 _tdata等角度采样\Output';

Sepa=1*ones(10,1);
%if_without_P=1;  %1为无P消除工况作用
Ch_name=['10000rpm';'11000rpm';'12000rpm';'12500rpm';'13000rpm';];
Famen{1}=[100;95;90;85;80;75;70;65;60;55;50;45;40;35;30;29;28;27;26-1;26;25];
Famen{2}=[100;90;80;60;50;40;35;30;29;28;27;26];
Famen{3}=[100;95;90;85;80;75;70;65;60;55;50;45;40;35;32;30;29;28-2;28-1;28;];
Famen{4}=[100;80;60;50;40;35;32;30;29;28-1;28];
Famen{5}=[100;80;60;50;45;40;35;34;33;32;31;30;29-1;29];
Famen{6}=[2;2;2;1;1];%失速工况说明；分别为后3个，后3，后3，后2，后2

%% I.导入不同转速和不同阀门开度的feature数据

load(fullfile(opath,'feature_resample600_point_less_rotorspeed_10000.mat')) %将轴承不同的转速（故障程度为1）对应压气机不同的转速（阀门开度为100%）
feature1=feature_point_less;
clear feature_point_less
load(fullfile(opath,'feature_resample600_point_less_rotorspeed_11000.mat')) %将轴承不同的故障程度（故障程度1-4）对应压气机不同的阀门开度（100%-->28%）
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
% load feature_more_point_rotorspeed_10000.mat %将轴承不同的转速（故障程度为1）对应压气机不同的转速（阀门开度为100%）
% feature1=feature_point;
% clear feature_point
% load feature_more_point_rotorspeed_11000.mat %将轴承不同的故障程度（故障程度1-4）对应压气机不同的阀门开度（100%-->28%）
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
for con=[1 2 3 4 5]  %训练HMM的工况-可作为修改参数（1-5：5个转速）
for hh=1 %:length(Famen{1,con})    %训练阀门工况
for num=1:29%表示所选取的特征参数
  
for q=1:10
P_no{q, 1}=eye(length(num));  
end
if kk==0
P=P_no;%有无P
end

%% II.乘上P矩阵，消除‘转速’冗余属性
    NAPfeature{1,1}=Multiply(P,feature1,num); %先求P矩阵，消除不同转速的影响
    NAPfeature{2,1}=Multiply(P,feature2,num);
    NAPfeature{3,1}=Multiply(P,feature3,num);
    NAPfeature{4,1}=Multiply(P,feature4,num);
    NAPfeature{5,1}=Multiply(P,feature5,num);
%     NAPfeature_train{1,1}=Multiply(P,feature6,num); %先求P矩阵，消除不同转速的影响
%     NAPfeature_train{2,1}=Multiply(P,feature7,num);
%     NAPfeature_train{3,1}=Multiply(P,feature8,num);
%     NAPfeature_train{4,1}=Multiply(P,feature9,num);
%     NAPfeature_train{5,1}=Multiply(P,feature10,num);
   
%% III.利用一组任意转速的100%开度数据训练HMMmodel{10组不同测点通道}
%con4tr_stall=[20;10;18;11;14];%失速工况

[O,lie4training]=size(NAPfeature{con,1}{1,hh}); %改训练样本为失速工况
parfor i=1:10
traindata{i}=NAPfeature{con,1}{i,hh}(:,1:lie4training);%利用一组开度为100，转速为10000的工况训练HMM模型
[PAI{i,1},Ae{i,1},Pe{i,1},mu{i,1},...
    Sigma{i,1},mixmat{i,1},stateseq{i,1},LL{i,1}]=hsmm_jhm_timeseries(Q,M,traindata{i},IterationNo);
end

%% IV. 利用训练的HMMmodel{10组不同测点通道}来预测
%测试
parfor dae=1:length(NAPfeature)  
    tic
    Loglik{dae,1}=Loglik_HSMM_Calulation(Sepa,NAPfeature{dae,1},PAI,Ae,Pe,mu,Sigma,mixmat);
    toc
end

 Loglik_con1_5_without_P{con}=Loglik;clear Loglik;

%画图
save_directory = ['失速预测-k',num2str(kk),'重采样600重采样-P-1-5-',Ch_name(con,:),num2str(Famen{con}(hh)),'%训练样本',date];  %频谱图存储文件夹
if ~exist(save_directory)
    mkdir(save_directory)
end
directory=[cd,'/',save_directory,'/']; 

for testnum=1:5 %
[fig]=createfigure( Loglik_con1_5_without_P{con}{testnum,1},num,con,hh,testnum,Ch_name,Famen)
saveas(fig,[directory,num2str(num(1)),'-29号特征-',Ch_name(con,:),num2str(Famen{con}(hh)),'%训练样本-基于HSMM的',Ch_name(testnum,:),'测试样本的不同测点PI曲线图','.fig'])
saveas(fig,[directory,num2str(num(1)),'-29号特征-',Ch_name(con,:),num2str(Famen{con}(hh)),'%训练样本-基于HSMM的',Ch_name(testnum,:),'测试样本的不同测点PI曲线图','.png'])
end
%close all
%save  Loglik_con1_5_without_P.mat Loglik_con1_5_without_P
%eval(['!rename', ',Loglik_con1_5_without_P.mat', ',Loglik_',Ch_name(con,:),'_No_P_Charac',num2str(num),'_Famen',num2str(Famen{con}(hh)),'.mat']);%新技能：重命名

end
end
end
end
 




function cell_A=Multiply(cell_P,cell_feature,num)
%两个相同形式的cell矩阵相乘
[m1 n1]=size(cell_P);
[m2 n2]=size(cell_feature);
if m1~=m2 | n1~=1
    disp('！cell数组格式不一致，无法相乘！')
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
for i=1:n %表示5组工况数据
for j=1:m%表示10个测点
%for k=1:length(NAPfeature0{j,i}) %内部函数进行k循环，减少调用程序造成的时间浪费
[state,state2,stateseq1,Temp_lik(j,:)]= hsmm_jhm_timeseries_prob(feature{j,i},PAI{j,1},A{j,1},P{j,1},mu{j,1},Sigma{j,1},mixmat{j,1}); 
%end    
end
    Loglik=[Loglik Temp_lik];
    Temp_lik=[];
end
end   
 
function [figure1]=createfigure(YMatrix1,num,con,hh,testnum,Ch_name,Famen)
%CREATEFIGURE(YMATRIX1)
%  YMATRIX1:  y 数据的矩阵


% 创建 figure
figure1 = figure;

% 创建 axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% 使用 plot 的矩阵输入创建多行
plot1 = plot(YMatrix1','Marker','+','LineWidth',2,'Parent',axes1);
set(plot1(1),'DisplayName','B测点','Color',[0 0 0]);
set(plot1(2),'DisplayName','R-1测点','Color',[0 0 1]);
set(plot1(3),'DisplayName','R-2测点');
set(plot1(4),'DisplayName','R-3测点','Color',[0 1 0]);
set(plot1(5),'DisplayName','R-4测点');
set(plot1(6),'DisplayName','R-5测点');
set(plot1(7),'DisplayName','R-6测点');
set(plot1(8),'DisplayName','R-7测点',...
    'Color',[0.749019622802734 0 0.749019622802734]);
set(plot1(9),'DisplayName','R-8测点','Color',[1 1 0]);
set(plot1(10),'DisplayName','C测点','Color',[1 0 0]);

% 创建 xlabel
xlabel('样本个数');

% 创建 title
title({['基于HSMM的',num2str(num),'号特征-',Ch_name(con,:),num2str(Famen{con}(hh)),'%训练样本','-'];[Ch_name(testnum,:),'测试样本的不同测点PI曲线图']});

% 创建 ylabel
ylabel('PI累加值');

box(axes1,'on');
% 创建 legend
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