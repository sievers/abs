function[mapset]=create_initial_mapset_abs(tods,mapset,mapset_in,myopts)
myid=mpi_comm_rank+1;
nproc=mpi_comm_size;

do_exact_pointing=get_struct_mem(myopts,'do_exact_pointing',true);
debutter=get_struct_mem(myopts,'debutter',true);
if debutter
  debutter_expt=get_struct_mem(myopts,'debutter_expt','abs');
end
noise_model=get_struct_mem(myopts,'noise_model',@set_tod_noise_bands_projvecs);

