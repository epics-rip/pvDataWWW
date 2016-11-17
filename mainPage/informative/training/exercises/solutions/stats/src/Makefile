TOP=..

include $(TOP)/configure/CONFIG

PROD_HOST += StatsService
StatsService_SRCS += StatsServiceMain.cpp
StatsService_SRCS += StatsService.cpp
StatsService_LIBS += pvAccess nt pvData Com

PROD_HOST += StatsClient
StatsClient_SRCS += StatsClient.cpp
StatsClient_LIBS += pvAccess nt pvData Com

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

