function [Feature,leftData]=features_diff_extract(Data,Object,samplePoint,leftData,Feature)

%首先，需要将leftDtat拼接到Data中
Data=[leftData;Data];
[len1,len2]=size(Data);
len3=floor(len1/samplePoint);%此段信号可切的刀数
leftLen=len1-samplePoint*len3;
leftData=Data(end-leftLen+1:end,:);
lastlen=length(Feature);
for i=1:len3  %可并行计算
    x=Data(1+(i-1)*samplePoint:samplePoint+(i-1)*samplePoint,Object);
    
    %%时域特征
    x=x-mean(x);
    PV=peakvalue(x); %峰值1
    PPV=ppvalue(x);   %峰峰值2
    AP=meanamp(x);   %平均幅值3
    RP=rootamp(x);   %方根幅值4
    RMS=rootmeansquare(x); %有效值5
    SK=skewness(x);   %歪度指标6
    KU=kurtosis(x);  %峭度指标7
    CF=peakind(x);   %峰值指标8
    CLF=marginind(x); %裕度指标9
    IF=pluseind(x);  %脉冲指标10
    SF=waveind(x);  %波形指标11
    WE3=feature_WE3(x);%16个小波包能量熵12-27
    SPEC=spectrumentropy(x);%幅值谱熵28
    ENV=Envelop(x);%包络谱熵29
    Feature{lastlen+i}=[PV;PPV;AP;RP;RMS;SK;KU;CF;CLF;IF;SF;WE3;SPEC;ENV];
    %归一化
    %Feature{i} = Feature{i}./repmat(sqrt(sum(Feature{i}.^2,2)),1,size(Feature{i},2));%对行进行归一化
end