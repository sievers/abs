function[tod_tags]=cuts_names_to_tod_tags_abs(cuts_names) 
if iscell(cuts_names)
  tod_tags=cell(size(cuts_names));
  for j=1:length(cuts_names),
    tod_tags(j)=cuts_names_to_tod_tags_abs(cuts_names{j});
  end
  return
end
ii=max(find(cuts_names=='/'));
cuts_names=cuts_names(ii+1:end);
tt='cuts_';
if strncmp(cuts_names,tt,length(tt))
  cuts_names=cuts_names(length(tt)+1:end);
end
tod_tags=['/fwee/'  cuts_names '.000'];


