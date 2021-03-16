%
clc
clear
close all
m=1;psi_m=0;w1=40;
t=linspace(0,1,100);
theta=linspace(0,2*pi,1000);
%p=exp(i*w1*t).'*cos(m*theta-psi_m);
r=cos(m*theta-psi_m)

mmpolar(theta,r);