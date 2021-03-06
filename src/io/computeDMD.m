%% -------                  computeDMD                    ------- %%
%！ input： rpm,tsignal,xuhao,save_directory,name
%！ output：tsignal2,EIGS
%！ 功能：   DMD 模态分解
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%

function [tsignal2,EIGS]=computeDMD(rpm,tsignal,xuhao,save_directory,name)
% dt=T/length(rpm);

for kk=1:length(rpm)
    len(kk)=length(rpm{1,kk});
end
[q1,q2]=min(len)
for kk=1:length(rpm)
    VORTALL(:,kk)=reshape(rpm{1,kk}(1:min(len),:),1,[])';%按列
end

X = VORTALL(:,1:end-1);
X2 = VORTALL(:,2:end);
[U,S,V] = svd(X,'econ');

%%  Compute DMD (Phi are eigenvectors)
r =30; %length(rpm)-1;  % truncate at 21 modes
U = U(:,1:r);
S = S(1:r,1:r);
V = V(:,1:r);
Atilde = U'*X2*V*inv(S);
[W,eigs] = eig(Atilde);
Phi =real(X2*V*inv(S)*W);
EIGS=diag(eigs);


%% figure3-b DMD 相对坐标系，模态
% 时间间隔
dT=1/(mean(12000)/60);
% 物理频率
f=imag(log(EIGS)/dT)/2/pi;
% 剔出频率为0的，除了第一个意以外
list=[1;find(f>0 & f<97)];
Si=diag(S);
X1 = f(list);
Y1 = log2(Si(list)/2e-5);

% 创建 figure
figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% 创建 stem
stem1 = stem(X1,Y1,'MarkerFaceColor',[0 0 0],'Color',[0 0 0]);
baseline1 = get(stem1,'BaseLine');
set(baseline1,'Visible','on');

% 创建 ylabel
ylabel({'Amplitude/log2'});

% 创建 xlabel
xlabel({'DMD frequency, imag(\lambda_k)'});

% 取消以下行的注释以保留坐标区的 X 范围
 xlim(axes1,[0 100]);
% 取消以下行的注释以保留坐标区的 Y 范围
 ylim(axes1,[32 44]);
box(axes1,'on');
hold(axes1,'off');
saveas(figure1,[save_directory,'/','fig3-b2,DMD frequcy','.fig'])







%%
tsignal2.Nvar= tsignal.Nvar;
tsignal2.varnames= tsignal.varnames;
for kk=1:r
tsignal2.surfaces(kk).zonename= tsignal.surfaces(q2(1)).zonename;
tsignal2.surfaces(kk).x= tsignal.surfaces(q2(1)).x;
tsignal2.surfaces(kk).y= tsignal.surfaces(q2(1)).y;
tsignal2.surfaces(kk).z= tsignal.surfaces(q2(1)).z;
tsignal2.surfaces(kk).v= reshape(Phi(:,kk),1,min(len),10); 
%tsignal2.surfaces(kk).v(1,xuhao,:)=1.1*max(Phi(:,kk));
tsignal2.surfaces(kk).solutiontime=kk;
end
mat2tecplot(tsignal2,[save_directory,'/',name,'.plt']);
%% Plot DMD modes

% for i=10:2:20
%     figure
%     imagesc(reshape(real(Phi(:,i)),min(len),10)); % plot vorticity field
%     figure
%     imagesc(reshape(real(Phi(:,i)),min(len),10)); % plot vorticity field
% % 
% %     plotCylinder(reshape(real(Phi(:,i)),min(len),10),min(len),10);
% %     plotCylinder(reshape(imag(Phi(:,i)),min(len),10),min(len),10);
% end
% 
%% figure3 a） Plot DMD spectrum
% Complex eigenvalues λ_k scattered in the unit circle   
%    (truncated at 30th mode in the case)
h=figure 
theta = (0:1:100)*2*pi/100;
plot(cos(theta),sin(theta),'k--') % plot unit circle
hold on, grid on
real_eigs=real(diag(eigs));
imag_eigs=imag(diag(eigs));
scatter(real_eigs,imag_eigs,'ok')
% for i=1:length(eigs)
% text(real_eigs(i),imag_eigs(i),num2str(i))
% end
axis([-1.1 1.1 -1.1 1.1]);
axis equal
saveas(h,[save_directory,'/',name,'.png'])



%% figure-3b The raw data and top 3 normalized dynamic modes
% 备注：输出结果，再tecplot做cutoff，输出eps格式！

tsignal3.Nvar= tsignal.Nvar;
tsignal3.varnames= tsignal.varnames;
% 名字标签
tsignal3.varnames{1, 4} = 'Normalized';
% 将几个模态图合并成一个，但tecplot出现自动粘连问题
% 解决办法：将该处设置偏离较大的值，然后通过tecplot的cutoff功能抠除
% 空间布置
n=3; space=100;
n_mode=[1,2,4];
x=tsignal.surfaces(q2(1)).x;
y=tsignal.surfaces(q2(1)).y;
z=tsignal.surfaces(q2(1)).z;
%中间值
x_middle1=x(1,:)-1;x_middle2=x(end,:)-1;
y_middle1=y(1,:);y_middle2=y(end,:);
z_middle1=z(1,:);z_middle2=z(end,:);

%嵌入的偏离值 
%div=(min(min(Phi))-max(max(Phi)))*ones(1,10);
%div=max(max(Phi))*ones(1,10);
div = 3.2*ones(1,10);

% 初始设为空；如果输出, 设为snapshot of raw data。
tsignal3.surfaces.x =[x;x_middle1]; tsignal3.surfaces.y =[y;y_middle1]; tsignal3.surfaces.z =[z;z_middle1];
tsignal3_v=[normalize(reshape(tsignal.surfaces(51).v,min(len),10));div];%随意取


for k=1:n
    tsignal3.surfaces.x=[tsignal3.surfaces.x;x_middle1;x;x_middle2];
    tsignal3.surfaces.y=[tsignal3.surfaces.y;y_middle1 + (k)*space;y + (k)*space;y_middle2 + (k)*space];
    tsignal3.surfaces.z=[tsignal3.surfaces.z;z_middle1;z;z_middle2];
    tsignal3_v=[tsignal3_v;div;normalize(reshape(Phi(:,n_mode(k)),min(len),10));div];
end

tsignal3.surfaces.v=reshape(tsignal3_v,1,min(len)+1+(min(len)+2)*n,10);
tsignal3.surfaces.solutiontime=1;
mat2tecplot(tsignal3,[save_directory,'/',name,'-union.plt']);






end