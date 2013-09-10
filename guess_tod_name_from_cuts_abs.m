function[nm_test]=guess_tod_name_from_cuts_abs(cutsname,varargin)

if iscell(cutsname)
  for j=length(cutsname):-1:1,
    nm_test{j}=guess_tod_name_from_cuts_abs(cutsname{j},varargin{:});
  end
  return
end
dirroot=get_keyval_default('dirroot','/project/r/rbond/abs/data/cryo/',varargin{:});

[dr,tt,ext]=fileparts(cutsname);
tt=strsplit(tt,'_');
assert(numel(tt)==3);
myct=str2num(tt{2});

mydate=date_from_ctime(myct,'yyyymmdd');
nm_test=[dirroot '/' mydate '/' tt{2} '_' tt{3} ext];
if exist(nm_test,'dir')
  return;
end

mydate=date_from_ctime(myct+86400,'yyyymmdd');
nm_test=[dirroot '/' mydate '/' tt{2} '_' tt{3} ext];
if exist(nm_test,'dir')
  return;
end

mydate='';
nm_test=[dirroot '/' mydate '/' tt{2} '_' tt{3} ext];
if exist(nm_test,'dir')
  return;
end

nm_test='';
return

