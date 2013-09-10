function[hwp_good,ct,unwrapped,sensoray_time,myerr,omega,hwp_buf_counts0,ii,pred,badct,hwp_buf_time0,pred2]=reconstruct_hwp(fname)
if isa(fname,'int64')
  myf=fname;
else
  myf=init_getdata_file(fname);
end


hwp_buf_time0=getdata_double_channel(myf,'hwp_buf_time0');%hwp_buf_time0(hwp_buf_time0>1e13)=nan;hwp_buf_time0(hwp_buf_time0<1e9)=nan;
hwp_buf_counts0=getdata_double_channel(myf,'hwp_buf_counts0');%hwp_buf_time0(hwp_buf_time0>1e13)=nan;hwp_buf_time0(hwp_buf_time0<1e9)=nan;
sensoray_time=getdata_double_channel(myf,'sensoray_2620_time');dd=diff(sensoray_time); ii=abs(dd)>1000;dd(ii)=nan;%plot(dd,'*');
ct=getdata_double_channel(myf,'sync_time');
[ct,badct]=repair_ctime(ct);
if isa(fname,'int64')
  %do nothing because the file was opened externally
else
  close_getdata_file(myf);
end


ref_ctime_samp=2;


ii=diff(hwp_buf_time0)~=0;
ii=[true;ii];
hwp_buf_time0=hwp_buf_time0(ii);
hwp_buf_counts0=hwp_buf_counts0(ii);
sensoray_time=sensoray_time(ii);



ii=(hwp_buf_counts0>10000)|(hwp_buf_time0>1e12)|(hwp_buf_time0<1e8);
hwp_buf_time0=hwp_buf_time0(~ii);
hwp_buf_counts0=hwp_buf_counts0(~ii);
sensoray_time=sensoray_time(~ii);

[min(sensoray_time) median(sensoray_time) max(sensoray_time)]
ct=ct-hwp_buf_time0(ref_ctime_samp);
hwp_buf_time0=hwp_buf_time0-hwp_buf_time0(ref_ctime_samp);
crap=sort(sensoray_time);
%crap(1:10)

diff1=diff(hwp_buf_time0);med1=median(diff1);
diff2=diff(sensoray_time);med2=median(diff2);
[med1 med2]
thresh=0.01;  %be within 1% of the median

ok1=abs(diff1-med1)<thresh*med1;
ok2=abs(diff2-med2)<thresh*med2;
sum([ok1 ok2 ok1&ok2]);
ok=(ok1(1:end-1)&ok1(2:end)&ok2(1:end-1)&ok2(2:end));
sum(ok);

ii=find(ok)+1;  %offset to undo shifting from diffs
min(abs(sensoray_time(ii)-sensoray_time(ii-1)))
pp=polyfit(hwp_buf_time0(ii),sensoray_time(ii),1);


pred=polyval(pp,ct);




delt=hwp_buf_counts0(ii+1)-hwp_buf_counts0(ii-1);
delt(delt>4500)=delt(delt>4500)-9000;
delt(delt<-4500)=delt(delt<-4500)+9000;
dt=sensoray_time(ii+1)-sensoray_time(ii-1);
omega=median(delt./dt);

unwrapped=0*sensoray_time;
myerr=0*unwrapped;
%tt=sensoray_time(ii);
%cc=hwp_buf_counts0(ii);
unwrapped(1)=hwp_buf_counts0(1);
[min(hwp_buf_counts0) max(hwp_buf_counts0)]
for j=2:length(sensoray_time),
  targ=unwrapped(j-1)+(sensoray_time(j)-sensoray_time(j-1))*omega;
  targ2=rem(targ,9000);
  myerr(j)=rem(hwp_buf_counts0(j)-targ2+9000*10+4500,9000)-4500;


  %err=cc(j)-targ;
  %while err>4500,
  %  err =err-9000;
  %end
  %while err<-4500
  %  err=err+9000;
  %end
  if (abs(myerr(j))>200)
    disp(['goofed on ' num2str([j hwp_buf_counts0(j) targ myerr(j)])]);
    assert(1==0)
  end
  %myerr(j)=err;

  unwrapped(j)=targ+myerr(j);
end

%hwp_good=interp1(sensoray_time(ii),unwrapped,pred,'extrap','linear');

pp2=polyfit(sensoray_time(ii),hwp_buf_time0(ii),1);
pred2=polyval(pp2,sensoray_time);
hwp_good=interp1(pred2,unwrapped,ct,'extrap','linear');

return


