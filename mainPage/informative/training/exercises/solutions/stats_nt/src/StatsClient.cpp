// Copyright information and license terms for this software can be
// found in the file LICENSE that is included with the distribution

#include <pv/pvData.h>
#include <pv/rpcService.h>
#include <pv/clientFactory.h>
#include <pv/rpcClient.h>
#include <pv/ntscalarArray.h>
#include <pv/ntaggregate.h>

#include <string>
#include <iostream>

using namespace epics::pvData;


// Set a pvAccess connection timeout, after which the client gives up trying 
// to connect to server.
const static double REQUEST_TIMEOUT = 3.0;


/**
 * The main establishes the connection to the statsServer, constructs the
 * mechanism to pass parameters to the server, calls the server in the EV4
 * 2-step way, gets the response from the statsServer, unpacks it, and
 * prints the results.
 * 
 * @param args - the numbers to be inputted to the stats service.
  */
int main (int argc, char *argv[])
{
    PVDoubleArray::svector vals;
    vals.reserve(argc);

    for (int i = 1; i < argc; ++i)
        vals.push_back(atof(argv[i]));

    // Start the pvAccess client side.
    epics::pvAccess::ClientFactory::start();

    try 
    {
        epics::nt::NTScalarArrayPtr ntscalarArray =
            epics::nt::NTScalarArray::createBuilder()->
            value(pvDouble)->
            create();

        // Set the value of the data object.
	    ntscalarArray->getValue<PVDoubleArray>()->replace(freeze(vals));

        // Create an RPC client to the "statsService" service
        epics::pvAccess::RPCClient::shared_pointer client
             = epics::pvAccess::RPCClient::create("statsService"); 

        // Create an RPC request and block until response is received. There is
        // no need to explicitly wait for connection; this method takes care of it.
        // In case of an error, an exception is thrown.
        PVStructurePtr response = client->request(
            ntscalarArray->getPVStructure(), REQUEST_TIMEOUT);
 
        // Check for expected fields and print them.

        epics::nt::NTAggregatePtr ntaggregate = epics::nt::NTAggregate::wrapUnsafe(response);

        PVDoublePtr sumField = ntaggregate->getValue();
        if (sumField)
        {
            std::cout << "value: " << sumField->get() << std::endl;
        }

        PVLongPtr nField = ntaggregate->getN();
        if (nField)
        {
            std::cout << "N:     " << nField->get() << std::endl;
        }

        PVDoublePtr dispField = ntaggregate->getDispersion();
        if (dispField)
        {
            std::cout << "disp:  " << dispField->get() << std::endl;
        }

        PVDoublePtr maxField = ntaggregate->getMax();
        if (maxField)
        {
            std::cout << "max:   " << maxField->get() << std::endl;
        }

        PVDoublePtr minField = ntaggregate->getMin();
        if (minField)
        {
            std::cout << "min:   " << minField->get() << std::endl;
        }

    }
    catch (epics::pvAccess::RPCRequestException & ex)
    {
        // The client connected to the server, but the server request method issued its 
        // standard summary exception indicating it couldn't complete the requested task.
        std::cerr << "Stats service was not successful. RPCException:" << std::endl;
        std::cerr << ex.what() << std::endl;
    }
    catch (...)
    {
        // Catch any other exceptions so we always call ClientFactory::stop().
        std::cerr << "Stats service was not successful. Unexpected exception." << std::endl;
    }
    // Stop pvAccess client, so that this application exits cleanly.
    epics::pvAccess::ClientFactory::stop();

    return 0;
}
