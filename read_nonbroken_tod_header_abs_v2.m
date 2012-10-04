function[tod]=read_nonbroken_tod_header_abs_v2(todname,row,col,ra_wrap,varargin)

pol_angle_file=get_keyval_default('pol_angle_file','/home/sievers/abs/detectors/pol_angles/wiregrid_hwp_detector_angles.txt',varargin{:});
hwp_encoder_range=get_keyval_default('hwp_encoder_range',9000,varargin{:});


myf=init_getdata_file(todname);

tod=allocate_tod_c();
[dx,dy]=get_abs_detector_offsets(row,col,varargin{:});

row=row(isfinite(dx));
col=col(isfinite(dx));

[az,el]=read_abs_boresight_azel(myf);
ct=getdata_double_channel(myf,'sync_time');
sync_box_num=getdata_double_channel(myf,'sync_box_num');
assert(numel(ct)==numel(sync_box_num));  %if this fails, we have size mismatches


set_tod_ndata_c(tod,length(az));
set_tod_altaz_c(tod,el,az);

set_tod_timevec_c(tod,ct);
set_tod_dt_c(tod,median(diff(ct)));
set_tod_rowcol_c(tod,row,col);
alloc_tod_cuts_c(tod);


ndet=numel(row);
ndata=numel(az);

pol_angles=myload(pol_angle_file);
pol_angles=convert_pod_quantity_to_mce(pol_angles,varargin{:});
theta=0*row;
for j=1:length(row),
  theta(j)=pol_angles(row(j)+1,col(j)+1);
end
sum(isnan(theta))

[dx,dy]=get_abs_detector_offsets(row,col,varargin{:});
initialize_actpol_pointing(tod,-dy,-dx,0*dx,148.0,1);
