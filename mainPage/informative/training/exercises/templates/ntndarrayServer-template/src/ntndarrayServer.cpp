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



using namespace epics::pvData;
using namespace epics::pvDatabase;
using namespace epics::nt;
using std::tr1::static_pointer_cast;
using std::tr1::dynamic_pointer_cast;
using std::string;

namespace epics { namespace ntndarrayServer { 

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

    //imageGen = RotatingImageGenerator::create("data/epicsv4Grayscale.data");
    //imageGen = RotatingImageGenerator::create("data/testImage_small.data");
    imageGen = RotatingImageGenerator::create("data/testImage_large.data");
    //imageGen = RotatingImageGenerator::create("data/ess.data");
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
        PVUByteArray::svector bytes;
        imageGen->fillSharedVector(bytes,angle);
        setValue(freeze(bytes));
        if (firstTime)
        {
            int dims[] = { imageGen->getWidth(), imageGen->getHeight() };
            setDimension(dims, 2);
            setAttributes();
            setSizes(static_cast<int64_t>(imageGen->getSize()));
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

void NTNDArrayRecord::setValue(PVUByteArray::const_svector const & bytes)
{
    // Get the union value field

    // Select the byteValue field stored in "value"

    // replace the shared vector with "bytes"

    // call postPut so that the union sees the change in the stored field  

}

void NTNDArrayRecord::setDimension(const int32_t * dims, size_t ndims)
{
    // Get the dimension field
    PVStructureArrayPtr dimField = pvStructure->getSubField<PVStructureArray>("dimension");

    // create a shared_vector or try to reuse the dimension field's one  
    PVStructureArray::svector dimVector(dimField->reuse());
    // resize/reserve the number of elements
    dimVector.resize(ndims);

    // Iterate over the number of dimensions, creating and adding the
    // appropriate dimension structures.
    for (size_t i = 0; i < ndims; i++)
    {
        PVStructurePtr d = dimVector[i];
        // If d is null or not unique create a new PVStructure
        if (!d || !d.unique())
            d = dimVector[i] = getPVDataCreate()->createPVStructure(dimField->getStructureArray()->getStructure());
        // Set the size, offset, fullSize, binning and reverse fields
        // (binning should be 1)
    }
    // replace the dimensions field's shared_vector
    // (Remember to freeze first)
    dimField->replace(freeze(dimVector));
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

    // Replace the attribute field's shared vector
    // (Remember to freeze first)
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
