#!/bin/bash

THISDIR=${PWD}

EV4_BASE=$THISDIR

if [ "$1" = "clean" ]; then
   echo "Removing old RELEASE.locals"
   find . -name RELEASE.local -exec rm {} \; 
   exit 0
fi


if [ "$1" = "" ]; then

    echo "Configuring ..."
    echo "EPICS_BASE =  ${EPICS_BASE}"
    echo "ARCHIVER = ${ARCHIVER_DIR}"

    echo "EV4_BASE=${EV4_BASE}" > RELEASE.local
    echo "PVDATABASE=\$(EV4_BASE)/pvDatabaseCPP" >> RELEASE.local
    echo "PVASRV=\$(EV4_BASE)/pvaSrv" >> RELEASE.local
    echo "PVACCESS=\$(EV4_BASE)/pvAccessCPP" >> RELEASE.local
    echo "PVDATA=\$(EV4_BASE)/pvDataCPP" >> RELEASE.local
    echo "PVCOMMON=\$(EV4_BASE)/pvCommonCPP" >> RELEASE.local
    if [ -d ${ARCHIVER_DIR} ]; then
        echo "ARCHIVER=${ARCHIVER_DIR}" >> RELEASE.local
    fi
    echo "EPICS_BASE=${EPICS_BASE}" >> RELEASE.local

    echo "RELEASE.local file created"
    echo "Configuration successful"
    exit 0
fi


if [ "$1" = "multi" ]; then

    echo "Configuring ..."
    echo "EPICS_BASE =  ${EPICS_BASE}"
    echo "ARCHIVER = ${ARCHIVER_DIR}"

    if [ -e pvCommonCPP/configure ]; then
        pushd pvCommonCPP/configure
        echo "EPICS_BASE=${EPICS_BASE}" > RELEASE.local
        popd
    else
        echo "Skipping pvCommonCPP/configure - doesn't exist" 
    fi

    if [ -e pvDataCPP/configure ]; then
        echo "Making config files for pvCommonCPP" 
        pushd pvDataCPP/configure
        echo "EV4_BASE=${EV4_BASE}" > RELEASE.local
        echo "PVCOMMON=\$(EV4_BASE)/pvCommonCPP" >> RELEASE.local
        echo "EPICS_BASE=${EPICS_BASE}" >> RELEASE.local   
        popd
    else
        echo "Skipping pvDataCPP: configure - doesn't exist" 
    fi

    if [ -e pvAccessCPP/configure ]; then
        echo "Making config files for pvAccessCPP" 
        pushd pvAccessCPP/configure
        echo "EV4_BASE=${EV4_BASE}" > RELEASE.local
        echo "PVDATA=\$(EV4_BASE)/pvDataCPP" >> RELEASE.local
        echo "PVCOMMON=\$(EV4_BASE)/pvCommonCPP" >> RELEASE.local
        echo "EPICS_BASE=${EPICS_BASE}" >> RELEASE.local
        popd
    else
        echo "Skipping pvAccessCPP: configure - doesn't exist" 
    fi

    if [ -e pvaSrv/configure ]; then
        echo "Making config files for pvaSrv" 
        pushd pvaSrv/configure
        echo "EV4_BASE=${EV4_BASE}" > RELEASE.local
        echo "PVACCESS=\$(EV4_BASE)/pvAccessCPP" >> RELEASE.local
        echo "PVDATA=\$(EV4_BASE)/pvDataCPP" >> RELEASE.local
        echo "PVCOMMON=\$(EV4_BASE)/pvCommonCPP" >> RELEASE.local
        echo "EPICS_BASE=${EPICS_BASE}" >> RELEASE.local
        popd
    else
        echo "Skipping pvaSrv: configure doesn't exist" 
    fi

    if [ -e pvDatabaseCPP/configure ]; then
        echo "Making config files for pvDatabaseCPP" 
        pushd pvDatabaseCPP/configure
        echo "EV4_BASE=${EV4_BASE}" > RELEASE.local
        echo "PVASRV=\$(EV4_BASE)/pvaSrv" >> RELEASE.local
        echo "PVACCESS=\$(EV4_BASE)/pvAccessCPP" >> RELEASE.local
        echo "PVDATA=\$(EV4_BASE)/pvDataCPP" >> RELEASE.local
        echo "PVCOMMON=\$(EV4_BASE)/pvCommonCPP" >> RELEASE.local
        echo "EPICS_BASE=${EPICS_BASE}" >> RELEASE.local
        popd
    else
        echo "Skipping pvDatabaseCPP: configure doesn't exist" 
    fi

    if [ -e exampleCPP/HelloWorld/configure ]; then
        echo "Making config files for exampleCPP/HelloWorld" 
        pushd exampleCPP/HelloWorld/configure
        echo "EV4_BASE=${EV4_BASE}" > RELEASE.local
        echo "PVACCESS=\$(EV4_BASE)/pvAccessCPP" >> RELEASE.local
        echo "PVDATA=\$(EV4_BASE)/pvDataCPP" >> RELEASE.local
        echo "PVCOMMON=\$(EV4_BASE)/pvCommonCPP" >> RELEASE.local
        echo "EPICS_BASE=${EPICS_BASE}" >> RELEASE.local
        popd
    else
        echo "Skipping exampleCPP/HelloWorld: configure doesn't exist" 
    fi

    if [ -e exampleCPP/ChannelArchiverService/configure ]; then
        echo "Making files for exampleCPP/ChannelArchiverService" 
        pushd exampleCPP/ChannelArchiverService/configure
        echo "EV4_BASE=${EV4_BASE}" > RELEASE.local
        echo "PVACCESS=\$(EV4_BASE)/pvAccessCPP" >> RELEASE.local
        echo "PVDATA=\$(EV4_BASE)/pvDataCPP" >> RELEASE.local
        echo "PVCOMMON=\$(EV4_BASE)/pvCommonCPP" >> RELEASE.local
        if [ -d ${ARCHIVER_DIR} ]; then
            echo "ARCHIVER=${ARCHIVER_DIR}" >> RELEASE.local
        fi
        echo "EPICS_BASE=${EPICS_BASE}" >> RELEASE.local
        popd
    else
        echo "Skipping exampleCPP/ChannelArchiverService: configure doesn't exist" 
    fi

    exit 0
fi

echo "Unknown option $1"
exit 1





