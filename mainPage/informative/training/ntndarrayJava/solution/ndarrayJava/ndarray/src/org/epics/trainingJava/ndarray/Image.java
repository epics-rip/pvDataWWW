
package org.epics.trainingJava.ndarray;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;

public class Image
{
    int width;
    int height;
    int size;
    byte[] data;

    public Image(String fileName)
    {
        load(fileName);
    }

    public Image(byte[] data, int width, int height)
    {
        this.width = width;
        this.height = height;
        this.size = width * height;
        this.data = data;
    }

    public byte[] getBytes()
    {
        return data;
    }

    public int[] getDims()
    {
        int[] dims = { height, width };
        return dims;
    }

    public int getSize()
    {
        return size;
    }

    void load(String fileName)
    {
        try {

            BufferedReader br = new BufferedReader(new InputStreamReader(
                new FileInputStream(fileName)));

            String line = br.readLine();
            String[] dimStrings = line.split("\\s");

            width  = Integer.parseInt(dimStrings[0], 10);
            height = Integer.parseInt(dimStrings[1], 10);

            size = width * height;

            data = new byte[size];
            int i = 0;

            while ((line = br.readLine()) != null)
            {
                String[] hexStrings = line.split("\\s");

                for (String hexString : hexStrings)
                {
                    if (!hexString.isEmpty())
                    {
                        int val = Integer.parseInt(hexString, 16);
                        data[i++] = (byte)val;
                    }
                }
            }
        }
        catch (Throwable t)
        {
            System.err.println(t);
        }
    }
}

