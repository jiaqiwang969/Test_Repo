clear
clc

%[zone1,VARlist1] = tec2mat('B2B65layer_11012_t1.dat');

%开头
%#!MC 1410
%$!VarSet |MFBD| = 'C:\Program Files\Tecplot\Tecplot 360 EX 2017 R2'

%结尾
%$!RemoveVar |MFBD|

%生成文件名
number=11012:4:14012;
for k=1:length(number)

fid=fopen('rewirte.mcr','r');
fid1=fopen('Data.mcr','a+');

best_data=[];
while 1
   tline=fgetl(fid);
   tline = strrep( tline , 'B2B65layer_11012_t1' , ['B2B65layer_',num2str(number(k),'%05d'),'_t1'] );
    if ~ischar(tline),break;end 
    fprintf(fid1, '%s\n',tline);  %s避免转译字符的错误

end
fclose(fid1);
fclose(fid);

end