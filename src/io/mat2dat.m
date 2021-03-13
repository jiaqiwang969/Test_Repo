function  mat2dat(tdata,file,varnames)
%% export ascii format tecplot file
fid = fopen(file,'w');
if isfield(tdata,'auxdata')
    if isstruct(tdata.auxdata)
        for i = 1:length(tdata.auxdata)
            if isnumeric(tdata.auxdata(i).value)
                tdata.auxdata(i).value = sprintf('%.6G',tdata.auxdata(i).value);
            end
            fprintf(fid,'DATASETAUXDATA %s = "%s"\n',tdata.auxdata(i).name,tdata.auxdata(i).value);
        end
    end
end
fprintf(fid,'TITLE="%s"\n',file);

fprintf(fid,'VARIABLES = ');
for i = 1:length(varnames)-1
    fprintf(fid,'"%s"\n',varnames{i});
end
i = i+1;
fprintf(fid,'"%s"\n',varnames{i});
fprintf(fid,'DATASETAUXDATA Common.DensityVar="17"\n');

for zk=1:length(tdata)
fprintf(fid,'ZONE T="%s"\n',tdata(zk).T);
fprintf(fid,' STRANDID=%d, ',tdata(zk).STRANDID);
fprintf(fid,' SOLUTIONTIME=%s\n',tdata(zk).SOLUTIONTIME);
fprintf(fid,' I=%d, ',tdata(zk).I);
fprintf(fid,' J=%d, ',tdata(zk).J);
fprintf(fid,' K=%d, ',tdata(zk).K);
fprintf(fid,' ZONETYPE=%s\n',tdata(zk).ZONETYPE);
fprintf(fid,' DATAPACKING=%s\n',tdata(zk).DATAPACKING);
fprintf(fid,' AUXDATA CGNS.CGNSBase_t="Surfaces"\n');
fprintf(fid,' AUXDATA CGNS.Zone_t="%s"\n',tdata(zk).T);
fprintf(fid,' DT=%s\n',tdata(zk).DT);

for k=1:length(varnames)
    ij=0;        
    for j=1:tdata(zk).J
        for i=1:tdata(zk).I
            fprintf(fid,' %1.9E',tdata(zk).data(i,j,k));
            ij=ij+1;
            if mod(ij,5)==0
                fprintf(fid,'\n');
            end
        end
    end
    fprintf(fid,'\n');
end

end

%E
fclose(fid);

