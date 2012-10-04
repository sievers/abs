function[myx,myy]=get_abs_detector_offsets(rows,cols,varargin)
xy_fname=get_keyval_default('xy_file','/home/sievers/abs/pointing/abs_focalplane.dat',varargin{:});
mce_file=get_keyval_default('mce_map','/home/sievers/abs/pointing//mce_pod_map_03262012.txt',varargin{:});
pol_angle_file=get_keyval_default('pol_angle_file','/home/sievers/abs/detectors/pol_angles/wiregrid_hwp_detector_angles.txt',varargin{:});

%disp([xy_fname ' ' mce_file])
xy=myload(xy_fname);
mce_map=myload(mce_file);

myx=0*rows;
myy=0*rows;
for j=1:numel(rows),
  rr=find(  (cols(j)==mce_map(:,3))&( (rows(j)==mce_map(:,4))|(rows(j)==mce_map(:,5))));
  assert(numel(rr)<=1);
  if numel(rr)==0
    myx(j)=nan;
    myy(j)=nan;
  else      
    mytarg=(mce_map(rr,1)-1)*10+(mce_map(rr,2)-1);
    myrow=find(mytarg==xy(:,1));
    myx(j)=xy(myrow,2);
    myy(j)=xy(myrow,3);
  end
end

myx=myx*pi/180;
myy=myy*pi/180;
