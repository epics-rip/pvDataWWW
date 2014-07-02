default: base helloWorld 

base : pvCommon pvData pvAccess pvaSrv pvDatabase

all : default archiverService

pvCommon : FORCE
	make -C pvCommonCPP

pvData : FORCE
	make -C pvDataCPP 

pvAccess : FORCE
	make -C pvAccessCPP

pvaSrv : FORCE
	make -C pvaSrv

pvDatabase : FORCE
	make -C pvDatabaseCPP

helloWorld : FORCE
	make -C exampleCPP/HelloWorld

archiverService : FORCE
	make -C exampleCPP/ChannelArchiverService

clean : 
	make -C pvCommonCPP clean
	make -C pvDataCPP clean
	make -C pvAccessCPP clean
	make -C pvaSrv clean
	make -C pvDatabaseCPP clean
	make -C exampleCPP/HelloWorld clean
	make -C exampleCPP/ChannelArchiverService clean

configure: FORCE
	./configure.sh

config_multi: FORCE
	./configure.sh multi

config_clean:
	./configure.sh clean


FORCE:


