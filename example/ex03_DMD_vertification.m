%% -------   example-04：利用cfd数据进行time-delay DMD的验证   ------- %%
%！22个叶片
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%
% 第一步，利用python批量提取csv
% 第二步，导入数据
% 第三步，将数据展开到2d平面，扫描
% 第四部，整理成DMD的形式


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
[fname,location]=uigetfile({'*.dat';'*.*'},'mat参数文件读取','MultiSelect','on');%MultiSelect单选
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
[zone1,VARlist1] = tec2mat(fullfile(location,char(fname(i_file)))); %选择文件导入数据
% Data=V2Pa_Universal(Data,kulite_transform_ab);
% %数据不需要取均值! Data(:,1:end-1)=Data(:,1:end-1);%-mean(Data(:,1:end-1));
% [rpm,tsignal,xuhao]=pltPlot_dB_universal(Data,fs,object,objectName,testTime,char(fname(i_file)),save_directory,DPLA,DPLA_Scale,'.mat');
% [tsignal2,EIGS,S,Phi]=computeDMD(n_mode,rotorspeed,rpm,tsignal,xuhao,save_directory,char(fname(i_file)));
% [the_freq,freq_dB]=frequencyDomainPlot_dB(Data,fs,2.56);
mat2dat(zone1,'test',VARlist1)
%figure;
%axis equal
%hold on
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
% figure;
% for k=1:max(BINX_1) 
% plot(x(BINXY_k{k}),y(BINXY_k{k}),'.');axis equal
% hold on
% end
Order=[];
for k=1:length(BINXY_k)
Order=[Order;BINXY_k{k}];
end
X_i=v(Order,:);
clearvars -except X_i save_directory i_file fname location
savename = [save_directory,'/',strrep(fname{i_file},'.dat','.mat')];
save(savename)
end

