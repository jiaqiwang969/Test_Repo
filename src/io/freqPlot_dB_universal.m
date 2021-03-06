%% -------               freqPlot_dB_universal              ------- %%
%！ input： signal,fs,object,objectName,testTime,fname,save_directory,if_RI,type
%！ output：rpm,tsignal,xuhao,Rotor_Speed
%！ 功能：   数据转化及输出
%% -------   Jiaqiwang969@gmail.com  SJTU SVN              ------- %%


function freqPlot_dB_universal(Rotor_Speed,EIGS,tsignal2,fs,Data,object)
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

%% figure-3c The frequency plot
% 分别包括绝对坐标系
figure1 = figure('Color',[1 1 1]);
axes1 = axes('Parent',figure1);
plot(the_freq,freq_dB(:,object(1)),'-k')
xlim(axes1,[15 12000]);
ylim(axes1,[120,180]);
xlabel({'Norm. Frequency (f/f_r_o_t)'});
ylabel('Spectrum i.e. 20*log10(L/2e-5) (dB)' );
box(axes1,'on');
set(axes1,'XGrid','on');   
set(axes1,'FontSize',14,'XGrid','on','XTick',[200 5800 11600],...
    'XTickLabel',{'1','29(1xBPF)','58(2xBPF)'});


end
