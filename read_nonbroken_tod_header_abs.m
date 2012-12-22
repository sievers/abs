function[tod]=read_nonbroken_tod_header_abs(todname,row,col,varargin)
pol_angle_file=get_keyval_default('pol_angle_file','/home/sievers/abs/detectors/pol_angles/wiregrid_hwp_detector_angles.txt',varargin{:});
freq=get_keyval_default('freq',148.0,varargin{:});
hwp_encoder_range=get_keyval_default('hwp_encoder_range',9000,varargin{:});
cuts_name=get_keyval_default('cuts_name','',varargin{:});

myf=init_getdata_file(todname);

%calib_pw=get_keyval_default('calib_pw',false,varargin{:}); %calibrate using IV files to picowatts


tod=allocate_tod_c();

[dx,dy]=get_abs_detector_offsets(row,col,varargin{:});

row=row(isfinite(dx));
col=col(isfinite(dx));
%dy=dy(isfinite(dx));
%dx=dx(isfinite(dx));



%get detector polarization angles
pol_angles=myload(pol_angle_file);
pol_angles=convert_pod_quantity_to_mce(pol_angles,varargin{:});
theta=0*row;
for j=1:length(row),
  theta(j)=pol_angles(row(j)+1,col(j)+1);
end

disp(['going to cut ' num2str(sum(~isfinite(theta))) ' detectors for not having measured polarization angles.']);

row=row(isfinite(theta));
col=col(isfinite(theta));
theta=theta(isfinite(theta));


[az,el]=read_abs_boresight_azel(myf);
ct=getdata_double_channel(myf,'sync_time');
[crap,ct]=find_bad_abs_ctime_samples(ct);  %make sure ctimes aren't totally crazy
sync_box_num=getdata_double_channel(myf,'sync_box_num');
whos
assert(numel(ct)==numel(sync_box_num));  %if this fails, we have size mismatches



set_tod_ndata_c(tod,length(az));
set_tod_altaz_c(tod,el,az);

set_tod_timevec_c(tod,ct);
set_tod_dt_c(tod,median(diff(ct)));
set_tod_rowcol_c(tod,row,col);
alloc_tod_cuts_c(tod);

if ~isempty(cuts_name)
  disp(['reading cuts from ' cuts_name])
  read_cuts_c(tod,cuts_name);
  get_tod_uncut_regions(tod);
  
end



[dx,dy]=get_abs_detector_offsets(row,col,varargin{:});
initialize_actpol_pointing(tod,-dy,-dx,theta,freq,1);
%initialize_actpol_pointing(tod,-dy,-dx,0*dx,freq,1);

hwp=getdata_double_channel(myf,'hwp_encoder_counts');
hwp=round(repair_hwp(hwp,'max_hwp',hwp_encoder_range));

hwp=2*pi*hwp/hwp_encoder_range;
set_tod_hwp_angle_c(tod,hwp);

set_tod_filename(tod,todname);

for j=1:length(myf)
  close_getdata_file(myf(j));
end
