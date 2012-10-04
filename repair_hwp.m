function[hwp]=repair_hwp(hwp,varargin)
hwp_max=get_keyval_default('max_hwp',9000,varargin{:});
hwp_tol=get_keyval_default('hwp_tol',10,varargin{:});

ind=find(hwp>hwp_max);
if isempty(ind)
  return
end
if min(diff(ind))==1
  error('we have consecutive bad samples in repair_hwp.  Bailing in the absence of better logic.');
end

lvec=ind-1;
if lvec(1)==0
  lvec(1)=2;
end

rvec=ind+1;
if rvec(end)>length(hwp)
  rvec(end)=length(hwp)-1;
end
lvec=hwp(lvec);
rvec=hwp(rvec);
ii=find(rvec<lvec-hwp_tol);
rvec(ii)=rvec(ii)+hwp_max;
%vals=round(0.5*(lvec+rvec));
vals=0.5*(lvec+rvec);
vals(vals>hwp_max)=vals(vals>hwp_max)-hwp_max;
hwp(ind)=vals;
