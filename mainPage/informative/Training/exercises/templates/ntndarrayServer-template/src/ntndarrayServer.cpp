/* ntndarrayServer.cpp */
/**
 * Copyright - See the COPYRIGHT that is included with this distribution.
 * EPICS pvData is distributed subject to a Software License Agreement found
 * in file LICENSE that is included with this distribution.
 */
/**
 * @author dgh
 * @date 2016.05.17
 */

#include <pv/standardPVField.h>
#include <pv/ntndarrayServer.h>

#include "epicsv4Grayscale.h"

namespace epics { namespace ntndarrayServer { 
using namespace epics::pvData;
using namespace epics::pvDatabase;
using namespace epics::nt;
using std::tr1::static_pointer_cast;
using std::tr1::dynamic_pointer_cast;
using std::string;

NTNDArrayRecordPtr NTNDArrayRecord::create(
    string const & recordName)
{

    PVStructurePtr pvStructure = NTNDArray::createBuilder()->
        addTimeStamp()->createPVStructure();

    NTNDArrayRecordPtr pvRecord(
        new NTNDArrayRecord(recordName,pvStructure));

    if(!pvRecord->init()) pvRecord.reset();

    return pvRecord;
}

NTNDArrayRecord::NTNDArrayRecord(
    string const & recordName,
    PVStructurePtr const & pvStructure)
: PVRecord(recordName,pvStructure),
  pvStructure(pvStructure),
  count(0),
  firstTime(true)
{
    ndarray = NTNDArray::wrap(pvStructure);

    imageGen = RotatingImageGenerator::create(epicsv4_raw, epicsv4_width,
        epicsv4_height);
}

NTNDArrayRecord::~NTNDArrayRecord()
{
}

void NTNDArrayRecord::destroy()
{
    PVRecord::destroy();
}

bool NTNDArrayRecord::init()
{   
    initPVRecord();
    NTNDArrayRecordPtr xxx = dynamic_pointer_cast<NTNDArrayRecord>(getPtrSelf());
    ntndarrayServerThread = NTNDArrayRecordThreadPtr(new NTNDArrayRecordThread(xxx));
    ntndarrayServerThread->init();
    ntndarrayServerThread->start();
    return true;
}

void NTNDArrayRecord::update()
{
    lock();
    try
    {
        beginGroupPut();
        PVByteArray::svector bytes;
        imageGen->fillSharedVector(bytes,angle);
        setValue(freeze(bytes));
        if (firstTime)
        {
            setDimension(epicsv4_raw_dim, 2);
            setAttributes();
            setSizes(static_cast<int64_t>(epicsv4_raw_size));
            firstTime = false;
        }
        setDataTimeStamp();
        setUniqueId(count++);
        process();
        endGroupPut();
    }
    catch(...)
    {
        unlock();
        throw;
    }
    angle += 1;
    unlock();
}

void NTNDArrayRecord::setValue(PVByteArray::const_svector const & bytes)
{
    // Get the union value field

    // Select the byteValue field stored in "value"

    // replace the shared vector with "bytes"

    // call postPut so that the union sees the change in the stored field  

}

void NTNDArrayRecord::setDimension(const int32_t * dims, size_t ndims)
{
    // Get the dimension field

    // create a shared_vector or try to reuse the dimension field's one  

    // resize/reserve the number of elements

    // Iterate over the number of dimensions, creating and adding the
    // appropriate dimension structures.

    // replace the dimensions field's shared_vector
    // (Remember to freeze first)

}

void NTNDArrayRecord::setAttributes()
{
    // Get the attribute field


    // Create a shared vector or reuse

    // Create an attribute for the Color Mode
    // name: ColorMode
    // value: variant union stores a PVInt with value 0
    // descriptor: "Color mode"
    // source: ""
    // sourceType = 0

    // Add the attribute to the shared_vector

    // Replace the attribute fields stored
}


void NTNDArrayRecord::setSizes(int64_t size)
{
    // Set the (long) compressedSize and uncompressedSize field

}

void NTNDArrayRecord::setUniqueId(int32_t id)
{
    pvStructure->getSubFieldT<PVInt>("uniqueId")->put(id);
    //ndarray->getUniqueId()->put(id);
}

void NTNDArrayRecord::setDataTimeStamp()
{
    // Create PVTimeStamp and TimeStamp objects
    // attach the dataTimeStamp field to the PVTimeStamp
    // TimeStamp object should get the current time
    // Use it to set the dataTimeStamp field

    // Alternatively you can use the member objects already created
    // for you and do the attaching once.
}

}}
