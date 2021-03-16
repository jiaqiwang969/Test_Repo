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
n_mode =30;
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
[tsignal2,EIGS,S,Phi,b]=computeDMD(n_mode,rotorspeed,rpm,tsignal,xuhao,save_directory,char(fname(i_file)));
[the_freq,freq_dB]=frequencyDomainPlot_dB(Data,fs,2.56);

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
plot(cos(theta),sin(theta),'k-.') % plot unit circle
hold on

plot(0.6*cos(theta),0.6*sin(theta),'k--') % plot unit circle

hold on, grid on
real_eigs=real(EIGS);
imag_eigs=imag(EIGS);
scatter(real_eigs,imag_eigs,'ok')

for i=1:3
text(real_eigs(list(i))-0.02,imag_eigs(list(i))+0.07,num2str(i),'FontSize',18,'Color',[1 0 0])
end
axis([-1 1 -1 1]);
axis equal
grid off
xlim([-1 1]);
ylim([-1 1]);
axis off
saveas(fig1,[save_directory,'/','fig3-a-unitCicle','.fig'])

%% figure3-b-1 DMD 相对坐标系，模态

X1 = f(list);
Y1 = log2(abs(b(list))/2e-5);


% 创建 figure
fig2 = figure('Color',[1 1 1]);
%axes1 = axes('Parent',fig2,'Position',[0.13 0.60238 0.775 0.3642857]);
axes1 = axes('Parent',fig2);
hold(axes1,'on');

% 创建 stem
stem1 = stem(Y1,'MarkerFaceColor',[0 0 0],'Color',[0 0 0]);
baseline1 = get(stem1,'BaseLine');
set(baseline1,'Visible','on');
set(axes1,'FontSize',14)
% 创建 ylabel
ylabel({'Amplitude/log2'},'FontSize',14);
% 创建 xlabel
%xlabel({'DMD frequency, imag(\lambda_k)/ Hz','FontSize',14});
%xlabel({'SVD eigenvalue','FontSize',14});
% 取消以下行的注释以保留坐标区的 X 范围
 %xlim(axes1,[-1 100]);
% 取消以下行的注释以保留坐标区的 Y 范围
ylim(axes1,[25 44]);
box(axes1,'on');
hold(axes1,'off');
 for i=1:3
     text(i,Y1(i)+0.4,num2str(i),'FontSize',18,'Color',[1 0 0]);
 end






%% figure-3b-2 The frequency plot
% 分别包括绝对坐标系
fig3 = figure('Color',[1 1 1]);
%axes2 = axes('Parent',fig2,'Position',[0.13 0.11  0.775 0.37865]);
axes3 = axes('Parent',fig3);
hold(axes3,'on');
plot(the_freq,freq_dB(:,object(1)),'-k')
xlim(axes3,[15 12000]);
ylim(axes3,[120,180]);
xlabel({'Norm. Frequency (f/f_r_o_t)'},'FontSize',14);
ylabel('Spectrum/20*log10(L/2e-5)' ,'FontSize',14);
box(axes3,'on');
set(axes3,'XGrid','on');   
set(axes3,'FontSize',14,'XGrid','on','XTick',[200 5800 11600],...
    'XTickLabel',{'1','29(1xBPF)','58(2xBPF)'});


saveas(fig2,[save_directory,'/','fig3-b2,DMD frequcy','.fig'])




%% figure-3c The raw data and top 3 normalized dynamic modes
% 备注：输出结果，再tecplot做cutoff，输出eps格式！

tsignal3.Nvar= tsignal.Nvar;
tsignal3.varnames= tsignal.varnames;
% 名字标签
tsignal3.varnames{1, 4} = 'Normalized';
% 将几个模态图合并成一个，但tecplot出现自动粘连问题
% 解决办法：将该处设置偏离较大的值，然后通过tecplot的cutoff功能抠除
% 空间布置
n=3; space=100;
n_mode=list(1:3);
x=tsignal.surfaces(1).x;
y=tsignal.surfaces(1).y;
z=tsignal.surfaces(1).z;
%中间值
x_middle1=x(1,:)-1;x_middle2=x(end,:)-1;
y_middle1=y(1,:);y_middle2=y(end,:);
z_middle1=z(1,:);z_middle2=z(end,:);

%嵌入的偏离值 
%div=(min(min(Phi))-max(max(Phi)))*ones(1,10);
%div=max(max(Phi))*ones(1,10);
div = 3.2*ones(1,10);
[len,temp]=size(tsignal.surfaces(1).z)
% 初始设为空；如果输出, 设为snapshot of raw data。
tsignal3.surfaces.x =[x;x_middle1]; tsignal3.surfaces.y =[y;y_middle1]; tsignal3.surfaces.z =[z;z_middle1];
tsignal3_v=[normalize(reshape(tsignal.surfaces(1).v,len,10));div];%随意取


for k=1:n
    tsignal3.surfaces.x=[tsignal3.surfaces.x;x_middle1;x;x_middle2];
    tsignal3.surfaces.y=[tsignal3.surfaces.y;y_middle1 + (k)*space;y + (k)*space;y_middle2 + (k)*space];
    tsignal3.surfaces.z=[tsignal3.surfaces.z;z_middle1;z;z_middle2];
    tsignal3_v=[tsignal3_v;div;normalize(reshape(Phi(:,n_mode(k)),len,10));div];
end

tsignal3.surfaces.v=reshape(tsignal3_v,1,len+1+(len+2)*n,10);
tsignal3.surfaces.solutiontime=1;
mat2tecplot(tsignal3,[save_directory,'/','union.plt']);

tsignal3.surfaces.x
tsignal3.surfaces.z


%%
%# some random data
K = 3;
N = len;
data = zeros(K,N);
% data(1,:) = 0.2*randn(1,N) + 1;
% data(2,:) = 0.2*randn(1,N) + 2;
% data(3,:) = 0.2*randn(1,N) + 3;

M1=reshape(Phi(:,n_mode(1)),len,10);
M2=reshape(Phi(:,n_mode(2)),len,10);
M3=reshape(Phi(:,n_mode(3)),len,10);

data(1,:)=normalize(M1(:,9));
data(2,:)=normalize(M2(:,10));
data(3,:)=normalize(M3(:,10));
radius = [data data(:,1)];             %# added first to last to create closed loop
min(radius(1,:))


radius(1,:) = smooth((radius(1,:)-min(radius(1,:)))/(max(radius(1,:))-min(radius(1,:))),10);
radius(2,:) = smooth((radius(2,:)-min(radius(2,:)))/(max(radius(2,:))-min(radius(2,:))),50);
radius(3,:) = smooth((radius(3,:)-min(radius(3,:)))/(max(radius(3,:))-min(radius(3,:))),55);
figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
flower(figure1,radius);
