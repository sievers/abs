function[true_az,true_el]=convert_enc_to_true_ptg_model_ctime(enc_az,enc_el,avg_ctime)

	%function returns true_az, true_el in radians based on the ABS boresight pointing model v0
	%enc_az, enc_el must be in radians

	if avg_ctime>1344069619 && avg_ctime<1345763417
		disp ('ctime falls between August 4, 2012 and August 23, 2012 - Exact ctime when the az. shift happened is unknown. Just correcting the encoder to true values using pointing model but no additional shifts are added to encoder az');
	elseif avg_ctime>1345763417
		enc_az=enc_az+9.*pi/180;
	end

	%affects el
	ELS_1 = 0.00358479423716; %sag, etc. degree 1 polynomial - takes the form -> ELS_1*x+ELS_2
	ELS_2 = -0.00288333759537; %sag, etc. degree 1 polynomial - takes the form -> ELS_1*x+ELS_2
	ELZ = 3.766911e-04; %El. zero

	%affects az
	IA = -8.241415e-03; %Az. zero
	NOAE = 1.741000e-03; %non-orthogonality of Az, el

	%affects both az and el
	AN = -4.846936e-04; %Az. tilt north
	AE = -6.033426e-04; %Az. tilt east

	true_el = enc_el + ( (ELS_1 * enc_el + ELS_2) + AN*cos(enc_az) + AE*sin(enc_az) + ELZ );

	%true_az = enc_az - (( IA*cos(enc_el) + NOAE*sin(enc_el) + AN*sin(enc_az)*sin(enc_el) - AE*cos(enc_az)*sin(enc_el) ) / cos(enc_el)); % I fit az*cos(el) - Hence the division by cos(el)
	true_az = arrayfun(@(a,b,c) (a + ( (IA*cos(c) + NOAE*sin(c) + AN*sin(b)*sin(c) - AE*cos(b)*sin(c)) / cos(c) )), enc_az, enc_az, enc_el); % I fit az*cos(el) - Hence the division by cos(el)

return
