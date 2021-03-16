% 分块算法，模拟实验的采样结果
% 前提假设多个传感器均匀布置
% 验证demo

% 问题1：m不被s整除；解决办法：扩展A矩阵
% 问题2：实践应用于圆柱扰流DMD分解
% 问题策略：将圆柱扰流拆分成5段，每段扫描到的时间为1，这样相当于5个时间步拼出一个完整的全周期信号
% 但只应用一个传感器
% 跟之前的5个传感器不一样，现在主要侧重于扫描速度

 clc
 %clear
 close all
 %run('/Users/wjq/Documents/Github-CI/Test_Repo/test/CODE/CH02_FLUIDS/computeDMD.m')
%load('monopole.mat')
clear A AA AA_all
% m为采样矩阵的总时间长度
m=5;
band=199*90;

% 不小于band个时间一周
n_round=450/90;
% AA=ones(m*band,m);
% [a,b]=meshgrid(1:m,1:m*band);
% AA=normalize(b.*AA);
data=VORTALL;
t=size(data,2);
X_all=[];AA_all=[];
for tk=1:floor(t/n_round)
AA=data(:,1+(tk-1)*n_round:tk*n_round);
AA_all=[AA_all AA];
% 设置实验等间距分布传感器个数
s=1;
n=ceil(m/s);

% 将矩阵补齐
for kk=1:n*s-m
    k=n*kk;
    AA=[AA(:,1:k) AA(:,k) AA(:,k+1:end)]; 
end
AA=[AA;AA(1:(n*s-m)*band,:)];

%% 采样矩阵A
for k3=1:s  
    for k2=1:s
        for k1=1:n
            A((k1+(k2-1)*n)*band-band+1:(k1+(k2-1)*n)*band,k1+(k3-1)*n)=ones(band,1);
        end
    end
end

%% 输出合成阵X
X=[];
for k2=1:s
    for k1=1:n_round
        index=find(A(:,k1)==1);
        X(index,k2)=AA(index,k1);
    end
end
% 重新将多余的列删掉
X(end-(n*s-m)*band+1:end,:)=[];
X_all=[X_all X];

end


figure
subplot(1,4,1)
imagesc(AA);
title('数据矩阵AA');
subplot(1,4,2)
imagesc(AA_all);
title('数据矩阵AA_a_l_l');
subplot(1,4,3)
imagesc(A);
title('采样矩阵A');
subplot(1,4,4)
imagesc(X_all);
title('采样矩阵X');


for k=1:size(X_all,2)
    X_all1{k}=reshape(X_all(:,k),128,128);
end
figure
for k=1:size(X_all,2)
    imagesc(X_all1{k}, [-0.5, 0.5]);axis equal
    pause(0.4)
end



%% 接下来就是进行DMD操作，观察不同传感器结果的差别
X =  X_all(:,1:end-1);
X2 = X_all(:,2:end);
[U1,S1,V1] = svd(X,'econ');

%  Compute DMD (Phi are eigenvectors)
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
% 创建 xlabel
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

