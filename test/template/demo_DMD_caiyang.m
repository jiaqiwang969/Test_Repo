% 分块算法，模拟实验的采样结果
% 前提假设多个传感器均匀布置
% 验证demo

% 问题1：m不被s整除；解决办法：扩展A矩阵

% clc
% clear
% close all
% run('/Users/wjq/Documents/Github-CI/Test_Repo/test/template/exampleOfMonopole.m')
load('monopole.mat')
clear A AA AA_all
data=sensor_data.p;
tl=size(data,2); %仿真或实验的总时间步数
% 给定已知采样数据
xband=128; %一个时间步内x轴的全部采样数据, 也可以认为是周向上的数据
yband=128; %一个时间步内y轴的全部采样数据
%总传感器数目为：xband*s个
s_band=3;   %x轴一次扫描到的点数，相当于并排挨着布置的传感器数目
s_cir=3;    % 设置实验等间距分布传感器个数，周向布置的传感器数
n_round= 110; % 截断时间数，键向信号截断,提前规定好
n_r=ceil(n_round/(s_band*s_cir));  % n_round个时间步拼出一个时间步需要的时间步数


%%
% 周向传感器的作用：AA矩阵多好几列边带，
X_all=[];AA_all=[];
for tk=1:floor(tl/n_r) % 总时间步经过时延最后拼接得到的序列数目
% % 数据加工截断，n_r输出一列
% AA=data(:,1+(tk-1)*n_r:tk*n_r);  
% % 在实际测试中，矩阵AA非完全整数倍关系
% % 即，时间方向上s_cir传感器的整数倍，
% % 以及，空间方向上
% n=ceil(m/s_cir);
% % 将矩阵补齐
% for kk=1:n*s_cir-m
%     k=n*kk;
%     AA=[AA(:,1:k) AA(:,k) AA(:,k+1:end)]; 
% end
% AA=[AA;AA(1:(n*s_cir-m)*yband,:)];

%% 采样矩阵A，采样矩阵的列数提前已经规定好（锁相）
for k3=1:s_cir  
    for k2=1:s_cir
        for k1=1:n
            A((k1+(k2-1)*n)*yband-yband+1:(k1+(k2-1)*n)*yband,k1+(k3-1)*n)=ones(yband,1);
        end
    end
end
% 
% %% 输出合成阵X
% X=[];
% for k2=1:s_cir
%     for k1=1:n_r
%         index=find(A(:,k1)==1);
%         X(index,k2)=AA(index,k1);
%     end
% end
% % 重新将多余的列删掉
% X(end-(n*s_cir-m)*yband+1:end,:)=[];
% X_all=[X_all X];

end


figure
subplot(1,4,1)
imagesc(AA);
title('数据矩阵AA');
subplot(1,4,2)
imagesc(data);
title('数据矩阵AA_a_l_l');
subplot(1,4,3)
figure
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
dT=3.4000e-05*n_r;
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

