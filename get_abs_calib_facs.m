function[calib_facs]=get_abs_calib_facs(todname,varargin)
ff=get_keyval_default('iv_file','',varargin{:});
efficiency_file=get_keyval_default('efficiency_file','',varargin{:});
if isnumeric(efficiency_file)  %going to do a default here
  efficiency_file='/home/sievers/abs/detectors/optical_efficiencies/efficiency_04152012.txt';
end

if isempty(ff)
  ff=find_my_ivfile(todname);
end

calib_facs=read_ivfile(ff);
if ~isempty(efficiency_file)
  efficiencies=read_ivfile(efficiency_file,'<ratio_multiply_dP_C',false);
  min=get_keyval_default('min_efficiency',0.0,varargin{:});
  max=get_keyval_default('max_efficiency',0.4,varargin{:});
  efficiencies(efficiencies<=min)=nan;
  efficiencies(efficiencies>max)=nan;
  calib_facs=calib_facs./efficiencies;
end

  


%keep_ind=true(length(row),1);
%for j=1:length(row)
%  if calib_facs(row(j)+1,col(j)+1)==0
%    keep_ind(j)=false;
%  end
%end







%if sum(keep_ind==false)>0
%  disp(['Cutting ' num2str(sum(keep_ind==false)) ' detectors for missing IV values.'])
%    row=row(keep_ind);
%    col=col(keep_ind);
%  end
%end

