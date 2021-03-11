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
rotorspeed=17000;
number=52;
samplePoint=600;

%% io接口
% 导入函数路径
addpath(genpath('/Users/wjq/Documents/Github-CI/Test_Repo/src'));  
% 导入data路径，
%通过gui导入![fname,location]=uigetfile({'*.mat';'*.*'},'mat参数文件读取','MultiSelect','on');%MultiSelect单选
for k=1:number
fname{k} = ['Compressor2Stall-17000-',num2str(k),'-17000.mat'];
end
location = '/Users/wjq/Documents/Github-CI/Test_Repo/data/试验18-2019-11-12-憋压/17000/';
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
[features,leftData]=features28_diff_extract(Data,Object,samplePoint,leftData,features);%11个时域特征  %feature=[PV,PPV,AP,RP,RMS,SF,IF,CF,CLF,SK,KU];
disp([char(fname(i_file)),' ... OK!'])
toc



end


save('feature28_600_17000.mat','features')

%load('/Users/wjq/Documents/Github-CI/Test_Repo/example/ex02_featureExtract/特征值结果批量输出-09-Mar-2021/ex02_featureExtract/特征值结果批量输出-11-Mar-2021/feature_600_12000.mat')
%load('feature28_600_12000.mat')

% 

for ff=1
figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes('Parent',figure1);
for k=1:length(features)
    feature_1(k)=features{k}(ff,1);
    feature_2(k)=features{k}(ff,2);
end   


smooth_fea1=normalize(smooth(feature_1,1));
smooth_fea2=normalize(smooth(feature_2,1));

plot([1:length(features)]/length(features),smooth_fea1,'DisplayName','1','MarkerSize',2,'Marker','.','LineWidth',1,...
    'Color',[0 0 0])
hold on
plot([1:length(features)]/length(features),smooth_fea2,'DisplayName','2','MarkerSize',2,'Marker','.','LineWidth',1,...
    'Color',[1 0 0])
hold on

title(['feature',num2str(ff)])
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.449620775729646 0.371518547658106 0.151785714285714 0.129761904761905],...
    'FontSize',14,...
    'FontName','Helvetica Neue',...
    'EdgeColor',[1 1 1],...
    'Color',[0.941176470588235 0.941176470588235 0.941176470588235]);

plot([55/57 55/57],[min([smooth_fea1;smooth_fea2]), max([smooth_fea1;smooth_fea2])],'Marker','.','DisplayName','prestall')
saveas(figure1,[save_directory,'/','feature-',num2str(ff),'.fig'])


end


