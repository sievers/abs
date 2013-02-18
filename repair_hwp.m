function[hwp]=repair_hwp(hwp,varargin)
hwp_max=get_keyval_default('max_hwp',9000,varargin{:});
hwp_tol=get_keyval_default('hwp_tol',10,varargin{:});

ind=find(hwp>hwp_max);
if isempty(ind)
  return
end
if min(diff(ind))==1

  nseg=0;
  ind=[-2; ind]; %put a dummy so there's no special logic about the first sample.
  for j=2:length(ind)
    if ind(j)>ind(j-1)+1
      nseg=nseg+1;
      ileft(nseg)=ind(j)-1;
    end
    iright(nseg)=ind(j)+1;  %this should get set correctly for the last sample
  end
  %disp(ind(2:end)');
  %disp([ileft' iright']);
  lvec=hwp(ileft);
  rvec=hwp(iright);
  ii=find(rvec<lvec+hwp_tol);
  rvec(ii)=rvec(ii)+hwp_max;
 
  for j=2:length(ind)
    ii=find((ind(j)>ileft)&(ind(j)<iright));
    %disp(['sample ' num2str(ind(j)) ' falls between ' num2str([ileft(ii) iright(ii) hwp(ileft(ii)) hwp(iright(ii))])]);
    hwp(ind(j))=interp1([ileft(ii) iright(ii)],[lvec(ii) rvec(ii)],ind(j));
    if hwp(ind(j))>hwp_max,
      hwp(ind(j))=hwp(ind(j))-hwp_max;
    end
  end 
  warning('we have consecutive bad samples in repair_hwp.  You should have a look at the repaired HWP timestream and make sure I coded things corectly.');    
  return
else
  
  lvec=ind-1;
  if lvec(1)==0
    lvec(1)=2;
  end  
  rvec=ind+1;
end
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
