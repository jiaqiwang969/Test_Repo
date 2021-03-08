%% -------   example-02：传感器测量到信号，然后tecplot展示   ------- %%
%！ 需要代码：io接口:
%！          - 指定数据源位置，以及结果存储相应参数，默认存储为01-xxx-result
%！          - 数据导入以及转换V2Pa_Universal
%！           ps接口: pltPlot_dB_universal
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%
% 绘制论文里面的figure3

clc
clear
close all
%% 案例研究内容： 
output='叶顶流场动画结果输出';
% 是否做DPLA处理
DPLA=0; 
DPLA_Scale= 0; 

% DMD 模态数
n_mode =3
%% io接口
% 导入函数路径
addpath(genpath('/Users/wjq/Documents/Github-CI/Test_Repo/src'));  
% 导入data路径，
%通过gui导入! [fname,location]=uigetfile({'*.mat';'*.*'},'mat参数文件读取','MultiSelect','on');%MultiSelect单选
rotorspeed=17000;
fname = {'jibojian-1.txt'};
location = '/Users/wjq/Documents/Github-CI/Test_Repo/data/试验14-2018-07-26激波';
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
[tsignal2,EIGS,S,Phi]=computeDMD(n_mode,rotorspeed,rpm,tsignal,xuhao,save_directory,char(fname(i_file)));
%[the_freq,freq_dB]=freqPlot_dB_universal(rotorspeed,EIGS,tsignal2,fs,Data,object)
end


%% 最终处理，输出结果，论文可用，格式一致
%% figure3 a） Plot DMD spectrum
% Complex eigenvalues λ_k scattered in the unit circle   
%    (truncated at 30th mode in the case)
% 时间间隔
dT=1/(mean(rotorspeed)/60);
% 物理频率
f=imag(log(EIGS)/dT)/2/pi;
% 剔出频率为0的，除了第一个意以外
list=[1;find(f>0 & f<97)];

fig1=figure 
theta = (0:1:100)*2*pi/100;
plot(cos(theta),sin(theta),'k--') % plot unit circle
hold on, grid on
real_eigs=real(EIGS);
imag_eigs=imag(EIGS);
scatter(real_eigs,imag_eigs,'ok')

for i=1:length(list)
text(real_eigs(list(i))-0.02,imag_eigs(list(i))+0.07,num2str(i),'FontSize',14)
end
axis([-1 1 -1 1]);
axis equal
grid off
xlim([-1 1]);
ylim([-1 1]);
axis off
saveas(fig1,[save_directory,'/','fig3-a-unitCicle','.fig'])



    
    
