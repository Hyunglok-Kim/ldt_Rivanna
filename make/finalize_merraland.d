finalize_merraland.o finalize_merraland.d : finalize_merraland.F90
finalize_merraland.o : merraland_forcingMod.o
finalize_merraland.o : LDT_coreMod.o
