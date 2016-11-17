// Copyright information and license terms for this software can be
// found in the file LICENSE that is included with the distribution

#include <pv/rpcServer.h>
#include "MathsService.h"

using namespace epics::pvData;

namespace epics
{

namespace mathsService
{

// returns this service's result structure type definition.
StructureConstPtr makeResponseStructure()
{
#if 0
    FieldCreatePtr factory = getFieldCreate();

    FieldConstPtrArray fields;
    StringArray names;

    names.push_back("sum");
    fields.push_back(factory->createScalar(pvDouble));

    return factory->createStructure(names, fields);
#else
    return getFieldCreate()->
       createFieldBuilder()->add("sum", pvDouble)->createStructure();
#endif
}


// Definition of the Maths RPC service.

epics::pvData::PVStructurePtr MathsService::request(
    epics::pvData::PVStructurePtr const & pvArgument
    ) throw (pvAccess::RPCRequestException)
{   
    // Extract the two arguments.
    // Report an error by throwing a RPCRequestException
    epics::pvData::PVStringPtr aField = pvArgument->getSubField<PVString>("a");
    if (!aField)
    {
        throw pvAccess::RPCRequestException(Status::STATUSTYPE_ERROR,
            "PVString field with name 'a' expected.");
    }

    epics::pvData::PVStringPtr bField = pvArgument->getSubField<PVString>("b");
    if (!bField)
    {
        throw pvAccess::RPCRequestException(Status::STATUSTYPE_ERROR,
            "PVString field with name 'b' expected.");
    }

    // Create the result structure of the data interface.
    PVStructurePtr result(
        getPVDataCreate()->createPVStructure(makeResponseStructure()));

    // Fill in the value of the structure's sum field
    double a = atof(aField->get().c_str());
    double b = atof(bField->get().c_str());

    PVDoublePtr sumField = result->getSubField<PVDouble>("sum");
	sumField->put(a+b);
    
    // return the structure.
    return result;
}

}

}
