// Copyright information and license terms for this software can be
// found in the file LICENSE that is included with the distribution


#ifndef MATHSSERVICERPC_H
#define MATHSSERVICERPC_H

#include <pv/rpcService.h>

namespace epics
{

namespace statsService
{

/**
 * Declaration of the Stats RPC service.
 */
class StatsService : public epics::pvAccess::RPCService
{
public:
    POINTER_DEFINITIONS(StatsService);

    epics::pvData::PVStructurePtr request(
        epics::pvData::PVStructurePtr const & args
            ) throw (epics::pvAccess::RPCRequestException);
};

}

}

#endif
