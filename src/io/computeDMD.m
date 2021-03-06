%% -------                  computeDMD                    ------- %%
%！ input： rpm,tsignal,xuhao,save_directory,name
%！ output：tsignal2,EIGS
%！ 功能：   DMD 模态分解
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%

function [tsignal2,EIGS,S]=computeDMD(rpm,tsignal,xuhao,save_directory,name)
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