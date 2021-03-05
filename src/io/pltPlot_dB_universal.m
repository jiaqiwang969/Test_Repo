%% -------               pltPlot_dB_universal              ------- %%
%！ input： signal,fs,object,objectName,testTime,fname,save_directory,if_RI,type
%！ output：rpm,tsignal,xuhao,Rotor_Speed
%！ 功能：   数据转化及输出
%% -------   Jiaqiwang969@gmail.com  SJTU SVN              ------- %%



function [rpm,tsignal,xuhao,Rotor_Speed]=pltPlot_dB_universal(signal,fs,object,objectName,testTime,fname,save_directory,if_RI,type,DPLA_Scale)

[Pulse,Rotor_Speed] = keyRotation_RealTime(signal(1:end,end),fs); %通过键向信号获取转速信息.去头去尾      
H_if_RI=1:(length(Rotor_Speed)-1);

%% 添加失速双锁相功能
%---------------%%%%%--------可注释掉-------------%%%%%---------------------
if if_RI ==1
    S_data =smooth(signal(:,object(9)),2000,'loess' );%低通滤波%作为失速启动的键向信号
    Threshold=mean(S_data);%默认值----->调整参数 
%！    查看信号与否
%     figure
%     plot(signal(:,object(9)));hold on
%     plot(S_data);hold on
%     plot([1 204800],[Threshold Threshold]);
%     title('确认失速')
% 
% 
%     disp(['~请再次确认',char(fname),'是否是失速工况？'])
%     disp(['~需观察是否在频谱图上观察到失速旋转频率和其倍频？如无，非失速工况'])
%     disp(['~以及确认Threshold值，是否在红线之间？'])
%     prompt = '观察失速运动情况为1；观察一周变化为0；';
%     pause

    [Pulse_RI,RI_Speed] = RI_RealTime(S_data,fs,Threshold); %通过键向信号获取失速相位信息 

    % 每圈都找对应的失速相位
    for NumPhase=1:length(Pulse)
        temp_Phase=Pulse_RI./Pulse(NumPhase);
        temp_order=find(temp_Phase<1);
        if isempty(temp_order)
            continue
        end
        if temp_order(end)==length(Pulse_RI)
            break
        end
     
        Phase(NumPhase,:)=(1-(Pulse(NumPhase)-Pulse_RI(temp_order(end)))/(Pulse_RI(temp_order(end)+1)-Pulse_RI(temp_order(end))))*360;   
    end
    [RI_order(:,1),RI_order(:,2)]=sort(+Phase);%一个符号绝对旋转方向
    H_if_RI=RI_order(:,2)';
end     
%----------------%%%%---------------------%%%%%---------------------

for k=1:length(Pulse)  %每转一圈刷新一次网格，一个时间步！%按照RI_marker排序
    %% 计算和安排相对位置关系
    distance_key_rotor=6;%键向位置和最近叶片之间的距离
    R_rotor=184.4002;%mm/动叶半径
    x=[2;4.41;7.68;11.14;14.39;17.41;20.73;23.77;26.63;34];
    y_2=[20.29;24.92;29.60;35.37;40.80;44.83;49.71;55.40;59.70;72.36];
    %叶片排整理成横排！y_2=[0;0;0;0;0;0;0;0;0;0];
    distance_point_B1_R1=3.8*R_rotor*2*pi/29;
    distance_point_B1_C1=5.3/360*R_rotor*2*pi;%17.0575mm;将C1移到70mm，差值为（70-17.0575）mm
    distance_pointR1_R1=R_rotor*2*pi/29;
    interval(k)=Rotor_Speed(k)/60*R_rotor/fs*2*pi;
    round_point(k)=distance_pointR1_R1*29/interval(k);%一周的点数
    len(k)=floor(round_point(k))-2+3;%=130;%调节显示节点个数;取一周围成一个三维的圈
    point_Pulse_rotor(k)=round(distance_key_rotor/interval(k)); %%%12000-（19*1.6092）；13000-（12*1.7433）；10000-（5*1.0740）；11000-（-2*1.3598）；125000-（16*1.6763）
    point_rotor_rotor(k)=round_point(k)/29; %两个叶片之间的距离来推算采样一个叶道的点数 %144000/BPF
    %暂时用不到这个参数! tran_C1=(70-distance_point_B1_C1)/interval;%C1实际点位和理想点位差23.2235个点位，C1前移23个点位,第24
    point_B1_R1_interval(k,1)=round(distance_point_B1_R1./interval(k));  %B1与R1差52.5761个点位，R1-R8前移53个点位，第54
    point_B1_C1_interval(k,1)=round((y_2(end)-y_2(1)-distance_point_B1_C1)./interval(k));  %%17.0575mm;将C1移到70mm，差值为（70-17.0575）mm
