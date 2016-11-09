// Copyright information and license terms for this software can be
// found in the file LICENSE that is included with the distribution

#include <pv/rpcServer.h>
#include "StatsService.h"


using namespace epics::pvAccess;

// Main is the entry point of the statsService server side executable.

int main(int argc,char *argv[])
{
    RPCServer server;

    // register our service as "statsService"
    server.registerService("statsService",
        RPCService::shared_pointer(new epics::statsService::StatsService()));

    server.printInfo();
    server.run();

    return 0;
}

