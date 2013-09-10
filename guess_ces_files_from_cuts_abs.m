function[nm_test]=guess_ces_files_from_cuts_abs(cutsname,varargin)

if iscell(cutsname)
  for j=length(cutsname):-1:1,
    nm_test{j}=guess_ces_files_from_cuts_abs(cutsname{j},varargin{:});
  end
  return
end
dirroot=get_keyval_default('dirroot','/project/r/rbond/abs/data/cryo/',varargin{:});

[dr,tt,ext]=fileparts(cutsname);
tt=strsplit(tt,'_');
assert(numel(tt)==3);
myct=str2num(tt{2});
nm_test=_find_dirfile(myct,tt,'.000',dirroot);
if ~isempty(nm_test)
  [aa,bb,cc]=fileparts(nm_test);
  to_exec=['ls -1d ' aa '/' bb '.*'];
  [fwee,flub]=system(to_exec);
  nm_test=strsplit(flub,sprintf('\n'),true);
end
return





function[nm_test]=_find_dirfile(myct,tt,ext,dirroot)
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