end


%% 生成网格矩阵
% 为保证转速差异不影响数据结构，对数据进行最小截断
Len= min(len);
Interval=max(interval);
Point_rotor_rotor=min(point_rotor_rotor);
Point_Pulse_rotor=min(point_Pulse_rotor);
% 构建2d环形surface
y_1=(1:Len+1)*Interval;
X = repmat(x,size(y_1))';
yy_1 = repmat(y_1,size(x))';
yy_2=repmat(y_2,size(y_1))';
Y=yy_1+yy_2;
% 2维面和3维面转换
initial_y=Y(1,1);
Theta=(Y-initial_y)./R_rotor;
XX=R_rotor*cos(Theta);
YY=R_rotor*sin(Theta);
ZZ=X;

for H=1:length(Pulse) 
    % 导入数据，对网格赋值,if_RI==0
    rpm_1{H}(:,1) = signal(Pulse(H):Pulse(H)+Len,object(1));%传感器B1
    rpm_1{H}(:,2) = signal((point_B1_R1_interval+Pulse(H)):(point_B1_R1_interval+Pulse(H)+Len),object(2));
    rpm_1{H}(:,3) = signal((point_B1_R1_interval+Pulse(H)):(point_B1_R1_interval+Pulse(H)+Len),object(3));
    rpm_1{H}(:,4) = signal((point_B1_R1_interval+Pulse(H)):(point_B1_R1_interval+Pulse(H)+Len),object(4));
    rpm_1{H}(:,5) = signal((point_B1_R1_interval+Pulse(H)):(point_B1_R1_interval+Pulse(H)+Len),object(5));
    rpm_1{H}(:,6) = signal((point_B1_R1_interval+Pulse(H)):(point_B1_R1_interval+Pulse(H)+Len),object(6));
    rpm_1{H}(:,7) = signal((point_B1_R1_interval+Pulse(H)):(point_B1_R1_interval+Pulse(H)+Len),object(7));
    rpm_1{H}(:,8) = signal((point_B1_R1_interval+Pulse(H)):(point_B1_R1_interval+Pulse(H)+Len),object(8));
    rpm_1{H}(:,9) = signal((point_B1_R1_interval+Pulse(H)):(point_B1_R1_interval+Pulse(H)+Len),object(9));
    rpm_1{H}(:,10) = signal((point_B1_C1_interval+Pulse(H)):(point_B1_C1_interval+Pulse(H)+Len),object(10));%传感器C1
end



%% 整理数据
%！ raw data output
if if_RI==0
    rpm = rpm_1;
end
%！ DPLA，但是不做平均操作
if if_RI==1 && DPLA_Scale==0
    solutime=1;
    for H=H_if_RI  %每转一圈刷新一次网格，一个时间步！%按照RI_marker排序
        rpm{solutime} = rpm_1{H};%传感器B1
    end
    solutime=solutime+1;
