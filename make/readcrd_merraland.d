readcrd_merraland.o readcrd_merraland.d : readcrd_merraland.F90
readcrd_merraland.o : merraland_forcingMod.o
readcrd_merraland.o : LDT_coreMod.o
readcrd_merraland.o : LDT_logMod.o
