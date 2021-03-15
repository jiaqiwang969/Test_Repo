%% -------   example-04：利用cfd数据进行time-delay DMD的验证   ------- %%
%！22个叶片;-3.4000e-05s 一个间隔，一周440步，4步一个间隔
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%
% 模拟实验斜排阵列的处理效果
% 思路：之前利用"扫描仪"已经将每圈数据分为220份，现在110个这样的数据输出一个结果
% 2份，2份的拼接在一起，就得到了类似实验的假设效果，妙呀！
% 如果只关注单纯叶片处的序列，需要进一步进行y方向的拆块序列记录
% 如果斜排，暂时做不到（需要扫描仪做调整），但应该不影响参数，暂时不讨论该影响

%1-Time;%2-Density;%3-Points:0;%4-Points:1%5-Points:2%6-Static Pressure	
%7-Vm%8-Vorticity vector:0%9-Vorticity vector:1%10-Vorticity vector:2	
%11-Vr	%12-Vt	%13-Vxyz:0	%14-Vxyz:1	%15-Vxyz:2	%16-Wt	%17-Wxyz:0	
%18-Wxyz:1	%19-Wxyz:2

% 研究1：传感器布置数量对DMD效果的影响，传感器选择对称布置

clc
clear
close all

%% io接口
output='CFD_DMD验证结果';
% 导入函数路径
addpath(genpath('/Users/wjq/Documents/Github-CI/Test_Repo/src'));  
% 导入data路径，
%通过gui导入! 
%[fname_2,location_2]=uigetfile({'*.mat';'*.*'},'mat参数文件读取','MultiSelect','on');%MultiSelect单选
number=9016:4:14012;
for k=1:length(number)
    fname_2{1,k}=['B2B65layer_',num2str(number(k),'%05d'),'_t1.mat'];
end

location_2='/Users/wjq/Documents/Github-CI/Test_Repo/data/CFD_DMD/';
% 保存路径, 创建目录
save_directory = [mfilename,'/',output,'-',date];  %频谱图存储文件夹
if ~exist(save_directory)
    mkdir(save_directory)
else
    disp('文件夹存在！');
end
% % //========================================  
if isstr(fname_2)
   fname_2=cellstr(fname_2);
end
% 备份
copyfile([mfilename,'.m'] , save_directory)

% 生成X矩阵
VORTALL=[];
for i_file=1:length(fname_2)
load(fullfile(location_2,char(fname_2(i_file)))); %选择文件导入数据
VORTALL(:,i_file)=X_i(:,18); %将其转化为11列，1250/110=11.3636
end

% VORTALL 是已经应用扫描仪以后的效果

%% 首先，由于VORTALL的数据格点不按照规律排列，需要先进行转化
%  先利用"扫描仪"进行扫描操作，使得按照从左到右顺序排列，共220份
%  一定要记录220分的序列号，以便对110列的打散拼接操作
% 注：总结后，将其转化为function，输出参数。

sensor=2;%表示分成几份


examplefile='/Users/wjq/Documents/Github-CI/Test_Repo/data/B2B_65layer/B2B65layer_09016_t1.dat';
nbins=[220,330];
[zone1,VARlist1,BINXY_k,Order,x,y]=scanner(examplefile,nbins);
n_round=110; %一周110个序列
n=nbins(1)/n_round;
VORTALL_delay=[];
% initial xuhao
xuhao_BINXY_k(1,1)=length(BINXY_k{1});
for k=1:length(BINXY_k)-1
    xuhao_BINXY_k(1,k+1)=xuhao_BINXY_k(1,k)+length(BINXY_k{k+1});
end
xuhao_BINXY_k=[0 xuhao_BINXY_k];
xuhao_1=1;xuhao_2=0;
for k=1:floor(length(fname_2)/n_round)*sensor
    X_delay=[];
    for kk=1:floor(n_round/sensor)
        for kkk=1:sensor
            st1=xuhao_BINXY_k(2*kk-1)+1 ;
            en1=xuhao_BINXY_k(2*kk+n-1) ;
            X_delay(st1:en1,1)=VORTALL(st1:en1,(k-1)*n_round+kk);     
        end       
    end
    VORTALL_delay(:,k)=X_delay;
end


X =  VORTALL_delay(:,1:end-1);
X2 = VORTALL_delay(:,2:end);
[U1,S1,V1] = svd(X,'econ');

