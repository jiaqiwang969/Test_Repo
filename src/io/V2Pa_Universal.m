%% -------                    V2Pa_Universal              ------- %%
%！ input： Data,kulite_transform_ab
%！ output：DATA
%！ 功能：   数据导入以及转换V2Pa_Universal
%% -------   Jiaqiwang969@gmail.com  SJTU SVN             ------- %%


function DATA=V2Pa_Universal(Data,kulite_transform_ab)
    %first,check the size of Data and kulite_transform_ab,is same or not
    if size(Data,2)~=size(kulite_transform_ab,1)
        disp('转换参数不正确！！')
    end
     for k=1:size(Data,2)  
         DATA(:,k)= Data(:,k)*kulite_transform_ab(k,1)+kulite_transform_ab(k,2);%传感器B1
     end
       
end