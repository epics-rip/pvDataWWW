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


// Create the "data interface" required to send data to the stats service. 
// That is, define the client side API of the stats service.
static StructureConstPtr makeRequestStructure()
{
    return getFieldCreate()->createFieldBuilder()->
       setId("epics:nt/NTScalarArray:1.0")->
       addArray("value", pvDouble)->
       createStructure();
}

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
        // Create the introspection object for the structure used
        // to send arguments to the server. 
        StructureConstPtr structure = makeRequestStructure();

        // Create the data object for the structure used
        // to send arguments to the server. 
        PVStructurePtr arguments(getPVDataCreate()->createPVStructure(structure));

        // Set the value of the data object.
	    arguments->getSubFieldT<PVDoubleArray>("value")->replace(freeze(vals));

        // Create an RPC client to the "statsService" service
        epics::pvAccess::RPCClient::shared_pointer client
             = epics::pvAccess::RPCClient::create("statsService"); 

        // Create an RPC request and block until response is received. There is
        // no need to explicitly wait for connection; this method takes care of it.
        // In case of an error, an exception is thrown.
        PVStructurePtr response = client->request(arguments, REQUEST_TIMEOUT);
 
        // Check for expected fields and print them.

        PVDoublePtr sumField = response->getSubField<PVDouble>("value");
        if (sumField)
        {
            std::cout << "value: " << sumField->get() << std::endl;
        }

        PVLongPtr nField = response->getSubField<PVLong>("N");
        if (nField)
        {
            std::cout << "N:     " << nField->get() << std::endl;
        }

        PVDoublePtr dispField = response->getSubField<PVDouble>("dispersion");
        if (dispField)
        {
            std::cout << "disp:  " << dispField->get() << std::endl;
        }

        PVDoublePtr maxField = response->getSubField<PVDouble>("max");
        if (maxField)
        {
            std::cout << "max:   " << maxField->get() << std::endl;
        }

        PVDoublePtr minField = response->getSubField<PVDouble>("min");
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
