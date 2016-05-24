/* ntndarrayServer.h */
/**
 * Copyright - See the COPYRIGHT that is included with this distribution.
 * EPICS pvData is distributed subject to a Software License Agreement found
 * in file LICENSE that is included with this distribution.
 */
/**
 * @author dgh
 * @date 2016.05.17
 */
#ifndef NTNDARRAYSERVER_H
#define NTNDARRAYSERVER_H


#include <pv/pvDatabase.h>
#include <pv/ntndarray.h>
#include <pv/timeStamp.h>
#include <pv/pvTimeStamp.h>
#include <epicsThread.h>
#include <string>

#include "image.h"

namespace epics { namespace ntndarrayServer { 


class NTNDArrayRecord;
typedef std::tr1::shared_ptr<NTNDArrayRecord> NTNDArrayRecordPtr;

class NTNDArrayRecordThread;
typedef std::tr1::shared_ptr<NTNDArrayRecordThread> NTNDArrayRecordThreadPtr;


class NTNDArrayRecord :
    public epics::pvDatabase::PVRecord
{
public:
    POINTER_DEFINITIONS(NTNDArrayRecord);
    static NTNDArrayRecordPtr create(
        std::string const & recordName);
    virtual ~NTNDArrayRecord();
    virtual void destroy();
    virtual bool init();
    void update();

private:
    NTNDArrayRecord(std::string const & recordName,
        epics::pvData::PVStructurePtr const & pvStructure);
    NTNDArrayRecordThreadPtr ntndarrayServerThread;

    void setValue(epics::pvData::PVByteArray::const_svector const & bytes);
    void setDimension(const int32_t * dims, size_t ndims);
    void setAttributes();
    void setSizes(int64_t size);
    void setUniqueId(int32_t id);
    void setDataTimeStamp();

    epics::pvData::PVStructurePtr pvStructure;
    epics::nt::NTNDArrayPtr ndarray;
    RotatingImageGeneratorPtr imageGen;

    epics::pvData::PVTimeStamp pvDataTimeStamp;
    epics::pvData::TimeStamp dataTimeStamp;

    int8_t count;
    bool firstTime;
    double angle;
};


class NTNDArrayRecordThread :
   public epicsThreadRunable
{
public:
    POINTER_DEFINITIONS(NTNDArrayRecord);
    NTNDArrayRecordThread(NTNDArrayRecordPtr const &  ntndarrayServer);
    virtual ~NTNDArrayRecordThread(){};
    void init();
    void start();
    virtual void run();
    void destroy();
private:
    NTNDArrayRecordPtr ntndarrayServer;
    bool isDestroyed;
    bool runReturned;
    std::string threadName;
    epics::pvData::Mutex mutex;
    std::auto_ptr<epicsThread> thread;
    double timeOut;
};

}}

#endif  /* NTNDARRAYSERVER_H */
