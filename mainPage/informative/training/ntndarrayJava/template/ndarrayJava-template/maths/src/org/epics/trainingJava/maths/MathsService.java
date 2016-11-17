/*
 * Copyright information and license terms for this software can be
 * found in the file LICENSE that is included with the distribution
 */

package org.epics.trainingJava.maths;

import org.epics.pvaccess.PVAException;
import org.epics.pvaccess.server.rpc.RPCRequestException;
import org.epics.pvaccess.server.rpc.RPCServer;
import org.epics.pvaccess.server.rpc.RPCService;
import org.epics.pvdata.factory.FieldFactory;
import org.epics.pvdata.factory.PVDataFactory;
import org.epics.pvdata.pv.Field;
import org.epics.pvdata.pv.FieldCreate;
import org.epics.pvdata.pv.PVDataCreate;
import org.epics.pvdata.pv.PVDouble;
import org.epics.pvdata.pv.PVString;
import org.epics.pvdata.pv.PVStructure;
import org.epics.pvdata.pv.ScalarType;
import org.epics.pvdata.pv.Status.StatusType;
import org.epics.pvdata.pv.Structure;

/**
 * MathsService is an example of a simple EPICS V4 Remote Procedure Call (RPC) service.
 * 
 */
public class MathsService
{
    private static final PVDataCreate pvDataCreate = 
            PVDataFactory.getPVDataCreate();
    private static final FieldCreate fieldCreate = 
            FieldFactory.getFieldCreate();

    // This service result structure type definition.

    /**
     * Implementation of RPC service.
     */
    static class MathsServiceImpl implements RPCService
    {
        public PVStructure request(PVStructure args) throws RPCRequestException
        {
            // Extract the two arguments.
            // Report an error by throwing a RPCRequestException


            // Create the result structure of the data interface.

            // Fill in the value of the structure's sum field


            // return the structure. Replace null with result
            return null;
        }
    }

    /**
     * Main is the entry point of the MathsService server side executable. 
     * @param args None
     */
    public static void main(String[] args) 
    {
        RPCServer server = new RPCServer();
        // register our service as "mathsService"
        server.registerService("mathsService", new MathsServiceImpl());
        server.printInfo();
        try {
            server.run(0);
        } catch (PVAException e) {
            System.err.println(e.getMessage());
            System.exit(1);
        }
    }
}
