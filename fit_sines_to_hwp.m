function[dat,mymod,fitp]=fit_sines_to_hwp(tod,varargin)

%if first argument is a TOD, pull things from it, otherwise use what's there.
if (numel(tod)==1)
  dat=get_tod_data(tod);
  hwp=get_tod_hwp(tod);
else
  dat=tod;
  clear tod;
  hwp=varargin{1};
  varargin=varargin(2:end);
end



npoly=get_keyval_default('npoly',0,varargin{:});
nsin=get_keyval_default('nsin',90,varargin{:});
do_slope=get_keyval_default('do_slope',false,varargin{:});
hwp_scale_fac=get_keyval_default('hwp_scale_fac',9000/2/pi,varargin{:});
hwp=round(hwp*hwp_scale_fac);


ndat=length(hwp);

if min(hwp)<=0
  delt=1-min(hwp);
  hwp=hwp+delt;
else
  delt=0;
end

x1=(0:nsin)';
%x1=x1/nsin*2*pi/9000;
x2=(1:nsin)';
%x2=x2/nsin*2*pi/9000;

lookup_mat=zeros(2*nsin+1,max(hwp));

for j=1:max(hwp),
  lookup_mat(:,j)=[cos(x1*j/9000*2*pi);sin(x2*j/9000*2*pi)];
end


sinmat=zeros(2*nsin+1,ndat);
for j=1:ndat,
  %sinmat(:,j)=[cos(x1);sin(x2)];
  sinmat(:,j)=lookup_mat(:,hwp(j));
end



if (do_slope)|(npoly>0)
  xvec=1:ndat;
  xvec=xvec'-mean(xvec);
  xvec=xvec/max(xvec);
end  

if (do_slope)

  sinmat=[sinmat;sinmat]';
  for j=2*nsin+2:size(sinmat,2),
    sinmat(:,j)=sinmat(:,j).*xvec;
  end
  sinmat=sinmat';
end



if npoly>0
  poly_mat=zeros(ndat,npoly);
  for j=1:npoly,
    poly_mat(:,j)=xvec.^j;
  end
  sinmat=[sinmat;poly_mat'];
  lookup_mat(end+1:(end+npoly),:)=0;
end



lhs=sinmat*sinmat';
rhs=sinmat*dat;
fitp=inv(lhs)*rhs;
if (npoly>0)
  fitp(end-npoly+1:end,:)=0;
end

dat=dat-sinmat'*fitp;
mymod=lookup_mat'*fitp(1:size(lookup_mat,1),:);
return
mymod=[mymod lookup_mat'*fitp(size(lookup_mat,1)+1:2*size(lookup_mat,1))];

toc