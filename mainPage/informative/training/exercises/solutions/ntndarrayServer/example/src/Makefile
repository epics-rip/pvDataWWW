TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#==================================================
# Build an IOC support library
#

DBD += ntndarrayServer.dbd

#=============================
# build an ioc application

PROD_IOC += ntndarrayServer


# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
ntndarrayServer_SRCS += ntndarrayServer_registerRecordDeviceDriver.cpp
ntndarrayServer_SRCS_DEFAULT += exampleServerMain.cpp
ntndarrayServer_SRCS_vxWorks += -nil-


# The following adds support from base/src/vxWorks
ntndarrayServer_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

ntndarrayServer_LIBS += pvData pvAccess
ntndarrayServer_LIBS += pvDatabase
ntndarrayServer_LIBS += pvaSrv
ntndarrayServer_LIBS += ntndarrayServer
ntndarrayServer_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

