function[isbad,tvec]=find_bad_abs_ctime_samples(tvec)
isbad=tvec>1e20;
if (1)
  dt=diff(tvec);
  dt=[1; dt];
  isbad=isbad|(dt==0);
end

bad_samps=find(isbad);
dt=median(diff(tvec));
for j=1:numel(bad_samps)
  tvec(bad_samps(j))=tvec(bad_samps(j)-1)+dt;
end
