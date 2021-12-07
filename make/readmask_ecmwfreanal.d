readmask_ecmwfreanal.o readmask_ecmwfreanal.d : readmask_ecmwfreanal.F90
readmask_ecmwfreanal.o : LDT_coreMod.o
readmask_ecmwfreanal.o : ecmwfreanal_forcingMod.o
readmask_ecmwfreanal.o : LDT_logMod.o
