function[ra,dec]=get_planet_position_from_ctime(obj,ctimes,varargin)

do_azel=get_ephem_obj_ind('azel',varargin)>0;  %hack since we have code sitting around that will check varargin

ok_obj_list={'moon','venus'};
ephem_dir='/home/sievers/ephemerides/';
ephem_files={'moon_superfine.txt','venus_2012.txt'};


persistent ephem_data  %we're going to save this so we don't reload at every call
if isempty(ephem_data)
  ephem_data=cell(size(ok_obj_list));
end


ind=get_ephem_obj_ind(obj,ok_obj_list);
if (ind<1)
  warning(['Object ' obj ' not supported in get_planet_position_from_ctime']);
  return;  %we failed due to unfound object
end

if isempty(ephem_data{ind})  %load planet data as requested
  fname=[ephem_dir ephem_files{ind}];
  disp(['loading ephemerides from ' fname])

  ephem_data(ind)={load(fname)};

end
dat_use=ephem_data{ind};

mjd=ctime2mjd(ctimes);

if (do_azel)
  z=sin(dat_use(:,5)*pi/180);
  x=cos(dat_use(:,4)*pi/180).*cos(dat_use(:,5)*pi/180);
  y=sin(dat_use(:,4)*pi/180).*cos(dat_use(:,5)*pi/180);

else
  z=sin(dat_use(:,3)*pi/180);
  x=cos(dat_use(:,2)*pi/180).*cos(dat_use(:,3)*pi/180);
  y=sin(dat_use(:,2)*pi/180).*cos(dat_use(:,3)*pi/180);
end
zz=interp1(dat_use(:,1),z,mjd(:,1));
xx=interp1(dat_use(:,1),x,mjd(:,1));
yy=interp1(dat_use(:,1),y,mjd(:,1));
dec=asin(zz);
ra=atan2(yy,xx);

return




function[ind]=get_ephem_obj_ind(obj,obj_list)
for j=1:numel(obj_list),
  if strcmp(obj,obj_list{j})
    ind=j;
    return;
  end
end
ind=-1;  %obj not found
%warning(['Object ' obj ' not supported in get_planet_position_from_ctime']);
return
