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
[rpm,tsignal,xuhao]=pltPlot_dB_universal(Data,fs,object,objectName,testTime,char(fname(i_file)),save_directory,0,'.mat');
[tsignal2,EIGS,S]=computeDMD(rpm,tsignal,xuhao,save_directory,char(fname(i_file)));
[the_freq,freq_dB]=freqPlot_dB_universal(12000,EIGS,tsignal2,fs,Data,object)

end



%% 最终处理，输出结果，论文可用，格式一致
%% figure3 a） Plot DMD spectrum
% Complex eigenvalues λ_k scattered in the unit circle   
%    (truncated at 30th mode in the case)
% 时间间隔
dT=1/(mean(12000)/60);
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

%% figure3-b-1 DMD 相对坐标系，模态

Si=diag(S);
X1 = f(list);
Y1 = log2(Si(list)/2e-5);

% 创建 figure
fig2 = figure('Color',[1 1 1]);
axes1 = axes('Parent',fig2,'Position',[0.13 0.60238 0.775 0.3642857]);
hold(axes1,'on');

% 创建 stem
stem1 = stem(X1,Y1,'MarkerFaceColor',[0 0 0],'Color',[0 0 0]);
baseline1 = get(stem1,'BaseLine');
set(baseline1,'Visible','on');
set(axes1,'FontSize',14)
% 创建 ylabel
ylabel({'Amplitude/log2'},'FontSize',14);
% 创建 xlabel
xlabel({'DMD frequency, imag(\lambda_k)/ Hz','FontSize',14});
% 取消以下行的注释以保留坐标区的 X 范围
 xlim(axes1,[-1 100]);
% 取消以下行的注释以保留坐标区的 Y 范围
 ylim(axes1,[32 44]);
box(axes1,'on');
hold(axes1,'off');
for i=1:length(list)
    text(X1(i)-0.6,Y1(i)+0.9,num2str(i),'FontSize',14);
end


%% figure-3b-2 The frequency plot
% 分别包括绝对坐标系
axes2 = axes('Parent',fig2,...
    'Position',[0.13 0.11  0.775 0.37865]);
hold(axes2,'on');
plot(the_freq,freq_dB(:,object(1)),'-k')
xlim(axes2,[15 12000]);
ylim(axes2,[120,180]);
xlabel({'Norm. Frequency (f/f_r_o_t)'},'FontSize',14);
ylabel('Spectrum/20*log10(L/2e-5)' ,'FontSize',14);
box(axes2,'on');
set(axes2,'XGrid','on');   
set(axes2,'FontSize',14,'XGrid','on','XTick',[200 5800 11600],...
    'XTickLabel',{'1','29(1xBPF)','58(2xBPF)'});


saveas(fig2,[save_directory,'/','fig3-b2,DMD frequcy','.fig'])




