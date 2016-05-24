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


namespace epics { namespace ntndarrayServer { 
using namespace epics::pvData;
using namespace epics::pvDatabase;
using std::string;


NTNDArrayRecordThread::NTNDArrayRecordThread(NTNDArrayRecordPtr const & ntndarrayServer)
: 
  ntndarrayServer(ntndarrayServer),
  isDestroyed(false),
  runReturned(false),
  threadName("ntndarrayServer"),
  timeOut(0.1)
{
}

void NTNDArrayRecordThread::init()
{
     thread = std::auto_ptr<epicsThread>(new epicsThread(
        *this,
        threadName.c_str(),
        epicsThreadGetStackSize(epicsThreadStackSmall),
        epicsThreadPriorityHigh));
}


void NTNDArrayRecordThread::run()
{
    while (true)
    {
        epicsThreadSleep(timeOut);
        ntndarrayServer->update();
    }
}


void NTNDArrayRecordThread::start()
{
    thread->start();
}

void NTNDArrayRecordThread::destroy()
{
    Lock lock(mutex);
    if(isDestroyed) return;
    isDestroyed = true;
    while(true) {
        if(runReturned) break;
        lock.unlock();
        epicsThreadSleep(.01);
        lock.lock();
    }
    thread->exitWait();
    thread.reset();
    ntndarrayServer.reset();
}

}}
