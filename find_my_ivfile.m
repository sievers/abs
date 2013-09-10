function[iv_name]=find_my_ivfile(tod_name,dirroot)
if tod_name(end)=='/'
  tod_name=tod_name(1:end-1);
end
ii=max(find(tod_name=='/'));
dr=tod_name(1:ii);
if exist('dirroot')
  tt=strsplit(dr,'/',true);
  dr=[dirroot '/' tt{end}];
end

%disp(['directory is ' dr]);
[a,b]=system(['ls ' dr '/iv*.out']);
iv_names=mystrsplit(b,10);
if isempty(iv_names)
  %give it another chance in case system craps out momentarily
  [a,b]=system(['ls ' dr '/iv*.out']);
  iv_names=mystrsplit(b,10);
  if isempty(iv_names)
    warning(['find_my_ivfile failed on ' tod_name]);
    return
  end
end


tail=tod_name(ii+1:end);
ii2=min(find(tail=='_'));
myctime=str2num(tail(1:ii2-1));
%sprintf('myctime is %d',myctime)
target_ctimes=get_iv_ctimes(iv_names);


ii=target_ctimes<=myctime; %these are the guys that happened before me.
if sum(ii)==0
  error(['unable to find any iv.out file with ctime predating the requested file.']);
end

target_ctimes=target_ctimes(ii);
iv_names=iv_names(ii);

[a,b]=max(target_ctimes);  %this is the latest file of those that are still left
iv_name=iv_names{b};


function[ivtimes]=get_iv_ctimes(iv_names)
ivtimes=zeros(size(iv_names));
n=numel(ivtimes);
for j=1:n,
  nm=iv_names{j};
  ii=max(find(nm=='/'));
  tag=nm(ii+1:end);
  ii=min(find(tag=='_'));
  tag=tag(ii+1:end);
  ii=min(find(tag=='.'));
  tag=tag(1:ii-1);

  tmp=str2num(tag);
  if isempty(tmp)
    ivtimes(j)=-1;
  else
    ivtimes(j)=tmp;
  end
  %ivtimes(j)=str2num(tag);
end

