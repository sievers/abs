function[asdf]=calibrate_data_abs(tod,varargin)
iv_file=get_keyval_default('iv_file','',varargin{:});
if (isempty(iv_file))
  iv_file=find_my_ivfile(get_tod_name(tod));
end
calib_facs=read_ivfile(iv_file);
[rr,cc]=get_tod_rowcol(tod);
facs=0*rr;
for j=1:length(rr),
  facs(j)=calib_facs(rr(j)+1,cc(j)+1);
end
apply_calib_facs_c(tod,facs);
