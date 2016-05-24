// Copyright information and license terms for this software can be
// found in the file LICENSE that is included with the distribution

#include <pv/pvData.h>
#include <pv/rpcService.h>
#include <pv/clientFactory.h>
#include <pv/rpcClient.h>

#include <string>
#include <iostream>

using namespace epics::pvData;


// Create the "data interface" required to send data to the maths service. That is,
// define the client side API of the maths service.
static StructureConstPtr makeRequestStructure()
{

}

// Set a pvAccess connection timeout, after which the client gives up trying 
// to connect to server.
const static double REQUEST_TIMEOUT = 3.0;


/**
 * The main establishes the connection to the mathsServer, constructs the
 * mechanism to pass parameters to the server, calls the server in the EV4
 * 2-step way, gets the response from the mathsServer, unpacks it, and
 * prints the results.
 * 
 * @param args - the two numbers to be inputted to the maths service.
  */
int main (int argc, char *argv[])
{
    // Start the pvAccess client side.
    epics::pvAccess::ClientFactory::start();

    try 
    {
        // Create the introspection object for the structure used
        // to send arguments to the server. 

        // Create the data object for the structure used
        // to send arguments to the server. 


        // Set the value of the data object.

        // Create an RPC client to the "mathsService" service
 
        // Create an RPC request and block until response is received. There is
        // no need to explicitly wait for connection; this method takes care of it.
        // In case of an error, an exception is thrown.


        // Extract the result using the introspection interface of the returned 
        // datum, 
 
        // Check the result conforms to expected format and if so print it.
     
    }
    catch (epics::pvAccess::RPCRequestException & ex)
    {
        // The client connected to the server, but the server request method issued its 
        // standard summary exception indicating it couldn't complete the requested task.
    }
    catch (...)
    {
        // Catch any other exceptions so we always call ClientFactory::stop().
    }

    // Stop pvAccess client, so that this application exits cleanly.
    epics::pvAccess::ClientFactory::stop();

    return 0;
}
