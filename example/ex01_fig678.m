%% -------   example-01：传感器测量到信号，然后tecplot展示   ------- %%
%！ 需要代码：io接口:
%！          - 指定数据源位置，以及结果存储相应参数，默认存储为01-xxx-result
%！          - 数据导入以及转换V2Pa_Universal
%！           ps接口: pltPlot_dB_universal
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%
%！ 论文任务清单内容: 
%！ DPLA 两个尺度的图像重新生成
%！ 选择数据为 'Compressor2Stall-12000-94.mat'

clc
clear
close all

%% 案例研究内容： 
output='叶顶流场动画结果输出';
% 是否做DPLA处理
DPLA=1;     
DPLA_Scale= 0; 
% 2%的平均尺度
if DPLA==1
    % DPLA_Scale 为0 表示不做平均操作
    DPLA_Scale= 20; 
end

%% io接口
% 导入函数路径
addpath(genpath('/Users/wjq/Documents/Github-CI/Test_Repo/src'));  
% 导入data路径，
%通过gui导入! [fname,location]=uigetfile({'*.mat';'*.*'},'mat参数文件读取','MultiSelect','on');%MultiSelect单选
rotorspeed=12000;
fname = {'Compressor2Stall-12000-94.mat'};
location = '/Users/wjq/Documents/Github-CI/Test_Repo/data/实验8-2018-01-20/Compressor2Stall-12000';
load([location,'/','参数说明','/','parameter.mat']); %选择文件导入数据
disp(Note);
% 保存路径, 创建目录
save_directory = [mfilename,'/',output,'-',date];  %频谱图存储文件夹
if ~exist(save_directory)
    mkdir(save_directory)
else
    disp('文件夹存在！');
end
% % //========================================  
if isstr(fname)
   fname=cellstr(fname);
end
% 备份
copyfile([mfilename,'.m'] , save_directory)



for i_file=1:length(fname)
Data = importdata(fullfile(location,char(fname(i_file)))); %选择文件导入数据
Data=V2Pa_Universal(Data,kulite_transform_ab);
%数据不需要取均值! Data(:,1:end-1)=Data(:,1:end-1);%-mean(Data(:,1:end-1));
[rpm,tsignal,xuhao]=pltPlot_dB_universal(Data,fs,object,objectName,testTime,char(fname(i_file)),save_directory,DPLA,DPLA_Scale,'.mat');
%[tsignal2,EIGS,S]=computeDMD(rpm,tsignal,xuhao,save_directory,char(fname(i_file)),rotorspeed);
%[the_freq,freq_dB]=frequencyDomainPlot_dB(Data,fs,2.56);

end

av=zeros(size(tsignal.surfaces(1).v));
for k=1:360/DPLA_Scale
    
av=av + tsignal.surfaces(k).v;

end
AV=av/k;

for k=1:360/DPLA_Scale
    
tsignal.surfaces(k).v=tsignal.surfaces(k).v-AV;

end

mat2tecplot(tsignal,[save_directory,'/','DPLA-Scale-',num2str(DPLA_Scale),'-union-backgroundremoval.plt']);



% %% figure-6 The raw data and top 3 normalized dynamic modes
% % 备注：输出结果，再tecplot做cutoff，输出eps格式！
% tsignal3.Nvar= tsignal.Nvar;
% tsignal3.varnames= tsignal.varnames;
% % 名字标签
% tsignal3.varnames{1, 4} = 'Normalized';
% % 将几个模态图合并成一个，但tecplot出现自动粘连问题
% % 解决办法：将该处设置偏离较大的值，然后通过tecplot的cutoff功能抠除
% % 空间布置
% n=3; space=100;
% n_mode=list(1:3);
% x=tsignal.surfaces(q2(1)).x;
% y=tsignal.surfaces(q2(1)).y;
% z=tsignal.surfaces(q2(1)).z;
% %中间值
% x_middle1=x(1,:)-1;x_middle2=x(end,:)-1;
% y_middle1=y(1,:);y_middle2=y(end,:);
% z_middle1=z(1,:);z_middle2=z(end,:);
% 
% %嵌入的偏离值 
% %div=(min(min(Phi))-max(max(Phi)))*ones(1,10);
% %div=max(max(Phi))*ones(1,10);
% div = 3.2*ones(1,10);
% 
% % 初始设为空；如果输出, 设为snapshot of raw data。
% tsignal3.surfaces.x =[x;x_middle1]; tsignal3.surfaces.y =[y;y_middle1]; tsignal3.surfaces.z =[z;z_middle1];
% tsignal3_v=[normalize(reshape(tsignal.surfaces(51).v,min(len),10));div];%随意取
% 
% 
% for k=1:n
%     tsignal3.surfaces.x=[tsignal3.surfaces.x;x_middle1;x;x_middle2];
%     tsignal3.surfaces.y=[tsignal3.surfaces.y;y_middle1 + (k)*space;y + (k)*space;y_middle2 + (k)*space];
%     tsignal3.surfaces.z=[tsignal3.surfaces.z;z_middle1;z;z_middle2];
%     tsignal3_v=[tsignal3_v;div;normalize(reshape(Phi(:,n_mode(k)),min(len),10));div];
% end
% 
% tsignal3.surfaces.v=reshape(tsignal3_v,1,min(len)+1+(min(len)+2)*n,10);
% tsignal3.surfaces.solutiontime=1;
% mat2tecplot(tsignal3,[save_directory,'/',name,'-union.plt']);
% 
% 
