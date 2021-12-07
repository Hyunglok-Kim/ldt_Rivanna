get_chirps2.o get_chirps2.d : get_chirps2.F90
get_chirps2.o : LDT_coreMod.o
get_chirps2.o : LDT_timeMgrMod.o
get_chirps2.o : LDT_logMod.o
get_chirps2.o : LDT_metforcingMod.o
get_chirps2.o : chirps2_forcingMod.o
