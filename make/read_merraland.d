read_merraland.o read_merraland.d : read_merraland.F90
read_merraland.o : merraland_forcingMod.o
read_merraland.o : LDT_misc.h
read_merraland.o : LDT_metforcingMod.o
read_merraland.o : LDT_coreMod.o
read_merraland.o : LDT_logMod.o
read_merraland.o : LDT_FORC_AttributesMod.o
