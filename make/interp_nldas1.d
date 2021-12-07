interp_nldas1.o interp_nldas1.d : interp_nldas1.F90
interp_nldas1.o : nldas1_forcingMod.o
interp_nldas1.o : LDT_coreMod.o
