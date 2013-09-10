function[tod,dx,dy]=read_tod_header_abs(todname,row,col,ra_wrap,varargin)

az_shift=get_keyval_default('az_shift',0,varargin{:}); %bonus az shift, in radians
el_shift=get_keyval_default('el_shift',0,varargin{:}); %bonus el shift, in radians
focal_plane_scale_fac=get_keyval_default('focal_plane_scale_fac',1.0,varargin{:}); %scale dx/dy by this amount.  Can be used e.g. to put all detectors along boresight
use_ctime_azel=get_keyval_default('use_ctime_azel',false,varargin{:}); %if true, use Srini's updated az/el boresight code
angle_shift=get_keyval_default('angle_shift',0,varargin{:}); %bonus shift to detector angles, in radians

ctime_shift=get_keyval_default('ctime_shift',0,varargin{:}); %bonus ctime shift, in radians
calib_pw=get_keyval_default('calib_pw',false,varargin{:}); %calibrate using IV files to picowatts
hwp_encoder_range=get_keyval_default('hwp_encoder_range',9000,varargin{:});
ignore_dirfile=get_keyval_default('ignore_dirfile',false,varargin{:});
iv_file=get_keyval_default('iv_file','',varargin{:});

angle_file=get_keyval_default('angle_file','',varargin{:});
do_reconstruct_hwp=get_keyval_default('reconstruct_hwp',false,varargin{:}); %if true, use code to try to repair HWP
median_az=get_keyval_default('median_az',[],varargin{:}); %if present, set the median az to this value
skip_repair=get_keyval_default('skip_repair',false,varargin{:}); %if true, don't try to repair potentially dodgy channels.  Akito's corrected TODs should make them skipable
get_radec_lims_lowmem=get_keyval_default('get_radec_lims_lowmem',true,varargin{:});

%if we've had problems reading stuff in, hack it so that we try to read directly from disk. All fields will need to be native int.
if ~ignore_dirfile
  myf=init_getdata_file(todname);
else
  myf=todname;
end

