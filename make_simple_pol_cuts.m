function[outname]=make_simple_pol_cuts(tod,dirroot,varargin)
dat_org=get_tod_data(tod);

detrend_data_c_c(tod);
find_spikes(tod,'thresh',15);
gapfill_data_c(tod);
dat_nohwp=fit_sines_to_hwp(tod,varargin{:});
push_tod_data(dat_nohwp,tod);
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


outname=[dirroot '/cuts_' tag];
write_cuts_c(tod,outname);
