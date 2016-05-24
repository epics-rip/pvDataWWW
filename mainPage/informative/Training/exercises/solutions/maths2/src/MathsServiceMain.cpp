// Copyright information and license terms for this software can be
// found in the file LICENSE that is included with the distribution

#include <pv/rpcServer.h>
#include "MathsService.h"


using namespace epics::pvAccess;

// Main is the entry point of the mathsService server side executable.

int main(int argc,char *argv[])
{
    RPCServer server;

    // register our service as "mathsService"
    server.registerService("mathsService",
        RPCService::shared_pointer(new epics::mathsService::MathsService()));

    server.printInfo();
    server.run();

    return 0;
}

