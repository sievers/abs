function[theta]=get_detector_angles_abs(rows,cols,fname)

angles=myload(fname);
theta=0*rows;
crud=angles(:,2)+i*angles(:,1);
crap=rows+i*cols;
for j=1:length(rows)
  ii=find(crap(j)==crud);
  if ~isempty(ii)
    theta(j)=angles(ii,3);
  else
    theta(j)=nan;
  end
end

theta(isnan(theta))=nan;  %since sometimes they come back as NA or inf
theta=theta*pi/180;  %go to radians