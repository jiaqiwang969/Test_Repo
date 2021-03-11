function [Feature,leftData]=features28_diff_extract(Data,Object,samplePoint,leftData,Feature)
% 只分析幅值谱熵这个指标
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
    SPEC=spectrumentropy(x);%幅值谱熵28
    Feature{lastlen+i}=[SPEC];
    %归一化
    %Feature{i} = Feature{i}./repmat(sqrt(sum(Feature{i}.^2,2)),1,size(Feature{i},2));%对行进行归一化
end