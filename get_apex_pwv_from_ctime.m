function[pwv,pwv_data]=get_apex_pwv_from_ctime(ctimes)
if size(ctimes,1)==1,
  ctimes=ctimes';
end

persistent pwv_data  %we're going to save this so we don't reload at every call
if isempty(pwv_data)
  disp(['loading pwv data.  please be patient.'])
  pwv_data=load('/home/sievers/abs/radiometer/apex_weather_through_17may2012.txt');
  pwv_data=sortrows(pwv_data,1);
  ii=diff(pwv_data(:,1))~=0;
  ii(end+1)=true;
  pwv_data=pwv_data(ii,:);
  assert(min(diff(pwv_data(:,1))>0));
end


inds=0*ctimes;
for j=1:numel(ctimes),
  ii=find_minimum_ind(ctimes(j),pwv_data);
  inds(j)=ii;
end

dd=[pwv_data(inds,2) pwv_data(inds+1,2)];
tt=[pwv_data(inds,1) pwv_data(inds+1,1)];
frac=ctimes-tt(:,1);
dt=tt(:,2)-tt(:,1);
pwv=dd(:,1)+(dd(:,2)-dd(:,1)).*(frac./dt);
if min(min(dd))==0
  warning(['Some requested data has zeros in PWV.  You should be careful.']);
  ii= (dd(:,1)==0)|(dd(:,2)==0);
  pwv(ii)=0;
end

nminute=5;
if max(abs(dt))>60*nminute,
  warning(['Did not find pwv data within ' num2str(nminute) ' minutes of at least some of the requested ctimes.']);
  pwv(abs(dt)>60*nminute)=0; %flag these guys with zero
end
return


function[ind]=find_minimum_ind(ct,dat)

if ct<dat(1,1)
  error('ct out of minimum range')
end
if (ct>=dat(end,1))
  error('ct out of maximum range')
end
i1=1;
i2=round(size(dat,1));
i3=size(dat,1);
while (i3-i1)>1
  if ct>dat(i2,1)
    i1=i2;
    i2=floor((i1+i3)/2);
  else
    i3=i2;
    i2=floor((i1+i3)/2);
  end
end
ind=i1;
