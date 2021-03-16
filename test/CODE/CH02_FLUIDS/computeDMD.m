clear all, close all, clc
load ../DATA/FLUIDS/CYLINDER_ALL.mat
for dT=1:10
caiyang=[1:dT:size(VORTALL,2)]
VORTALL_caiyang=VORTALL(:,caiyang);
X = VORTALL_caiyang(:,1:end-1);
X2 = VORTALL_caiyang(:,2:end);
[U,S,V] = svd(X,'econ');

%%  Compute DMD (Phi are eigenvectors)
r = 7;  % truncate at 21 modes
U = U(:,1:r);
S = S(1:r,1:r);
V = V(:,1:r);
Atilde = U'*X2*V*inv(S);
[W,eigs] = eig(Atilde);
Phi = X2*V*inv(S)*W;


%% figure3-b-1 DMD 相对坐标系，模态
EIGS=diag(eigs);
% 物理频率
omega=log(EIGS)/dT;
f=imag(omega)/2/pi;


%% Compute DMD mode amplitudes b
    x = X(:, 1);%(based on first snapshot)
    b = pinv(Phi)*x;
    
    
%     figure;
%     plot(abs(b));
%     

% Si=diag(S);
X1 = f;
% Y1 = log2(Si/2e-5);
Y1 =abs(b);

list=[find(f>=0 & f<0.15)];
[temp1,temp2]=sort(Y1(list),'descend');

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
%ylim(axes1,[32 44]);
box(axes1,'on');
hold(axes1,'off');
 for i=1:length(list)
     text(X1(list(temp2(i))),Y1(list(temp2(i)))+0.4,num2str(i),'FontSize',18,'Color',[1 0 0]);
 end
title(['dT:',num2str(dT)])

end
% 
% figurexx
% %% Plot DMD modes
% for i=10:2:20
%     plotCylinder(reshape(real(Phi(:,i)),nx,ny),nx,ny);
%     plotCylinder(reshape(imag(Phi(:,i)),nx,ny),nx,ny);
% end
% 
% %%  Plot DMD spectrum
% figure
% theta = (0:1:100)*2*pi/100;
% plot(cos(theta),sin(theta),'k--') % plot unit circle
% hold on, grid on
% scatter(real(diag(eigs)),imag(diag(eigs)),'ok')
% axis([-1.1 1.1 -1.1 1.1]);
% % 
% %% Plot DMD modes
% for i=9
%     figure
%     plotCylinder(reshape(real(Phi(:,i)),nx,ny),nx,ny);
% %     figure
% %     plotCylinder(reshape(imag(Phi(:,i)),nx,ny),nx,ny);
% end

% 
% % 
% % f1 = figure
% % for i=1:151
% %     plotCylinder(reshape((VORTALL(:,i)),nx,ny),nx,ny);
% %     pause(0.1)
% %     %close all 
% % 
% % end
% 
% 
