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
% 给定已知采样数据
m=128;
band=128;
% 不小于band个时间一周
n_round=128;
% AA=ones(m*band,m);
% [a,b]=meshgrid(1:m,1:m*band);
% AA=normalize(b.*AA);
data=sensor_data.p;
t=size(data,2);
X_all=[];AA_all=[];
for tk=1:floor(t/n_round)
AA=sensor_data.p(:,1+(tk-1)*n_round:tk*n_round);
AA_all=[AA_all AA];
% 设置实验等间距分布传感器个数
s=2;
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




