%% -------   example-04：利用cfd数据进行time-delay DMD的验证   ------- %%
%！22个叶片;-3.4000e-05s 一个间隔
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
[fname_2,location_2]=uigetfile({'*.mat';'*.*'},'mat参数文件读取','MultiSelect','on');%MultiSelect单选
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


%% 最基本的DMD算法结果输出
% tecplot接口
tsignal.surfaces(1).zonename='mysurface zone';
tsignal.surfaces(1).x=XX;    %size 3x3 
tsignal.surfaces(1).y=ZZ;    %size 3x3
tsignal.surfaces(1).z=YY;    %size 3x3
tsignal.surfaces(1).v(1,:,:)=rpm{kk};%根据键向信号判读
tsignal.surfaces(1).solutiontime=kk;
NAME = [strrep(char(fname),type,'-'),'DPLA',num2str(if_RI),'-','scale',num2str(DPLA_Scale),'-',date];  %存储文件夹

Varnames=[NAME];
output_file_name=[save_directory,'/',NAME,'-',num2str(rotorSpeed),'.plt']; 
tsignal.Nvar=4;     
tsignal.varnames={'x','y','z',Varnames};
mat2tecplot(tsignal,output_file_name);







