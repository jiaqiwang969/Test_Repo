%% -------               freqPlot_dB_universal              ------- %%
%！ input： signal,fs,object,objectName,testTime,fname,save_directory,if_RI,type
%！ output：rpm,tsignal,xuhao,Rotor_Speed
%！ 功能：   数据转化及输出
%% -------   Jiaqiwang969@gmail.com  SJTU SVN              ------- %%


function [the_freq,freq_dB]=freqPlot_dB_universal(Rotor_Speed,EIGS,tsignal2,fs,Data,object)
% 时间间隔
dT=1/(mean(Rotor_Speed)/60);
% 物理频率
f=imag(log(EIGS)/dT)/2/pi

K=3 %特征值序号

% SingalSimulate0=[tsignal2.surfaces(K).v(1,:,2)];
% SingalSimulate1=[tsignal2.surfaces(K+2).v(1,:,2)];
% 
% figure
% [the_freq0,freq_dB0]=frequencyDomainPlot_dB_no_deal(SingalSimulate0',fs,2.56);
% fH0=mean(Rotor_Speed)/60*20/(the_freq0(2)-the_freq0(1));
% [ma0,I0]=max(freq_dB0(1:fH0));
% m0=round(the_freq0(I0)/(mean(Rotor_Speed)/60))  %分解周向模态
% f01=m0*(mean(Rotor_Speed)/60)-f(K)
% f02=m0*(mean(Rotor_Speed)/60)+f(K)





% [the_freq1,freq_dB1]=frequencyDomainPlot_dB_no_deal(SingalSimulate1',fs,2.56);
% fH1=mean(Rotor_Speed)/60*20/(the_freq1(2)-the_freq1(1));
% [ma1,I1]=max(freq_dB1(1:fH1));
% m1=round(the_freq1(I1)/(mean(Rotor_Speed)/60))  %分解周向模态
% f11=m1*(mean(Rotor_Speed)/60)-f(K+2)
% f12=m1*(mean(Rotor_Speed)/60)+f(K+2)


%figure
[the_freq,freq_dB]=frequencyDomainPlot_dB(Data,fs,2.56);



end
