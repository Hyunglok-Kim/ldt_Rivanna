rdhm356_get_forcing.o rdhm356_get_forcing.d : rdhm356_get_forcing.F90
rdhm356_get_forcing.o : rdhm356_forcingMod.o
rdhm356_get_forcing.o : LDT_coreMod.o
rdhm356_get_forcing.o : LDT_timeMgrMod.o
rdhm356_get_forcing.o : LDT_logMod.o
