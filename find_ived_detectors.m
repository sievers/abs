function[rows,cols]=find_ived_detectors(fname)
ivfile=find_my_ivfile(fname);
iv_facs=read_ivfile(ivfile);
rows=repmat([1:size(iv_facs,1)]'-1,[1 size(iv_facs,2)]);
cols=repmat([1:size(iv_facs,2)]-1,[ size(iv_facs,1) 1]);
nn=numel(iv_facs);
iv_facs=reshape(iv_facs,[nn 1]);
rows=reshape(rows,[nn 1]);
cols=reshape(cols,[nn 1]);
rows=rows(iv_facs~=0);
cols=cols(iv_facs~=0);


