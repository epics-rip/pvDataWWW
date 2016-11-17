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

#if 0
    factory = getFieldCreate();

    FieldConstPtrArray fields;
    StringArray names;

    names.push_back("a");
    fields.push_back(factory->createScalar(pvString));

    names.push_back("b");
    fields.push_back(factory->createScalar(pvString));

    return factory->createStructure(names, fields);
#else
    return getFieldCreate()->createFieldBuilder()->
       add("a", pvString)->
       add("b", pvString)->
       createStructure();
#endif
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
    std::string a = (argc > 1) ? argv[1] : "0";
    std::string b = (argc > 2) ? argv[2] : "0";

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
	    arguments->getSubField<PVString>("a")->put(a);
	    arguments->getSubField<PVString>("b")->put(b);

        // Create an RPC client to the "mathsService" service
        epics::pvAccess::RPCClient::shared_pointer client
             = epics::pvAccess::RPCClient::create("mathsService"); 

        // Create an RPC request and block until response is received. There is
        // no need to explicitly wait for connection; this method takes care of it.
        // In case of an error, an exception is thrown.
        PVStructurePtr response = client->request(arguments, REQUEST_TIMEOUT);

        // Extract the result using the introspection interface of the returned 
        // datum, 
        PVDoublePtr sumField = response->getSubField<PVDouble>("sum");
 
        // Check the result conforms to expected format and if so print it.
        if (!sumField)
        {
            std::cerr << "Maths service was not successful. Expected PVDouble sum field" << std::endl;
        }
        else
        {
            std::cout << sumField->get() << std::endl;
        }         
    }
    catch (epics::pvAccess::RPCRequestException & ex)
    {
        // The client connected to the server, but the server request method issued its 
        // standard summary exception indicating it couldn't complete the requested task.
        std::cerr << "Maths service was not successful. RPCException:" << std::endl;
        std::cerr << ex.what() << std::endl;
    }
    catch (...)
    {
        // Catch any other exceptions so we always call ClientFactory::stop().
        std::cerr << "Maths service was not successful. Unexpected exception." << std::endl;
    }
    // Stop pvAccess client, so that this application exits cleanly.
    epics::pvAccess::ClientFactory::stop();

    return 0;
}
