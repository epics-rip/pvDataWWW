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


package org.epics.trainingJava.ndarray;

import org.epics.nt.NTNDArray;
import org.epics.pvdata.factory.PVDataFactory;
import org.epics.pvdata.misc.RunnableReady;
import org.epics.pvdata.misc.ThreadCreate;
import org.epics.pvdata.misc.ThreadCreateFactory;
import org.epics.pvdata.misc.ThreadPriority;
import org.epics.pvdata.misc.ThreadReady;
import org.epics.pvdata.pv.PVBoolean;
import org.epics.pvdata.pv.PVUByteArray;
import org.epics.pvdata.pv.PVDataCreate;
import org.epics.pvdata.pv.PVInt;
import org.epics.pvdata.pv.PVLong;
import org.epics.pvdata.pv.PVString;
import org.epics.pvdata.pv.PVStructure;
import org.epics.pvdata.pv.PVStructureArray;
import org.epics.pvdata.pv.PVUnion;
import org.epics.pvdata.pv.ScalarType;
import org.epics.pvdata.property.PVTimeStamp;
import org.epics.pvdata.property.PVTimeStampFactory;
import org.epics.pvdata.property.TimeStamp;
import org.epics.pvdata.property.TimeStampFactory;
import org.epics.pvdatabase.PVRecord;


//#include "image.h"


/**
 * NTNDArrayRecord.
 * 
 */
public class NTNDArrayRecord extends PVRecord implements RunnableReady
{
    public static NTNDArrayRecord create(
        String recordName)
    {
        PVStructure pvStructure = NTNDArray.createBuilder().
            addTimeStamp().createPVStructure();

        NTNDArrayRecord pvRecord = new NTNDArrayRecord(recordName,pvStructure);

        if(!pvRecord.init()) pvRecord = null;

        return pvRecord;
    }

    public void destroy()
    {

    }

    public boolean init()
    {
        threadCreate.create("device",ThreadPriority.getJavaPriority(ThreadPriority.middle), this);
        return true;
    }

    public void run(ThreadReady threadReady)
    {
        threadReady.ready();
        while (true)
        {
            try {
                Thread.sleep(100);
                update();
            }
            catch (Throwable t)
            {
                System.err.println(t.getMessage());
            } 
        }
    }

    public void update()
    {
        lock();
        try
        {
            beginGroupPut();
            byte[] bytes = imageGen.getBytes(angle);
            setValue(bytes);
            if (firstTime)
            {
                setDimension(imageGen.getDims());
                setAttributes();
                setSizes(imageGen.getSize());
                firstTime = false;
            }
            setDataTimeStamp();
            setUniqueId(count++);
            process();
            endGroupPut();
        }
        catch (Throwable t)
        {
            unlock();
            throw t;
        }
        angle += 1;
        unlock();
    }

    private NTNDArrayRecord(String recordName,
        PVStructure pvStructure)
    {
        super(recordName, pvStructure);
        this.pvStructure = pvStructure;
        ndarray = NTNDArray.wrap(pvStructure);
        ndarray.attachTimeStamp(pvDataTimeStamp);
    }

    private void setValue(byte[] bytes)
    {
        // Get the union value field

        // Select the byteValue field stored in "value"

        // replace the shared vector with "bytes"

        // call postPut so that the union sees the change in the stored field  
    }

    private void setDimension(int[] dims)
    {
        // Get the dimension field
        PVStructureArray dimField = pvStructure.getSubField(PVStructureArray.class, "dimension");

        int ndims = dims.length;
        PVStructure[] dimArray = new PVStructure[ndims];

        // Iterate over the number of dimensions, creating and adding the
        // appropriate dimension structures.
        for (int i = 0; i < ndims; ++i)
        {
            dimArray[i] = pvDataCreate.createPVStructure(dimField.
                    getStructureArray().getStructure());
            PVStructure d = dimArray[i];

            // Fill in the dimensions
            // (Hint: size/fullSize is the supplied dimension, offset = 0
            // binning is 1 and reverse is false.)
        }

        dimField.put(0, dimArray.length, dimArray, 0);
    }

    private void setAttributes()
    {
        // Get the attribute field

        // Create an attribute for the Color Mode
        // name: ColorMode
        // value: variant union stores a PVInt with value 0
        // descriptor: "Color mode"
        // source: ""
        // sourceType = 0


        // Create an array


        // Put to attribute field
    }

    private void setSizes(long size)
    {
        // Set the (long) compressedSize and uncompressedSize field
    }

    private void setUniqueId(int id)
    {
        pvStructure.getSubField(PVInt.class, "uniqueId").put(id);    
    }

    private void setDataTimeStamp()
    {
    }

    private static final PVDataCreate pvDataCreate = 
            PVDataFactory.getPVDataCreate();

    private PVStructure pvStructure;
    NTNDArray ndarray;
    //Image image = new Image("data/epicsv4Grayscale.data");
    //Image image = new Image("data/testImage_small.data");
    //Image image = new Image("data/ess.data");
    Image image = new Image("data/testImage_large.data");
    RotatingImageGenerator imageGen = RotatingImageGenerator.create(
        image.getBytes(), image.width, image.height);

    private PVTimeStamp pvDataTimeStamp = PVTimeStampFactory.create();
    private TimeStamp dataTimeStamp = TimeStampFactory.create();

    private int count;
    private boolean firstTime = true;
    private double angle;

    private static ThreadCreate threadCreate = ThreadCreateFactory.getThreadCreate();
}



