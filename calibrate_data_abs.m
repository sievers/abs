function[calib_facs,angle_mat]=calibrate_data_abs(tod,varargin)
iv_file=get_keyval_default('iv_file','',varargin{:});
flat_file=get_keyval_default('flat_file','',varargin{:}); %/home/r/rbond/sievers/abs/calib/black_baffle_responsivity.txt


if (isempty(iv_file))
  iv_file=find_my_ivfile(get_tod_name(tod));
end
calib_facs=read_ivfile(iv_file);

%check this!!!
if ~isempty(flat_file)
  mylines=load(flat_file);
  flat_mat=0*calib_facs;
  angle_mat=0*calib_facs;
  for j=1:length(mylines),
    flat_mat(mylines(j,2)+1,mylines(j,1)+1)=mylines(j,3);
    angle_mat(mylines(j,2)+1,mylines(j,1)+1)=mylines(j,4);    
  end
  calib_facs(flat_mat~=0)=calib_facs(flat_mat~=0)./flat_mat(flat_mat~=0);
  calib_facs(flat_mat==0)=0;
end


[rr,cc]=get_tod_rowcol(tod);
facs=0*rr;
for j=1:length(rr),
  facs(j)=calib_facs(rr(j)+1,cc(j)+1);
end


isbad=isnan(facs)|(facs==0);
whos facs
disp(['have ' num2str(sum(isbad)) ' uncalibrated detectors.']);
if (sum(isbad))>0,
  mdisp(['have uncalibrated detectors that aren''t cut.  Cutting now.']);
  for j=1:length(facs),
    if (isbad(j))
      cut_detector_c(tod,rr(j),cc(j));
    end
  end
end




apply_calib_facs_c(tod,facs);
