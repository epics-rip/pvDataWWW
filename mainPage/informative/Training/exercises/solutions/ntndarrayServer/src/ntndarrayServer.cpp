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

    pvDataTimeStamp.attach(pvStructure->getSubField<PVStructure>("dataTimeStamp"));
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
    PVUnionPtr value = pvStructure->getSubFieldT<PVUnion>("value");
    // Select the byteValue field stored in "value"
    PVByteArrayPtr byteValue = value->select<PVByteArray>("byteValue");
    // replace the shared vector with "bytes"
    byteValue->replace(bytes);
    // call postPut so that the union sees the change in the stored field  
    value->postPut();
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
        if (!d || !d.unique())
            d = dimVector[i] = getPVDataCreate()->createPVStructure(dimField->getStructureArray()->getStructure());
        d->getSubField<PVInt>("size")->put(dims[i]);
        d->getSubField<PVInt>("offset")->put(0);
        d->getSubField<PVInt>("fullSize")->put(dims[i]);
        d->getSubField<PVInt>("binning")->put(1);
        d->getSubField<PVBoolean>("reverse")->put(false);
    }
    // replace the dimensions field's shared_vector
    // (Remember to freeze first)
    dimField->replace(freeze(dimVector));
}

void NTNDArrayRecord::setAttributes()
{
    // Get the attribute field
    PVStructureArrayPtr attributeField = pvStructure->getSubField<PVStructureArray>("attribute");

    // Create a shared vector or reuse
    PVStructureArray::svector attributes(attributeField->reuse());
    attributes.reserve(1);

    // Create an attribute for the Color Mode
    // name: ColorMode
    // value: variant union stores a PVInt with value 0
    // descriptor: "Color mode"
    // source: ""
    // sourceType = 0
    PVStructurePtr attribute = getPVDataCreate()->createPVStructure(attributeField->getStructureArray()->getStructure());

    attribute->getSubField<PVString>("name")->put("ColorMode");
    PVInt::shared_pointer pvColorMode = getPVDataCreate()->createPVScalar<PVInt>();
    pvColorMode->put(0);

    attribute->getSubField<PVUnion>("value")->set(pvColorMode);
    attribute->getSubField<PVString>("descriptor")->put("Color mode");
    attribute->getSubField<PVInt>("sourceType")->put(0);
    attribute->getSubField<PVString>("source")->put("");

    // Add the attribute to the shared_vector
    attributes.push_back(attribute);

    // Replace the attribute fields stored
    attributeField->replace(freeze(attributes));
}


void NTNDArrayRecord::setSizes(int64_t size)
{
    // Set the (long) compressedSize and uncompressedSize field
    pvStructure->getSubFieldT<PVLong>("compressedSize")->put(size);    
    pvStructure->getSubFieldT<PVLong>("uncompressedSize")->put(size);
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
#if 0
    PVTimeStamp timeStamp;
    timeStamp.attach(pvStructure->getSubField<PVStructure>("dataTimeStamp"));
    TimeStamp current;
    current.getCurrent();
    timeStamp.set(current);
#else
    // Alternatively you can use the member objects already created
    // for you and do the attaching once.
    dataTimeStamp.getCurrent();
    pvDataTimeStamp.set(dataTimeStamp);
#endif
}

}}
