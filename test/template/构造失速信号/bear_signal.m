clc
clear
close all
% 将以下程序copy到matlab编辑器中运行，或直接在工作区运行即可
fs = 20e3; % 采样频率
fn = 3e3; % 固有频率
y0 = 5; % 位移常数
g = 0.1; % 阻尼系数
T = 0.01; % 重复周期
N = 4096; % 采样点数
NT = round(fs*T); % 单周期采样点数
t = 0:1/fs:(N-1)/fs; % 采样时刻
t0 = 0:1/fs:(NT-1)/fs; % 单周期采样时刻
K = ceil(N/NT)+1; % 重复次数
y = [];
for i = 1:K
y = [y,y0*exp(-g*2*pi*fn*t0).*sin(2*pi*fn*sqrt(1-g^2)*t0)];
end
y = y(1:N);
Yf = fft(y); % 频谱
figure(1)
plot(t,y);
axis([0,inf,-4,5])
title('轴承故障仿真信号时域波形图')
xlabel('Time(s)')
ylabel('Amplitude')
figure(2)
f = 0:fs/N:fs-fs/N;
plot(f/1e3,abs(Yf));
xlabel('Frequency(KHz)');
ylabel('\itY\rm(\itf\rm)')
title('轴承故障仿真信号幅度谱图')