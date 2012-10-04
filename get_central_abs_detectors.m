function[rows,cols]=get_central_abs_detectors(rows,cols,thresh)
[dx,dy]=get_abs_detector_offsets (rows,cols);
rr=sqrt(dx.^2+dy.^2);
ii=find(rr<thresh);
rows=rows(ii);
cols=cols(ii);

