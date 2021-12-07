get_nldas1.o get_nldas1.d : get_nldas1.F90
get_nldas1.o : nldas1_forcingMod.o
get_nldas1.o : LDT_coreMod.o
get_nldas1.o : LDT_timeMgrMod.o
get_nldas1.o : LDT_logMod.o
get_nldas1.o : LDT_metforcingMod.o
