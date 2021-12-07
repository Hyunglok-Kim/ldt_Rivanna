readsyntheticsmANNdata.o readsyntheticsmANNdata.d : readsyntheticsmANNdata.F90
readsyntheticsmANNdata.o : LDT_misc.h
readsyntheticsmANNdata.o : LDT_coreMod.o
readsyntheticsmANNdata.o : LDT_ANNMod.o
readsyntheticsmANNdata.o : LDT_timeMgrMod.o
readsyntheticsmANNdata.o : LDT_logMod.o
readsyntheticsmANNdata.o : syntheticsm_ANNdataMod.o
readsyntheticsmANNdata.o : map_utils.o