end
%！ DPLA，做平均操作
%！ averge the DPLA with the same period scale
if if_RI==1 && DPLA_Scale>0
        for k=1:360/DPLA_Scale 
            Xuhao{k}=find(RI_order(:,1)>DPLA_Scale*(k-1)&RI_order(:,1)<DPLA_Scale*(k));
            if length(Xuhao{k})==0
                 %! check
                warning("DPLA_Scale need to be larger, some period will missing and add with last period in case")
                kk=1;
                rpm{k}=rpm{k-1};
            else
                rpm_temp=zeros(Len+1,10);
                for kk=1:length(Xuhao{k})         
                    rpm_temp=rpm_temp+rpm_1{RI_order(Xuhao{k}(kk),2)};
                end
                rpm{k}=rpm_temp/kk;               
            end
        end
end
    
    
%% 输出到tecplot文件
for kk=1:length(rpm)
%! 虚拟叶片操作，暂时不考虑
%     % 一圈有29个叶片，对其进行划分，标记动叶位置（29份）:标记
       for k=1:29  
         Pulse_solid(k)=round(1+Point_rotor_rotor*(k-1));%这样就可以在变转速插入叶片了
       end
%      %不显示虚拟叶片排!rpm{solutime}(Pulse_solid+point_Pulse_rotor,:)=1.1*max(rpm{solutime}(:,end));  %在大约point_rotor_rotor个点搜寻正确的叶片位置，暂定用方差作为衡量指标

% tecplot接口
     tsignal.surfaces(kk).zonename='mysurface zone';
     tsignal.surfaces(kk).x=XX;    %size 3x3 
     tsignal.surfaces(kk).y=ZZ;    %size 3x3
     tsignal.surfaces(kk).z=YY;    %size 3x3
     tsignal.surfaces(kk).v(1,:,:)=rpm{kk};%根据键向信号判读
     tsignal.surfaces(kk).solutiontime=kk;
end
 %% 整合数据，生成文件
%title=''; 
rotorSpeed=floor(mean(Rotor_Speed)/100)*100;

if if_RI ==0
    NAME = [strrep(char(fname),type,'-'),'DPLA',num2str(if_RI),'-',date];  %存储文件夹
elseif if_RI==1 
    NAME = [strrep(char(fname),type,'-'),'DPLA',num2str(if_RI),'-','scale',num2str(DPLA_Scale),'-',date];  %存储文件夹
end
Varnames=[NAME];
output_file_name=[save_directory,'/',NAME,'-',num2str(rotorSpeed),'.plt']; 
tsignal.Nvar=4;     
tsignal.varnames={'x','y','z',Varnames};
mat2tecplot(tsignal,output_file_name);
%save([save_directory,'\',NAME,'.mat'],'rpm')
%save([save_directory,'\',NAME,'1.mat'],'tsignal');
xuhao=Pulse_solid+Point_Pulse_rotor;
%save([save_directory,'\',NAME,'xuhao.mat'],'xuhao');


%% Plot by matlab itself by surface(X,Y,Z,C)
f = figure;
kk=1
ax = axes;
axis equal

s = surface(tsignal.surfaces(kk).x,tsignal.surfaces(kk).y,tsignal.surfaces(kk).z,rpm{kk});
s.EdgeColor = 'none';
view(3)

ax.XLim = [-200 200];
ax.YLim = [0 36];
ax.ZLim = [-200 200];

ax.CameraPosition = [600 220 250];
ax.CameraTarget = [77 60 40];
ax.CameraUpVector = [0 0 1];
ax.CameraViewAngle = 40; %放大缩小


ax.Position = [0 0 1 1];
ax.DataAspectRatio = [.1 .1 .1];

l1 = light;
l1.Position = [160 400 80];
l1.Style = 'local';
l1.Color = [0 0.8 0.8];
 
l2 = light;
l2.Position = [.5 -1 .4];
l2.Color = [0.8 0.8 0];

% s.FaceColor = [0.9 0.2 0.2];
% 
% s.FaceLighting = 'gouraud';
% s.AmbientStrength = 0.3;

axis off
f.Color = 'white';
% s.DiffuseStrength = 0.6; 
% s.BackFaceLighting = 'lit';
% 
% s.SpecularStrength = 1;
% s.SpecularColorReflectance = 1;
% s.SpecularExponent = 7;

end
 
 
