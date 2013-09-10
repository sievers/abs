function[ra_fitp,dec_fitp,fitmat]=get_actpol_pointing_fit(tods)

%[ra,dec]=get_all_detector_radec_c (tods);
tt=get_tod_tvec(tods);
[alt,az]=get_tod_altaz(tods);

[altvec,altmin,altmax]=_get_scaled_vec(alt);
[azvec,azmin,azmax]=_get_scaled_vec(az);
[ttvec,ttmin,ttmax]=_get_scaled_vec(tt);

azmat=fliplr([azvec.^0 azvec azvec.^2 azvec.^3 azvec.^4]);
altmat=fliplr([altvec altvec.^2]);
tmat=fliplr([ttvec ttvec.^2]);
azt=[ttvec.*azvec];
fitmat=[azmat altmat tmat azt];

%mm=inv(fitmat'*fitmat);
mm=fitmat'*fitmat;mm=0.5*(mm+mm');

%do a bit of checking - it can happen that the elevation is degenerate with az
thresh=1e-7;
ee=eig(mm);
if (min(ee)<thresh*max(ee))
  fitmat=[azmat 0*altmat tmat azt];
  mm=fitmat'*fitmat;
  mm=0.5*(mm+mm');
  mm=invsafe(mm,-1*thresh);
else
  mm=inv(mm);
end


ra=get_all_detector_ra_saved_c(tods);
ra_fitp=mm*(fitmat'*ra);
clear ra;
dec=get_all_detector_dec_saved_c(tods);

dec_fitp=mm*(fitmat'*dec);

initialize_actpol_pointing_fit_c(tods,azvec,altvec,ttvec,ra_fitp,dec_fitp);

return

function[vec2,mymin,mymax]=_get_scaled_vec(vec);
mymin=min(vec);
mymax=max(vec);
mycent=0.5*(mymin+mymax);
mywidth=0.5*(mymax-mymin);
vec2=(vec-mycent)/mywidth;
return