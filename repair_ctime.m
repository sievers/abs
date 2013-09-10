function[ct,bad]=repair_ctime(ct)
dd=diff(ct);
tsamp=median(dd);
bad=find(abs(dd-tsamp)>0.01*tsamp);
mdisp(['have ' num2str(numel(bad)) ' bad ctime samples.']);
for j=1:length(bad),
  ct(bad(j)+1)=ct(bad(j))+tsamp;
end
%if numel(bad)>0
%  ct=repair_ctime(ct);
%end
