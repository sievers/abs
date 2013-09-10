function[el_good,az_good]=find_boresight_altaz_for_detector(dx,dy,alt_targ,az_targ)
ct=ctime;
az_targ=az_targ*pi/180;
alt_targ=alt_targ*pi/180;
[ra_targ,dec_targ]=get_radec_from_altaz_actpol_c(az_targ,alt_targ,ct);
myrow=1;
mycol=1;
%shouldn't need to change anything below here

naz=360;
nel=61;
az=pi*(-1:2/naz:1);
el=(0:nel-1)/(nel-1);
el=(30+60*el)*pi/180;

%[dx,dy]=get_abs_detector_offsets(myrow,mycol,'xy_file','/home/sievers/abs/pointing/abs_focalplane_v7_shift.txt','mce_map','/home/sievers/abs/pointing/mce_pod_map_03262012.txt');

[az,el]=meshgrid(az,el');
az=reshape(az,[numel(az) 1]);
el=reshape(el,[numel(el) 1]);
ndata=numel(az);
tod=allocate_tod_c();
set_tod_ndata_c(tod,ndata);
set_tod_altaz_c(tod,el,az);
ctvec=repmat(ct,size(az));
set_tod_timevec_c(tod,ctvec);
set_tod_dt_c(tod,1e-6);
set_tod_rowcol_c(tod,myrow,mycol);
tic;
initialize_actpol_pointing(tod,-dy,-dx,0*dx,148.0,1);
[ddx,ddy]=get_tod_pointing_offsets_c(tod)

precalc_actpol_pointing_exact(tod);
[ra,dec]=get_all_detector_radec_c(tod);
free_tod_pointing_saved(tod);
toc

dra=ra-ra_targ;
dra(dra>pi)=dra(dra>pi)-2*pi;
dra(dra<-pi)=dra(dra<-pi)+2*pi;
ddec=dec-dec_targ;
dist=sqrt((dra*cos(dec_targ)).^2+ddec.^2);
[a,b]=min(dist);
disp(a*180/pi);

%OK, now repeat on a zoomed-in grid
vv=(-5:0.025:5);vv=vv*pi/180;
az2=az(b)+vv;
el2=el(b)+vv';
[az2,el2]=meshgrid(az2,el2);
az2=reshape(az2,[numel(az2) 1]);
el2=reshape(el2,[numel(el2) 1]);
ct2=ct+0*az2;
ndata2=numel(az2);
tod2=allocate_tod_c();  
set_tod_ndata_c(tod2,ndata2);
set_tod_altaz_c(tod2,el2,az2);
set_tod_timevec_c(tod2,ct2);
set_tod_dt_c(tod2,1e-6);
set_tod_rowcol_c(tod2,myrow,mycol);
tic;                                                                                             toc                                                                                              
initialize_actpol_pointing(tod2,-dy,-dx,0*dx,148.0,1);
precalc_actpol_pointing_exact(tod2);
[ra2,dec2]=get_all_detector_radec_c(tod2);
free_tod_pointing_saved(tod2);
toc

dra=ra2-ra_targ;
dra(dra>pi)=dra(dra>pi)-2*pi;
dra(dra<-pi)=dra(dra<-pi)+2*pi;
ddec=dec2-dec_targ;
dist=sqrt((dra*cos(dec_targ)).^2+ddec.^2);
[a,b]=min(dist);

az_good=az2(b)*180/pi;
el_good=el2(b)*180/pi;
sprintf('Target boresight az/el in degrees is: %8.3f %8.3f which gets within %8.3f arcminutes.',az_good,el_good,a*180/pi*60)
%disp(['Targer boresight az/el in degrees is: ' num2str([az_good el_good]) ' which get within ' num2str(a*180/pi*60) ' arcminutes.'])

return
