/* NTNDArrayServerMain.cpp */
/**
 * Copyright - See the COPYRIGHT that is included with this distribution.
 * EPICS pvData is distributed subject to a Software License Agreement found
 * in file LICENSE that is included with this distribution.
 */
/**
 * @author dgh
 * @date 2016.05.17
 */


#include <cstddef>
#include <cstdlib>
#include <cstddef>
#include <string>
#include <cstdio>
#include <memory>
#include <iostream>

#include <pv/standardField.h>
#include <pv/standardPVField.h>
#include <pv/ntndarrayServer.h>
#include <pv/traceRecord.h>
#include <pv/channelProviderLocal.h>
#include <pv/serverContext.h>

using namespace std;
using std::tr1::static_pointer_cast;
using namespace epics::pvData;
using namespace epics::pvAccess;
using namespace epics::pvDatabase;
using namespace epics::ntndarrayServer;

int main(int argc,char *argv[])
{
    PVDatabasePtr master = PVDatabase::getMaster();
    ChannelProviderLocalPtr channelProvider = getChannelProviderLocal();
    PVRecordPtr pvRecord;
    bool result(false);

    string recordName  = "testNDArray";
    if (argc > 1)
        recordName = argv[1];

    pvRecord = NTNDArrayRecord::create(recordName);
    result = master->addRecord(pvRecord);

    if (result)
        cout << "NTNDArrayRecord " << recordName << " added" << endl;
    else
    {
        cerr<< "record " << recordName << " not added" << endl;
        return 1;
    }

    ServerContext::shared_pointer pvaServer = 
        startPVAServer(PVACCESS_ALL_PROVIDERS,0,true,true);

    string str;
    while(true) {
        cout << "Type exit to stop: \n";
        getline(cin,str);
        if(str.compare("exit")==0) break;

    }

    pvaServer->shutdown();
    pvaServer->destroy();
    channelProvider->destroy();
    return 0;
}

