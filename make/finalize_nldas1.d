finalize_nldas1.o finalize_nldas1.d : finalize_nldas1.F90
finalize_nldas1.o : nldas1_forcingMod.o
finalize_nldas1.o : LDT_coreMod.o
