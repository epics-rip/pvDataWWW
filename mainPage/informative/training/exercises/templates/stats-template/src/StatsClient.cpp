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
    return StructureConstPtr();
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
    // create a shared vector of doubles and add the arguments

    // Start the pvAccess client side.
    epics::pvAccess::ClientFactory::start();

    try 
    {
        // Create the introspection object for the structure used
        // to send arguments to the server. 
        StructureConstPtr structure = makeRequestStructure();

        // Create the data object for the structure used
        // to send arguments to the server. 

        // Set the value of the data object.

        // Create an RPC client to the "statsService" service

        // Create an RPC request and block until response is received. There is
        // no need to explicitly wait for connection; this method takes care of it.
        // In case of an error, an exception is thrown.
 
        // Check for expected fields and print them.
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
