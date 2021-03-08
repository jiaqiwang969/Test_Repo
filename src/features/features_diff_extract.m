function [Feature,leftData]=features_diff_extract(Data,Object,samplePoint,leftData,Feature)

%���ȣ���Ҫ��leftDtatƴ�ӵ�Data��
Data=[leftData;Data];
[len1,len2]=size(Data);
len3=floor(len1/samplePoint);%�˶��źſ��еĵ���
leftLen=len1-samplePoint*len3;
leftData=Data(end-leftLen+1:end,:);
lastlen=length(Feature);
for i=1:len3  %�ɲ��м���
    x=Data(1+(i-1)*samplePoint:samplePoint+(i-1)*samplePoint,Object);
    
    %%ʱ������
    x=x-mean(x);
    PV=peakvalue(x); %��ֵ1
    PPV=ppvalue(x);   %���ֵ2
    AP=meanamp(x);   %ƽ����ֵ3
    RP=rootamp(x);   %������ֵ4
    RMS=rootmeansquare(x); %��Чֵ5
    SK=skewness(x);   %���ָ��6
    KU=kurtosis(x);  %�Ͷ�ָ��7
    CF=peakind(x);   %��ֵָ��8
    CLF=marginind(x); %ԣ��ָ��9
    IF=pluseind(x);  %����ָ��10
    SF=waveind(x);  %����ָ��11
    WE3=feature_WE3(x);%16��С����������12-27
    SPEC=spectrumentropy(x);%��ֵ����28
    ENV=Envelop(x);%��������29
    Feature{lastlen+i}=[PV;PPV;AP;RP;RMS;SK;KU;CF;CLF;IF;SF;WE3;SPEC;ENV];
    %��һ��
    %Feature{i} = Feature{i}./repmat(sqrt(sum(Feature{i}.^2,2)),1,size(Feature{i},2));%���н��й�һ��
end