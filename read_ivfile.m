function[iv_facs]=read_ivfile(ivname,tag,doflip)

if ~exist('tag')
  tag='<Responsivity(W/DACfb)_';
end
if isempty(tag)
  tag='<Responsivity(W/DACfb)_';
end

if ~exist('doflip') %do we flip the signs of columns
  doflip=true;
end


lines=read_text_file_comments(ivname);
nl=numel(lines);
is_used=false(size(lines));

taglen=numel(tag);
for j=1:nl,
  if strncmp(lines{j},tag,taglen)
    is_used(j)=true;
  end
end
lines=lines(is_used);
nl=numel(lines);
%disp(lines);
[a,b]=strtok(lines{1});
nrow=numel(str2num(b));
iv_facs=zeros(nl,nrow);
for j=1:nl,
  [a,b]=strtok(lines{j});  
  iv_facs(j,:)=str2num(b);
end
iv_facs=iv_facs'; %so indexing is (row,column)


if (doflip)
  %do the sign flipping since columns have varying signs.
  column_signs= [ 1.0, -1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0,1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0,-1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 ];
  assert(size(iv_facs,2)==length(column_signs));
  column_signs=repmat(column_signs,[size(iv_facs,1) 1]);
  iv_facs=iv_facs.*column_signs;
end

