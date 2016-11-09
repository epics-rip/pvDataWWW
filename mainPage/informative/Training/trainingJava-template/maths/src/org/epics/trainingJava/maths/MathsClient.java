/*
 * Copyright information and license terms for this software can be
 * found in the file LICENSE that is included with the distribution
 */

package org.epics.trainingJava.maths;
/**
 * MathsClient is a simple example of an EPIVS V4 client, demonstrating support for a
 * a client/server environment using the ChannelRPC channel type of EPICS V4.  
 */

import org.epics.pvaccess.client.rpc.RPCClientImpl;
import org.epics.pvaccess.server.rpc.RPCRequestException;
import org.epics.pvdata.factory.FieldFactory;
import org.epics.pvdata.factory.PVDataFactory;
import org.epics.pvdata.pv.Field;
import org.epics.pvdata.pv.FieldCreate;
import org.epics.pvdata.pv.PVDouble;
import org.epics.pvdata.pv.PVString;
import org.epics.pvdata.pv.PVStructure;
import org.epics.pvdata.pv.ScalarType;
import org.epics.pvdata.pv.Status.StatusType;
import org.epics.pvdata.pv.Structure;

/**
 * MathsClient is an example of a simple EPICS V4 Remote Procedure Call (RPC) client
 * 
 */
public class MathsClient
{
    private final static FieldCreate fieldCreate = FieldFactory.getFieldCreate();

    // Create the introspection object for the structure used
    // to send arguments to the server.


    // Set a pvAccess connection timeout, after which the client gives up trying 
    // to connect to server.
    private final static double REQUEST_TIMEOUT = 3.0;

    /**
     * The main establishes the connection to the mathsServer, constructs the
     * mechanism to pass parameters to the server, calls the server in the EV4
     * 2-step way, gets the response from the mathsServer, unpacks it, and
     * prints the greeting.
     * 
     * @param args - the two numbers to add
     */
    public static void main(String[] args) 
    {
        // Start the pvAccess client-side.
        org.epics.pvaccess.ClientFactory.start();

        try
        {
            // Create an RPC client to the "mathsService" service

            // Create the data object for the structure used
            // to send arguments to the server. 

            // Set the value of the data object.

            try
            {
                // Remove this - it's here so it builds out the box
                throw new RPCRequestException(StatusType.ERROR,             
                     "NotImplemented");

                // Create an RPC request and block until response is received. There is
                // no need to explicitly wait for connection; this method takes care of it.
                // In case of an error, an exception is throw.

                // Extract the sum from the
 
                // Check the result conforms to expected format and if so print it. 
            }
            catch (RPCRequestException ex)
            {
                // The client connected to the server, but the server request method issued its 
                // standard summary exception indicating it couldn't complete the requested task.
                System.err.println("Maths service was not successful. RPCException: " + ex.getMessage());
            }
            catch (IllegalStateException ex)
            {
                // The client failed to connect to the server. The server isn't running or
                // some other network related error occurred.
            }
            catch (Throwable ex)
            {
                // The client failed to connect to the server. The server isn't running or
                // some other network related error occurred.
            }

            // Disconnect from the service client.
            // client.destroy();
        }
        finally
        {
            // Stop pvAccess client, so that this application exits cleanly.
            org.epics.pvaccess.ClientFactory.stop();
        }
    }
}