%%  Compute DMD (Phi are eigenvectors)
r =7; %length(rpm)-1;  % truncate at 21 modes
U = U1(:,1:r);
S = S1(1:r,1:r);
V = V1(:,1:r);
Atilde = U'*X2*V*inv(S);
[W,eigs] = eig(Atilde);
Phi =real(X2*V*inv(S)*W);
EIGS=diag(eigs);

%% Compute DMD mode amplitudes b
x = X(:, 1);
b = pinv(Phi)*x;



% 时间间隔
dT=3.4000e-05*n_round;
% 物理频率
omega=log(EIGS)/dT;
f=imag(omega)/2/pi;


% 剔出频率为0的，除了第一个意以外
%list=[1;find(f>0 & f<400)];

fig1=figure 
theta = (0:1:100)*2*pi/100;
plot(cos(theta),sin(theta),'k-.') % plot unit circle
hold on

plot(0.6*cos(theta),0.6*sin(theta),'k--') % plot unit circle

hold on, grid on
real_eigs=real(EIGS);
imag_eigs=imag(EIGS);
scatter(real_eigs,imag_eigs,'ok')

% for i=1:3
%text(real_eigs(list(i))-0.02,imag_eigs(list(i))+0.07,num2str(i),'FontSize',18,'Color',[1 0 0])
%end
axis([-1 1 -1 1]);
axis equal
grid off
xlim([-1 1]);
ylim([-1 1]);
axis off
%saveas(fig1,[save_directory,'/','fig3-a-unitCicle','.fig'])


%% figure3-b-1 DMD 相对坐标系，模态

Si=diag(S);
X1 = f;
Y1 = log2(Si/2e-5);

% 创建 figure
fig2 = figure('Color',[1 1 1]);
%axes1 = axes('Parent',fig2,'Position',[0.13 0.60238 0.775 0.3642857]);
axes1 = axes('Parent',fig2);
hold(axes1,'on');

% 创建 stem
stem1 = stem(X1,Y1,'MarkerFaceColor',[0 0 0],'Color',[0 0 0]);
baseline1 = get(stem1,'BaseLine');
set(baseline1,'Visible','on');
set(axes1,'FontSize',14)
% 创建 ylabel
ylabel({'Amplitude/log2'},'FontSize',14);
% 创建 xlabe
%xlabel({'DMD frequency, imag(\lambda_k)/ Hz','FontSize',14});
%xlabel({'SVD eigenvalue','FontSize',14});
% 取消以下行的注释以保留坐标区的 X 范围
 %xlim(axes1,[-1 100]);
% 取消以下行的注释以保留坐标区的 Y 范围
ylim(axes1,[25 50]);
box(axes1,'on');
hold(axes1,'off');
%  for i=1:3
%      text(i,Y1(i)+0.4,num2str(i),'FontSize',18,'Color',[1 0 0]);
%  end


% 还原回去？验证一下
[Order_1,Order_ii]=sort(Order);

%% 自由切换模态和"实验采集"
%Phi_back=VORTALL_delay(Order_ii,:);
Phi_back=Phi(Order_ii,:);

%%

xuhao_1=1;xuhao_2=0;
for k=1:154
    xuhao_2=xuhao_1+zone1(k).I*zone1(k).J-1;
for m_order=[1:r]
    zone1(k).data(:,:,3+m_order)=reshape(Phi_back(xuhao_1:xuhao_2,m_order),zone1(k).I,zone1(k).J);
end
    xuhao_1=xuhao_2+1;
end
VARlist2{1}=VARlist1{1};VAlist2{2}='Y axis';VARlist2{3}=VARlist1{3};
VARlist2{4}='m1';
VARlist2{5}='m2';
VARlist2{6}='m3';
VARlist2{7}='m4';
VARlist2{8}='m5';
VARlist2{9}='m6';
VARlist2{10}='m7';
VARlist2{11}='m8';
VARlist2{12}='m9';
VARlist2{13}='m10';
VARlist2{14}='m11';
VARlist2{15}='m12';
VARlist2{16}='m13';
VARlist2{17}='m14';
VARlist2{18}='m15';
mat2dat(zone1,'test6',VARlist2);

% 验证 
x_back=x(Order_ii);
y_back=y(Order_ii);
xuhao_1=1;xuhao_2=0;
figure;

for kk=1:154
    xuhao_2=xuhao_1+zone1(kk).I*zone1(kk).J-1;  
    %for m_order=1:15
        plot(x(xuhao_1:xuhao_2),y(xuhao_1:xuhao_2),'.');axis equal
        hold on
        %pause
    %end
    xuhao_1=xuhao_2+1;
    
end



  