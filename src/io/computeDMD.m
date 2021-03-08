%% -------                  computeDMD                    ------- %%
%！ input： rpm,tsignal,xuhao,save_directory,name
%！ output：tsignal2,EIGS
%！ 功能：   DMD 模态分解
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%

function [tsignal2,EIGS,S,Phi]=computeDMD(n_mode,rotorspeed,rpm,tsignal,xuhao,save_directory,name)
% dt=T/length(rpm);

for kk=1:length(rpm)
    Len(kk)=length(rpm{1,kk});
end
len=min(Len);
for kk=1:length(rpm)
    VORTALL(:,kk)=reshape(rpm{1,kk}(1:len,:),1,[])';%按列
end

X = VORTALL(:,1:end-1);
X2 = VORTALL(:,2:end);
[U,S,V] = svd(X,'econ');

%%  Compute DMD (Phi are eigenvectors)
r =n_mode; %length(rpm)-1;  % truncate at 21 modes
U = U(:,1:r);
S = S(1:r,1:r);
V = V(:,1:r);
Atilde = U'*X2*V*inv(S);
[W,eigs] = eig(Atilde);
Phi =real(X2*V*inv(S)*W);
EIGS=diag(eigs);

%% Compute DMD mode amplitudes b
x = X(:, 1);
b = pinv(Phi)*x;



% 时间间隔
dT=1/(rotorspeed/60);
% 物理频率
omega=log(EIGS)/dT;
f=imag(omega)/2/pi;
% 剔出频率为0的，除了第一个意以外
list=[1;find(f>0 & f<100)];

%list=[1,2,3,4,5]

%% 最基本的DMD算法结果输出
tsignal2.Nvar= tsignal.Nvar;
tsignal2.varnames= tsignal.varnames;
for kk=1:r
    tsignal2.surfaces(kk).zonename= tsignal.surfaces(1).zonename;
    tsignal2.surfaces(kk).x= tsignal.surfaces(1).x;
    tsignal2.surfaces(kk).y= tsignal.surfaces(1).y;
    tsignal2.surfaces(kk).z= tsignal.surfaces(1).z;
    tsignal2.surfaces(kk).v= reshape(Phi(:,kk),1,len,10);
    %tsignal2.surfaces(kk).v(1,xuhao,:)=1.1*max(Phi(:,kk));
    tsignal2.surfaces(kk).solutiontime=kk;
end
mat2tecplot(tsignal2,[save_directory,'/',name,'.plt']);

%% DMD reconstruction全模态 及其 单个模态（除去背景）分析-并输出tecplot
mm1 = size(X, 2); % mm1 = m - 1
t = (0:mm1 -1)*dT; % time vector
Xdmd_recon = Phi*diag(b)*exp(omega*t);

%选取前10%
n=round(length(omega)*0.1);
if mod(n,2) == 0
    n=n+1;
end
Omega=abs(omega); oder_Omeag=sort(Omega(:));
[m1]=find(Omega<=oder_Omeag(n));
[m2]=find(Omega>oder_Omeag(n));
Xdmd_background=Phi(:,m1)*diag(b(m1))*exp(omega(m1)*t);
Xdmd_left=Phi(:,m2)*diag(b(m2))*exp(omega(m2)*t);

Tsignal.Nvar= 8;
Tsignal.varnames= tsignal.varnames;

Tsignal.varnames{1, 4}=['Xdmd_recon'];
Tsignal.varnames{1, 5}=['Xdmd_background'];
Tsignal.varnames{1, 6}=['Xdmd_left'];
Tsignal.varnames{1, 7}=['X_real'];
Tsignal.varnames{1, 8}=['X_real-Xdmd_background'];
for kk=1:length(t)
    Tsignal.surfaces(kk).zonename= tsignal.surfaces(1).zonename;
    Tsignal.surfaces(kk).x= tsignal.surfaces(1).x;
    Tsignal.surfaces(kk).y= tsignal.surfaces(1).y;
    Tsignal.surfaces(kk).z= tsignal.surfaces(1).z;
    Tsignal.surfaces(kk).v(1,:,:)= reshape(abs(Xdmd_recon(:,kk)),len,10);
    Tsignal.surfaces(kk).v(2,:,:)= reshape(abs(Xdmd_background(:,kk)),len,10);
    Tsignal.surfaces(kk).v(3,:,:)= reshape(abs(Xdmd_left(:,kk)),len,10);
    Tsignal.surfaces(kk).v(4,:,:)= reshape(tsignal.surfaces(kk).v(1,1:len,:),len,10);
    Tsignal.surfaces(kk).v(5,:,:)= reshape(tsignal.surfaces(kk).v(1,1:len,:),len,10)-reshape(abs(Xdmd_background(:,kk)),len,10);
    
    Tsignal.surfaces(kk).solutiontime=kk;
end
mat2tecplot(Tsignal,[save_directory,'/',name,'DMD-backgroundRemoval','.plt']);






end