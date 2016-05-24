TOP=..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#==================================================
# Build an IOC support library
#


PROD_HOST += ntndarrayServerMain
ntndarrayServerMain_SRCS += ntndarrayServerMain.cpp
ntndarrayServerMain_LIBS += Com
ntndarrayServerMain_LIBS += pvData
ntndarrayServerMain_LIBS += pvAccess
ntndarrayServerMain_LIBS += pvDatabase
ntndarrayServerMain_LIBS += ntndarrayServer
ntndarrayServerMain_LIBS += nt

DBD += ntndarrayServer.dbd

INC += ntndarrayServer.h

LIBRARY_IOC += ntndarrayServer
ntndarrayServer_SRCS += ntndarrayServer.cpp
ntndarrayServer_SRCS += ntndarrayServerThread.cpp
ntndarrayServer_SRCS += ntndarrayServerRegister.cpp
ntndarrayServer_SRCS += image.cpp
ntndarrayServer_LIBS += pvData
ntndarrayServer_LIBS += pvAccess
ntndarrayServer_LIBS += pvDatabase
ntndarrayServer_LIBS += nt
ntndarrayServer_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

