%% -------   分块概念描述                                   ------- %%
%！220*110矩阵
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%

clc
clear
close all

m = rand(20, 10);  %demo matrix;
[colfrom, rowfrom, values] = improfile(m, [1, size(m, 2)], [1, size(m, 1)]);
figure
mesh(m)