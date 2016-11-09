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


// Definition of the Stats RPC service.

epics::pvData::PVStructurePtr StatsService::request(
    epics::pvData::PVStructurePtr const & pvArgument
    ) throw (pvAccess::RPCRequestException)
{   
    // Extract the arguments.
    // Report an error by throwing a RPCRequestException
    epics::nt::NTScalarArrayPtr ntscalarArray =
        epics::nt::NTScalarArray::wrapUnsafe(pvArgument);

    epics::pvData::PVDoubleArrayPtr args = ntscalarArray->getValue<PVDoubleArray>();
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

    nt::NTAggregatePtr ntaggregate = nt::NTAggregate::createBuilder()->
    addDispersion()->
    addMax()->
    addMin()->
    create();

    // Fill in the value of the structure's fields
    PVDoublePtr sumField = ntaggregate->getValue();
	sumField->put(mean);

    PVLongPtr nField = ntaggregate->getN();
	nField->put(N);

    PVDoublePtr dispField = ntaggregate->getDispersion();
	dispField->put(disp);

    PVDoublePtr maxField = ntaggregate->getMax();
	maxField->put(max);

    PVDoublePtr minField = ntaggregate->getMin();
	minField->put(min);

    // return the structure.
    return ntaggregate->getPVStructure();
}

}

}
