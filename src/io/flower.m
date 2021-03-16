%% -------                    flower              ------- %%
%！ input： radius 一周的压力幅值
%！ output：DATA
%！ 功能：   画出压力圆周图
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%


function flower(figure1,radius)
% 创建 figure

% 创建 axes
axes1 = axes('Parent',figure1);
axis off
hold(axes1,'on');
center = [0 0];                        %# center (shift)

theta = linspace(5*pi/2, pi/2, 500)';  %# 'angles
r = max(radius(:));                    %# radius
x1 = r*cos(theta)+center(1);
y1 = r*sin(theta)+center(2);
plot(x1, y1, 'k:');
hold on
N=size(radius,2)-1;

%# draw labels
theta = linspace(5*pi/2, pi/2, N+1)';    %# 'angles
theta(end) = [];
r = max(radius(:));
r = r + r*0.2;                           %# shift to outside a bit
x = r*cos(theta)+center(1);
y = r*sin(theta)+center(2);
str = strcat(num2str((1:N)','%d'));   %# 'labels
%text(x, y, str, 'FontWeight','Bold');

%# draw the actual series
theta = linspace(5*pi/2, pi/2, N+1);
x = bsxfun(@times, radius, cos(theta)+center(1))';
y = bsxfun(@times, radius, sin(theta)+center(2))';
clr = parula(size(radius,1));
% 

if size(radius,1)==3
    plot(x(:,1), y(:,1),'DisplayName','m1:29','MarkerSize',2,'Marker','.','LineWidth',1,...
        'Color',[0 0 0]);
    plot(x(:,2), y(:,2),'DisplayName','m2:1/2','Marker','.','LineWidth',3,...
        'Color',[0 0.447058823529412 0.741176470588235]);
    plot(x(:,3), y(:,3),'DisplayName','m3:1','Marker','.','LineWidth',3,...
        'LineStyle','--',...
        'Color',[0 1 0]);
    hold on
else 
    hold off
    plot(x(:,1), y(:,1),'DisplayName','m','MarkerSize',2,'Marker','.','LineWidth',1);
end


axis off
hold(axes1,'off');
% 设置其余坐标区属性
set(axes1,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',...
    [1 1 1.08929892089437]);
% 创建 legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.449620775729646 0.371518547658106 0.151785714285714 0.129761904761905],...
    'FontSize',14,...
    'FontName','Helvetica Neue',...
    'EdgeColor',[1 1 1],...
    'Color',[0.941176470588235 0.941176470588235 0.941176470588235]);
end