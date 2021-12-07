read_nldas1.o read_nldas1.d : read_nldas1.F90
read_nldas1.o : nldas1_forcingMod.o
read_nldas1.o : LDT_coreMod.o
read_nldas1.o : LDT_misc.h
read_nldas1.o : LDT_logMod.o
read_nldas1.o : LDT_metforcingMod.o
