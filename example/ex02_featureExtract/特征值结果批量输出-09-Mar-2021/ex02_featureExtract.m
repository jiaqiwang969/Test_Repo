%% -------   example-01：研究压气机从正常工况到失速到整个过程   ------- %%
%！ 需要代码：io接口:
%！          - 指定数据源位置，以及结果存储相应参数，默认存储为01-xxx-result
%！          - 数据导入以及转换V2Pa_Universal
%！           ps接口: pltPlot_dB_universal
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%
% 项目2：失速检测
% 12000rpm #55 和 17000 rpm #52
% I： fft批量输出结果，明白实验到整个过程，结果输出到本目录下
% II： 特征提取

clc
clear
close all
%% 案例研究内容： 
output='特征值结果批量输出';
%% 参数配置
rotorspeed=12000;
number=57;
samplePoint=600;

%% io接口
% 导入函数路径
addpath(genpath('/Users/wjq/Documents/Github-CI/Test_Repo/src'));  
% 导入data路径，
%通过gui导入![fname,location]=uigetfile({'*.mat';'*.*'},'mat参数文件读取','MultiSelect','on');%MultiSelect单选
for k=1:number
fname{k} = ['Compressor2Stall-12000-',num2str(k),'-12000.mat'];
end
location = '/Users/wjq/Documents/Github-CI/Test_Repo/data/试验18-2019-11-12-憋压/12000/';
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


leftData=[]; %leftData初始序号设为0
Object = object(1:2);%分析的对象，可以是数组，则分析多个传感器的特征
features=[];
for i_file=1:length(fname)
Data = importdata(fullfile(location,char(fname(i_file)))); %选择文件导入数据
Data=V2Pa_Universal(Data,kulite_transform_ab);
%数据不需要取均值! Data(:,1:end-1)=Data(:,1:end-1);%-mean(Data(:,1:end-1));
%[rpm,tsignal,xuhao]=pltPlot_dB_universal(Data,fs,object,objectName,testTime,char(fname(i_file)),save_directory,DPLA,DPLA_Scale,'.mat');
%[tsignal2,EIGS,S,Phi]=computeDMD(n_mode,rotorspeed,rpm,tsignal,xuhao,save_directory,char(fname(i_file)));
%% I.分析频谱，理解工况
%[the_freq,freq_dB]=frequencyDomainPlot_dB(Data,fs,2.56); 
%% II.提取Normal_Data.mat数据中29个特征量，然后保存
% 首先，数据需要进行拼接，然后按照600个点进行切分。 
% 我们选择一种简单的做法，不然太耗费内存。
% 读取数据，0，1，2，3。。。
% 首先读取data0，然后对其进行600个点切分，多余出来的拼接到下一个数据data2里面，直到最后一组
% 切分完以后立刻计算特征，features_diff_extract
%% III.研究相比B1和R1，声传感器信号的敏感程度
% 由于信号反复错杂，可以通过HMM框架，自己和自己的过去对比，这样有个标杆，去训练一个特定的指标。
% 用到HMM模型，测点为：B，R1，R-6, 声学测点1个


tic
[features,leftData]=features_diff_extract(Data,Object,samplePoint,leftData,features);%11个时域特征  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
disp([char(fname(i_file)),' ... OK!'])
toc



end


save(fullfile(save_directory,'feature_600_12000.mat'),'features')



% 
figure
for kk=1:29
    for k=1:length(features)
        feature_1(k)=features{k}(kk,1);
    end
    plot(normalize(smooth(feature_1,100)))
    hold on
end

