readGHCNANNdata.o readGHCNANNdata.d : readGHCNANNdata.F90
readGHCNANNdata.o : LDT_misc.h
readGHCNANNdata.o : LDT_coreMod.o
readGHCNANNdata.o : LDT_ANNMod.o
readGHCNANNdata.o : LDT_timeMgrMod.o
readGHCNANNdata.o : LDT_logMod.o
readGHCNANNdata.o : map_utils.o
readGHCNANNdata.o : GHCN_ANNdataMod.o
