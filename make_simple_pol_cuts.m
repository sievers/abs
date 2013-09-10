function[outname]=make_simple_pol_cuts(tod,dirroot,varargin)
write_cuts=get_keyval_default('write_cuts',true,varargin{:});
myopts=get_keyval_default('opts',[],varargin{:});
do_hwp_c=false;
if ~isempty(myopts)
  do_hwp_c=get_struct_mem(myopts,'do_hwp_az',false);
end


whos

dat_org=get_tod_data(tod);

detrend_data_c_c(tod);
find_spikes(tod,'thresh',15);
gapfill_data_c(tod);

  
if (do_hwp_c)
  disp('doing c hwp removal in make_simple_pol_cuts');
  fit_hwp_az_poly_to_data(tod,myopts);
else
  dat_nohwp=fit_sines_to_hwp(tod,varargin{:});
  push_tod_data(dat_nohwp,tod);
end
detrend_data_c_c(tod);
find_spikes(tod,varargin{:});

tod_name=get_tod_name(tod);
if iscell(tod_name)
  tod_name=tod_name{1};
end

ii=max(find(tod_name=='/'));
if ~isempty(ii)
  tag=tod_name(ii+1:end);
else
  tag=tod_name;
end

if (write_cuts)
  outname=[dirroot '/cuts_' tag];
  write_cuts_c(tod,outname);
end

