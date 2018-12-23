function var=iLoad(mat_path,varname)
    tmp=load(mat_path);
    var=tmp.(varname);
end