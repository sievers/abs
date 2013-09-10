function[az,el]=read_abs_boresight_azel(tod_name,apply_offsets)
if ~exist('apply_offsets')
  apply_offsets=true;
end

az_offset=20725175;
el_offset=65008;

%if numel(tod_name)==1 %getting a dirfile pointer here  
if ~ischar(tod_name) %getting a dirfile pointer here  
  myf=tod_name;
  try 
    az=getdata_double_channel(myf,'corr_az_encoder_counts');
  catch
    az=getdata_double_channel(myf,'az_encoder_counts');
    az=repair_vec(az);
  end

  try
    el=getdata_double_channel(myf,'corr_el_encoder_counts');
  catch 
    el=getdata_double_channel(myf,'el_encoder_counts');
    el=repair_vec(el);  
  end
else

  if tod_name(end)~='/'
    tod_name(end+1)='/';
  end
  fid=fopen([tod_name 'hk/az_encoder_counts']);
  az=fread(fid,inf,'int32');
  fclose(fid);
  %az_offset=21070040;

  fid=fopen([tod_name 'hk/el_encoder_counts']);
  el=fread(fid,inf,'int32');
  fclose(fid);
end
if apply_offsets==false
  return
end

az=(az-az_offset)*360/2^25;
az=az*pi/180;



%el_offset=64793;

el=el-el_offset;
el=90+el*360/2^17;

%el=90+(el-el_offset)*360/2^17;
%el=(el-el_offset)*360/2^17;

el=el*pi/180;

function[vec]=repair_vec(vec)
bad_ind=find(vec>2e9);

if numel(bad_ind)==0
  return
end
disp(['repairing ' num2str(numel(bad_ind)) ' samples.']);

if bad_ind(1)==1
  vec(1)=median(vec);
  bad_ind=bad_ind(2:end);
end
for j=1:numel(bad_ind)
  vec(bad_ind(j))=vec(bad_ind(j)-1);
end
