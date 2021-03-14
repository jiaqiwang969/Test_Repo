%% -------   function scanner：重新排列cfd仿真的网格序列   ------- %%
%！22个叶片;-3.4000e-05s 一个间隔，一周440步，4步一个间隔
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%
% examplefile为标准的tecplot输出文件
% nbins为切分厚度，例如[220,330]
% 输出BINXY_k为记录的序列号
function [zone1,VARlist1,BINXY_k,Order,x,y]=scanner(examplefile,nbins)
%% 记录扫描拆块序列号
% 选一个典型的代表
[zone1,VARlist1] = tec2mat(examplefile); %选择文件导入数据

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
%nbins = [220 330]; %10*叶片数
[N,Xedges,Yedges,BINX,BINY] = histcounts2(x,y,nbins);
% figure
% image(N)
% max(max(N))

[BINX_1,BINX_ii]=sort(BINX);

for k=1:max(BINX_1) %关键在这里！！
    
    [BINX_k]=find(BINX_1==k);
    order=BINX_ii(BINX_k);         %BINX_1的序号
    BINY_k=BINY(order);            %BINX_1的序号下Y的序号
    [BINY_k_1,BINY_k_ii]=sort(BINY_k);   %对k序号下的Y进行排序
    BINXY_k{k}=order(BINY_k_ii);              %最终得到x在某个区间内，y逐渐递增的序列
    
end
% 画图可以验证，扫描仪的第一列
figure;
for k=1:max(BINX_1)  %220分
    plot(x(BINXY_k{k}),y(BINXY_k{k}),'.');axis equal
    hold on
end



Order=[];
for k=1:length(BINXY_k)
    Order=[Order;BINXY_k{k}];
end

end