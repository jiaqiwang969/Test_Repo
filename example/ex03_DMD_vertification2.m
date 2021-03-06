%% -------   example-04：利用cfd数据进行time-delay DMD的验证   ------- %%
%！22个叶片;-3.4000e-05s 一个间隔;16043
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%
% 第一步，利用python批量提取csv
% 第二步，导入数据
% 第三步，将数据展开到2d平面，扫描
% 第四步，整理成DMD的形式
% 第五步，转换回tecplot


%1-Time;%2-Density;%3-Points:0;%4-Points:1%5-Points:2%6-Static Pressure	
%7-Vm%8-Vorticity vector:0%9-Vorticity vector:1%10-Vorticity vector:2	
%11-Vr	%12-Vt	%13-Vxyz:0	%14-Vxyz:1	%15-Vxyz:2	%16-Wt	%17-Wxyz:0	
%18-Wxyz:1	%19-Wxyz:2

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
VORTALL(:,i_file)=X_i(:,18);
end


X = VORTALL(:,1:end-1);
X2 = VORTALL(:,2:end);
[U1,S1,V1] = svd(X,'econ');

%%  Compute DMD (Phi are eigenvectors)
r =9; %length(rpm)-1;  % truncate at 21 modes
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
dT=3.4000e-05;
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



%% 接下来的工作就是将模态还原回去，Phi，重新装到那个structure里面
% 选一个典型的代表
[zone1,VARlist1] = tec2mat('/Users/wjq/Documents/Github-CI/Test_Repo/data/B2B_65layer/B2B65layer_09016_t1.dat'); %选择文件导入数据

filed=[];
x=[];
y=[];
v=[];
for k=1:154
filed{k}=reshape(zone1(k).data,zone1(k).I*zone1(k).J,length(VARlist1));

[theta,rho,z] = cart2pol(filed{k}(:,1),filed{k}(:,2),filed{k}(:,3));
%plot(theta,z,'.')
x=[x;theta];
y=[y;z];
v=[v;filed{k}(:,1:18)];

end

%% 从左到右,从下到上依次-"扫描仪"，后面可以对该方法对有效性做进一步验证！
nbins = [220 330]; %10*叶片数
[N,Xedges,Yedges,BINX,BINY] = histcounts2(x,y,nbins);
% figure
% image(N)
% max(max(N))

[BINX_1,BINX_ii]=sort(BINX);

for k=1:max(BINX_1)
    
    [BINX_k]=find(BINX_1==k);
    order=BINX_ii(BINX_k);         %BINX_1的序号
    BINY_k=BINY(order);            %BINX_1的序号下Y的序号
    [BINY_k_1,BINY_k_ii]=sort(BINY_k);   %对k序号下的Y进行排序
    BINXY_k{k}=order(BINY_k_ii);              %最终得到x在某个区间内，y逐渐递增的序列
    
end
% 画图可以验证，扫描仪的第一列
figure;
for k=1:max(BINX_1) 
    plot(x(BINXY_k{k}),y(BINXY_k{k}),'.');axis equal
    hold on
end
Order=[];
for k=1:length(BINXY_k)
    Order=[Order;BINXY_k{k}];
end


% 还原回去？验证一下
[Order_1,Order_ii]=sort(Order);
Phi_back=Phi(Order_ii,:);
xuhao_1=1;xuhao_2=0;
for k=1:154
    xuhao_2=xuhao_1+zone1(k).I*zone1(k).J-1;
for m_order=[1:r]
    zone1(k).data(:,:,3+m_order)=reshape(Phi_back(xuhao_1:xuhao_2,m_order),zone1(k).I,zone1(k).J);
end
    xuhao_1=xuhao_2+1;
end
VARlist2{1}=VARlist1{1};VAlist2{2}=VARlist1{2};VARlist2{3}=VARlist1{3};
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

mat2dat(zone1,'test3',VARlist2);

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



  