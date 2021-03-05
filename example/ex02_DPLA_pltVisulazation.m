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
% 2%的平均尺度
if DPLA==1
    % DPLA_Scale 为0 表示不做平均操作
    DPLA_Scale= 10; 
end

%% io接口
% 导入函数路径
addpath(genpath('/Users/wjq/Documents/Github-CI/Test_Repo/src'));  
% 导入data路径，
%通过gui导入! [fname,location]=uigetfile({'*.mat';'*.*'},'mat参数文件读取','MultiSelect','on');%MultiSelect单选
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
[rpm,tsignal,xuhao]=pltPlot_dB_universal(Data,fs,object,objectName,testTime,char(fname(i_file)),save_directory,DPLA,'.mat',DPLA_Scale);
% computeDMD(rpm,tsignal,xuhao,save_directory,char(fname(i_file)));
end

