function[mat]=convert_pod_quantity_to_mce(dat,varargin)
%convert data that is in (pod,horn,det1,det2) format into an mce row/col matrix
mce_file=get_keyval_default('mce_map','/home/sievers/abs/pointing//mce_pod_map_03262012.txt',varargin{:});
mce_dat=myload(mce_file);

rr=mce_dat(:,4:5);
rr=rr(isfinite(rr));
rmax=max(rr)+1;
cmax=max(mce_dat(:,3))+1;
mat=zeros(rmax,cmax)+nan;
for j=1:size(dat,1),
  ii=(find((dat(j,1)==mce_dat(:,1))&(dat(j,2)==mce_dat(:,2))));
  if numel(ii)~=1
    error(['mismatched row in convert_pod_quantity_to_mce, offending row is ' num2str(dat(j,:))]);
  end
  %[ii mce_dat(ii,:)]
  if isfinite(mce_dat(ii,4))
    mat(mce_dat(ii,4)+1,mce_dat(ii,3)+1)=dat(j,3);
  end
  if isfinite(mce_dat(ii,5))
    mat(mce_dat(ii,5)+1,mce_dat(ii,3)+1)=dat(j,4);
  end
end

