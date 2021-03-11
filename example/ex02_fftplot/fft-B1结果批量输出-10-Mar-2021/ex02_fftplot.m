%% -------   example-01：研究压气机从正常工况到失速到整个过程   ------- %%
%！ 需要代码：io接口:
%！          - 指定数据源位置，以及结果存储相应参数，默认存储为01-xxx-result
%！          - 数据导入以及转换V2Pa_Universal
%！           ps接口: pltPlot_dB_universal
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%
% 项目2：失速检测
% 12000rpm #55 和 17000 rpm #52
% 任务1： fft批量输出结果，明白实验到整个过程，结果输出到本目录下
% 任务2： 特征提取

clc
clear
close all
%% 案例研究内容： 
output='fft-B1结果批量输出';
% 是否做DPLA处理
DPLA=0; 
DPLA_Scale= 0; 

% DMD 模态数
n_mode =30;
%% io接口
% 导入函数路径
addpath(genpath('/Users/wjq/Documents/Github-CI/Test_Repo/src'));  
% 导入data路径，
%通过gui导入! 
[fname,location]=uigetfile({'*.mat';'*.*'},'mat参数文件读取','MultiSelect','on');%MultiSelect单选
rotorspeed=17000;
%fname = {'Compressor2Stall-12000-8-12000.mat'};
%location = '/Users/wjq/Documents/Github-CI/Test_Repo/data/试验18-2019-11-12-憋压/12000/';
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
%[rpm,tsignal,xuhao]=pltPlot_dB_universal(Data,fs,object,objectName,testTime,char(fname(i_file)),save_directory,DPLA,DPLA_Scale,'.mat');
%[tsignal2,EIGS,S,Phi]=computeDMD(n_mode,rotorspeed,rpm,tsignal,xuhao,save_directory,char(fname(i_file)));
[the_freq,freq_dB]=frequencyDomainPlot_dB(Data,fs,2.56);
% 创建 figure
fig2 = figure('Color',[1 1 1]);
%% figure-1 The frequency plot
% 分别包括绝对坐标系
axes1 = axes('Parent',fig2,...
    'Position',[0.13  0.60238 0.775 0.37865]);
hold(axes1,'on');
plot(the_freq,freq_dB(:,object(1)),'-k')
xlim(axes1,[15 12000]);
%ylim(axes1,[120,180]);
xlabel({'Norm. Frequency (f/f_r_o_t)'},'FontSize',14);
ylabel('Spectrum/20*log10(L/2e-5)' ,'FontSize',14);
box(axes1,'on');
set(axes1,'XGrid','on');   
set(axes1,'FontSize',14,'XGrid','on','XTick',[200 5800 11600],...
    'XTickLabel',{'1','29(1xBPF)','58(2xBPF)'});

%% figure-2 Time-series plot
% 分别包括绝对坐标系
axes2 = axes('Parent',fig2,...
    'Position',[0.13 0.11  0.775 0.37865]);
hold(axes2,'on');
plot(the_freq,freq_dB(:,object(1)),'-k')
xlim(axes2,[15 12000]);
%ylim(axes2,[120,180]);
xlabel({'Norm. Frequency (f/f_r_o_t)'},'FontSize',14);
ylabel('Spectrum/20*log10(L/2e-5)' ,'FontSize',14);
box(axes2,'on');
set(axes2,'XGrid','on');   
set(axes2,'FontSize',14,'XGrid','on','XTick',[200 5800 11600],...
    'XTickLabel',{'1','29(1xBPF)','58(2xBPF)'});

% 创建 figure
fig3 = figure('Color',[1 1 1]);
%% figure-1 The frequency plot
% 分别包括绝对坐标系
axes1 = axes('Parent',fig3,...
    'Position',[0.13  0.60238 0.775 0.37865]);
hold(axes1,'on');
plot(Data(:,object(1)),'-k')
% xlim(axes1,[15 12000]);
% %ylim(axes1,[120,180]);
% xlabel({'Norm. Frequency (f/f_r_o_t)'},'FontSize',14);
% ylabel('Spectrum/20*log10(L/2e-5)' ,'FontSize',14);
% box(axes1,'on');
% set(axes1,'XGrid','on');   
% set(axes1,'FontSize',14,'XGrid','on','XTick',[200 5800 11600],...
%     'XTickLabel',{'1','29(1xBPF)','58(2xBPF)'});

%% figure-2 Time-series plot
% 分别包括绝对坐标系
axes2 = axes('Parent',fig3,...
    'Position',[0.13 0.11  0.775 0.37865]);
hold(axes2,'on');
plot(Data(:,11),'-k')
% xlim(axes2,[15 12000]);
% %ylim(axes2,[120,180]);
% xlabel({'Norm. Frequency (f/f_r_o_t)'},'FontSize',14);
% ylabel('Spectrum/20*log10(L/2e-5)' ,'FontSize',14);
% box(axes2,'on');
% set(axes2,'XGrid','on');   
% set(axes2,'FontSize',14,'XGrid','on','XTick',[200 5800 11600],...
%     'XTickLabel',{'1','29(1xBPF)','58(2xBPF)'});





saveas(fig2,[save_directory,'/','pro2-frequcy',fname{i_file},'.fig'])
saveas(fig2,[save_directory,'/','pro2-frequcy',fname{i_file},'.png'])

end