tod=allocate_tod_c();
if ~exist('row')
  row=0:21;nr=numel(row);
  col=0:23;nc=numel(col);
  row=repmat(row,[nc 1]);
  col=repmat(col',[1 nr]);
  row=reshape(row,[nr*nc 1]);
  col=reshape(col,[nr*nc 1]);
end


if ~isempty(angle_file)  
  theta=-1*get_detector_angles_abs(row,col,angle_file);
  if sum(isnan(theta))>0
    mdisp(['cutting detectors for missing polarization angles.']);
    ii=isfinite(theta);
    row=row(ii);
    col=col(ii);
    theta=theta(ii);
  end
end



%calib_facs=ones(size(row));
calib_facs=ones(max(row)+1,max(col)+1); %default to one for the calibration unless otherwise specified
if calib_pw
  if (1)
    if iscell(todname)
      calib_facs=get_abs_calib_facs(todname{1},varargin{:});
    else
      calib_facs=get_abs_calib_facs(todname,varargin{:});
    end
  else
    if isempty(iv_file)
      ff=find_my_ivfile(todname);
    else
      ff=iv_file;
    end
    calib_facs=read_ivfile(ff);
  end
  
  keep_ind=true(length(row),1);
  for j=1:length(row)
    if calib_facs(row(j)+1,col(j)+1)==0
      keep_ind(j)=false;
    end
    if ~isfinite(calib_facs(row(j)+1,col(j)+1))
      keep_ind(j)=false;
    end
    
  end
  if sum(keep_ind==false)>0
    disp(['Cutting ' num2str(sum(keep_ind==false)) ' detectors for missing IV values.'])
    row=row(keep_ind);
    col=col(keep_ind);
  end
end

[dx,dy]=get_abs_detector_offsets(row,col,varargin{:});

if focal_plane_scale_fac ~=1
  mdisp(['rescaling focal plane detector positions by ' num2str(focal_plane_scale_fac) '.']);
  dx=dx*focal_plane_scale_fac;
  dy=dy*focal_plane_scale_fac;
end


row=row(isfinite(dx));
col=col(isfinite(dx));

whos myf

%fid=fopen([todname '/sync_box_num']);sync_box_num=fread(fid,inf,'uint32');fclose(fid);
sync_box_num=getdata_double_channel(myf,'sync_box_num');

ct=getdata_double_channel(myf,'sync_time');

[az,el]=read_abs_boresight_azel(myf);
if (use_ctime_azel)
  [az,el]=convert_enc_to_true_ptg_model_ctime(az,el,median(ct));
  %[az2,el2]=convert_enc_to_true_ptg_model_ctime(az,el,median(ct));
  %az=2*az-az2;
  %az=az2;
  %el=2*el-el2;
end

if ~isempty(median_az)
  mdisp(['assigning median az']);
  az=az-median(az)+median_az;
end

%el=pi/2-el;



%fid=fopen([todname '/hk/sync_time']);
%ct=fread(fid,inf,'double');
%fclose(fid);
if numel(sync_box_num)~=numel(az)
  warning(['Mismatch in data lengths in ' todname ' tesdata: ' num2str(numel(sync_box_num)) ', hk: ' num2str(numel(az))]);
  %fid=fopen([todname '/hk/sync_number']);sync_num=fread(fid,inf,'uint32');fclose(fid);
  sync_num=getdata_double_channel(myf,'sync_number');
  %if sync_num(end)~=sync_box_num(numel(sync_num))
  %  error(['Samples at end of HK do not line up, I am not yet smart enough to recover.']);
  %end
end


if (do_reconstruct_hwp)
  hwp=reconstruct_hwp(myf);
  %hwp=2*pi*rem(hwp,hwp_encoder_range)/hwp_encoder_range;
else
  hwp=getdata_double_channel(myf,'hwp_encoder_counts');
  hwp=round(repair_hwp(hwp,'max_hwp',hwp_encoder_range));
  hwp=2*pi*hwp/hwp_encoder_range;
end


[isbad,ct]=find_bad_abs_ctime_samples(ct);

xx=(1:length(ct))';

if ~skip_repair
  if ~isempty(isbad)
    az(isbad)=interp1(xx(~isbad),az(~isbad),xx(isbad));
    el(isbad)=interp1(xx(~isbad),el(~isbad),xx(isbad));
    if ~do_reconstruct_hwp
      hwp(isbad)=interp1(xx(~isbad),hwp(~isbad),xx(isbad));
    end
  end
end

%If we have an extra shift to the az, apply it now.
if az_shift~=0
  az=az+az_shift;
end

if ctime_shift~=0
  ct=ct+ctime_shift;
end



set_tod_ndata_c(tod,length(az));
set_tod_altaz_c(tod,el,az);
set_tod_hwp_angle_c(tod,hwp);

set_tod_timevec_c(tod,ct);
set_tod_dt_c(tod,median(diff(ct)));
set_tod_rowcol_c(tod,row,col);

disp('seting todname');

todname=strip_trailing_slashes(todname);
set_tod_filename(tod,todname);

disp('set');

ndet=numel(row);
ndata=numel(az);
%dat=zeros(ndata,ndet);


if (0)
  for j=1:ndet,
    %fname=sprintf('%s/tesdatar%02dc%02d',todname,row(j),col(j));
    %fid=fopen(fname);
    %tmp=fread(fid,inf,'int32');
    tmp=calib_facs(row(j)+1,col(j)+1)*getdata_double_channel(myf,sprintf('tesdatar%02dc%02d',row(j),col(j)));
    if length(tmp)<ndata,
      tmp(end+1:ndata)=tmp(end);
    end
    dat(:,j)=tmp(1:ndata);
    %fclose(fid);
  end
else
end 

alloc_tod_cuts_c(tod);
%set_tod_data_saved(tod,dat);

if (1)
  
  [dx,dy]=get_abs_detector_offsets(row,col,varargin{:});

  if focal_plane_scale_fac ~=1
    mdisp(['rescaling focal plane detector positions by ' num2str(focal_plane_scale_fac) '.']);
    dx=dx*focal_plane_scale_fac;
    dy=dy*focal_plane_scale_fac;
  end

  %dy=-1.758972761091516901e+00*pi/180;
  %dx= 2.142848400011577725e-01*pi/180;
  ra=zeros(ndata,ndet);
  dec=zeros(ndata,ndet);
  do_actpol_pointing=true
  if do_actpol_pointing
    tic
      if ~exist('theta')
        theta=0*dx; %if we're reading a file, it's set earlier.
      end
      initialize_actpol_pointing(tod,-dy,-dx,theta,148.0,1);
      precalc_actpol_pointing_exact(tod,1);
      %pull ra/dec separately so can free intermediately
      %[ra,dec]=get_all_detector_radec_c(tod);
      ra=get_all_detector_ra_saved_c(tod);
      free_tod_ra_saved(tod);
      dec=get_all_detector_dec_saved_c(tod);
      free_tod_dec_saved(tod);
      free_tod_pointing_saved(tod);


      %if do_actpol_pointing
      %tic
      %initialize_actpol_pointing(tod,-dy,-dx,0*dx+angle_shift,148.0,1);
      %if (get_radec_lims_lowmem)
      %  find_tod_radec_lims_actpol_pointing_exact_c(tod);
      %else        
      %  precalc_actpol_pointing_exact(tod);
      %  [ra,dec]=get_all_detector_radec_c(tod,ra_wrap);
      %  free_tod_pointing_saved(tod);
      %end
    toc
  else
    tic
      for j=1:numel(row),
        [ra_det,dec_det]=get_radec_from_altaz_actpol_c(az,el,ct,-dy(j),-dx(j));  
        if numel(ra_det)~=numel(az)
          whos
          error(['we have a housekeeping/data length mismatch on ' todname]);
        end
        ra(:,j)=ra_det;
        dec(:,j)=dec_det;
      end
    toc
  end

  if (exist('ra_wrap'))
    disp(['repairing RA from ra_wrap']);
    ra(ra>ra_wrap)=ra(ra>ra_wrap)-2*pi;
    disp([max(max(ra)) min(min(ra))]);
  end
  ramin=min(min(ra));
  ramax=max(max(ra));  
  disp([ramin ramax])

  if (ramax-ramin>6) %if we span more than 6 radians, we probably have wrapped and need change the branch point
    disp('reparing ra');
    rr=sort(reshape(ra,[numel(ra) 1]));
    dra=diff(rr);[a,b]=max(dra);
    mybranch=mean([rr(b) rr(b+1)]);
    clear rr;clear dra;
    %if mybranch<0
    if 1
      ra(ra<mybranch)=ra(ra<mybranch)+2*pi;
    else
      ra(ra>mybranch)=ra(ra>mybranch)-2*pi;
    end
    ramin=min(min(ra));
    ramax=max(max(ra));      
  end
  
  decmin=min(min(dec));
  decmax=max(max(dec));  

  if (~do_actpol_pointing)
    set_tod_pointing_saved(tod,ra,dec);
    disp('set pointing.');
  end
  set_tod_radec_lims_c(tod,ramin,ramax,decmin,decmax);
  
end
