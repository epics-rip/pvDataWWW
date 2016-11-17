// Copyright information and license terms for this software can be
// found in the file LICENSE that is included with the distribution

#include <pv/rpcServer.h>
#include "StatsService.h"
#include <pv/ntscalarArray.h>
#include <pv/ntaggregate.h>
#include <cmath>

using namespace epics::pvData;

namespace epics
{

namespace statsService
{

// returns this service's result structure type definition.
StructureConstPtr makeResponseStructure()
{
    return StructureConstPtr();
}


// Definition of the Stats RPC service.

epics::pvData::PVStructurePtr StatsService::request(
    epics::pvData::PVStructurePtr const & pvArgument
    ) throw (pvAccess::RPCRequestException)
{   
    // Extract the arguments.
    // Report an error by throwing a RPCRequestException

    // calculate the mean, N and other values


    // Create the result structure of the data interface.


    // Fill in the value of the structure's fields


    // return the structure. Replace null structure with one constructed 
    return PVStructurePtr();
}

}

}
