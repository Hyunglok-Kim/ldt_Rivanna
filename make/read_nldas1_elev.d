read_nldas1_elev.o read_nldas1_elev.d : read_nldas1_elev.F90
read_nldas1_elev.o : nldas1_forcingMod.o
read_nldas1_elev.o : LDT_fileIOMod.o
read_nldas1_elev.o : LDT_coreMod.o
read_nldas1_elev.o : LDT_logMod.o
read_nldas1_elev.o : LDT_metforcingMod.o
