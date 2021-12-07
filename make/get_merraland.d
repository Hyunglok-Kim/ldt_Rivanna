get_merraland.o get_merraland.d : get_merraland.F90
get_merraland.o : merraland_forcingMod.o
get_merraland.o : LDT_coreMod.o
get_merraland.o : LDT_timeMgrMod.o
get_merraland.o : LDT_logMod.o
get_merraland.o : LDT_metforcingMod.o
