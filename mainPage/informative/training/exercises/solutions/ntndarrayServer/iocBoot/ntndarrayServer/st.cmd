< envPaths

cd ${TOP}

## Register all support components
dbLoadDatabase("dbd/ntndarrayServer.dbd")
ntndarrayServer_registerRecordDeviceDriver(pdbbase)

## Load record instances
dbLoadRecords("db/dbScalar.db","name=pvdouble,type=ao")
dbLoadRecords("db/dbArray.db","name=pvdoubleArray,type=DOUBLE")
dbLoadRecords("db/dbStringArray.db","name=pvstringArray")
dbLoadRecords("db/dbEnum.db","name=pvenum")
dbLoadRecords("db/dbCounter.db","name=pvcounter");

cd ${TOP}/iocBoot/${IOC}
iocInit()
dbl
epicsThreadSleep(1.0)
ntndarrayServerCreateRecord testNDArray
ntndarrayServerCreateRecord testMP
startPVAServer
pvdbl

