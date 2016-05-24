// Copyright information and license terms for this software can be
// found in the file LICENSE that is included with the distribution


#ifndef MATHSSERVICERPC_H
#define MATHSSERVICERPC_H

#include <pv/rpcService.h>

namespace epics
{

namespace mathsService
{

/**
 * Declaration of the Maths RPC service.
 */
class MathsService : public epics::pvAccess::RPCService
{
public:
    POINTER_DEFINITIONS(MathsService);

    epics::pvData::PVStructurePtr request(
        epics::pvData::PVStructurePtr const & args
            ) throw (epics::pvAccess::RPCRequestException);
};

}

}

#endif
