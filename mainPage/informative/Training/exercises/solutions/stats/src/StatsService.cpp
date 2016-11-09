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
    return getFieldCreate()-> createFieldBuilder()->
       setId("epics:nt/NTAggregate:1.0")->
       add("value", pvDouble)->
       add("N", pvLong)->
       add("dispersion", pvDouble)->
       add("max", pvDouble)->
       add("min", pvDouble)->
       createStructure();
}


// Definition of the Stats RPC service.

epics::pvData::PVStructurePtr StatsService::request(
    epics::pvData::PVStructurePtr const & pvArgument
    ) throw (pvAccess::RPCRequestException)
{   
    // Extract the arguments.
    // Report an error by throwing a RPCRequestException
    epics::pvData::PVDoubleArrayPtr args = pvArgument->getSubField<PVDoubleArray>("value");
    if (!args)
    {
        throw pvAccess::RPCRequestException(Status::STATUSTYPE_ERROR,
            "PVDoubleArray field with name 'value' expected.");
    }

    PVDoubleArray::const_svector vals = args->view();

    bool firstTime = true;
    double sum = 0.0;
    double sumSq = 0.0;
    double disp = 0.0;
    double mean = 0.0;
    double max = 0.0;
    double min = 0.0;
    long N = vals.size();

    for (PVDoubleArray::const_svector::const_iterator it = vals.begin();
         it != vals.end(); ++it)
    {
        double value = *it;
        sum += value;
        sumSq += value*value;
        if (value > max || firstTime) max = value;
        if (value < min || firstTime) min = value;
        firstTime = false;
    }

    if (N > 0)
    {
        mean = sum/N;
        disp = sqrt(sumSq/N - mean*mean);
    }

    // Create the result structure of the data interface.
    PVStructurePtr result(
        getPVDataCreate()->createPVStructure(makeResponseStructure()));

    // Fill in the value of the structure's fields
    PVDoublePtr sumField = result->getSubFieldT<PVDouble>("value");
	sumField->put(mean);

    PVLongPtr nField = result->getSubFieldT<PVLong>("N");
	nField->put(N);

    PVDoublePtr dispField = result->getSubFieldT<PVDouble>("dispersion");
	dispField->put(disp);

    PVDoublePtr maxField = result->getSubFieldT<PVDouble>("max");
	maxField->put(max);

    PVDoublePtr minField = result->getSubFieldT<PVDouble>("min");
	minField->put(min);

    // return the structure.
    return result;
}

}

}
