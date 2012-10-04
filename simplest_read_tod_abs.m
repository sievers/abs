function[tod]=simplest_read_tod_abs(todname,row,col)

tod=allocate_tod_c();
if ~exist('row')
  row=0:21;nr=numel(row);
  col=0:23;nc=numel(col);
  row=repmat(row,[nc 1]);
  col=repmat(col',[1 nr]);
  row=reshape(row,[nr*nc 1]);
  col=reshape(col,[nr*nc 1]);
end

[dx,dy]=get_abs_detector_offsets(row,col);                                                                                                                                                            
row=row(isfinite(dx));
col=col(isfinite(dx));

fid=fopen([todname '/sync_box_num']);sync_box_num=fread(fid,inf,'uint32');fclose(fid);


[az,el]=read_abs_boresight_azel(todname);
el=pi/2-el;
fid=fopen([todname '/hk/sync_time']);
ct=fread(fid,inf,'double');
fclose(fid);
if numel(sync_box_num)~=numel(az)
  warning(['Mismatch in data lengths in ' todname ' tesdata: ' num2str(numel(sync_box_num)) ', hk: ' num2str(numel(az))]);
  fid=fopen([todname '/hk/sync_number']);sync_num=fread(fid,inf,'uint32');fclose(fid);
  %if sync_num(end)~=sync_box_num(numel(sync_num))
  %  error(['Samples at end of HK do not line up, I am not yet smart enough to recover.']);
  %end
end



[isbad,ct]=find_bad_abs_ctime_samples(ct);

xx=(1:length(ct))';
if ~isempty(isbad)
  az(isbad)=interp1(xx(~isbad),az(~isbad),xx(isbad));
  el(isbad)=interp1(xx(~isbad),el(~isbad),xx(isbad));
end


set_tod_ndata_c(tod,length(az));
set_tod_altaz_c(tod,el,az);

set_tod_timevec_c(tod,ct);
set_tod_dt_c(tod,median(diff(ct)));
set_tod_rowcol_c(tod,row,col);



ndet=numel(row);
ndata=numel(az);
dat=zeros(ndata,ndet);
for j=1:ndet,
  fname=sprintf('%s/tesdatar%02dc%02d',todname,row(j),col(j));
  fid=fopen(fname);
  tmp=fread(fid,inf,'int32');
  if length(tmp)<ndata,
    tmp(end+1:ndata)=tmp(end);
  end
  dat(:,j)=tmp(1:ndata);
  fclose(fid);
end

alloc_tod_cuts_c(tod);
set_tod_data_saved(tod,dat);

if (1)
  
  [dx,dy]=get_abs_detector_offsets(row,col);
  %dy=-1.758972761091516901e+00*pi/180;
  %dx= 2.142848400011577725e-01*pi/180;
  ra=zeros(size(dat));
  dec=zeros(size(dat));
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
  ramin=min(min(ra));
  ramax=max(max(ra));  

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
  set_tod_pointing_saved(tod,ra,dec);
  disp('set pointing.');
  set_tod_radec_lims_c(tod,ramin,ramax,decmin,decmax);
  
end
