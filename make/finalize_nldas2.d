finalize_nldas2.o finalize_nldas2.d : finalize_nldas2.F90
finalize_nldas2.o : nldas2_forcingMod.o
finalize_nldas2.o : LDT_coreMod.o
finalize_nldas2.o : LDT_misc.h
