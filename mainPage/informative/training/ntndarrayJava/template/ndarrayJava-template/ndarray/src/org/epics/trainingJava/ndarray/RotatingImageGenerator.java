/* image.h */
/**
 * Copyright - See the COPYRIGHT that is included with this distribution.
 * EPICS pvData is distributed subject to a Software License Agreement found
 * in file LICENSE that is included with this distribution.
 */
/**
 * @author dgh
 * @date 2016.09.27
 */

package org.epics.trainingJava.ndarray;

public class RotatingImageGenerator
{
    private byte[] m_data;
    private int m_width;
    private int m_height;
    private int m_size;
    public static RotatingImageGenerator create(byte[] data, int width, int height)
    {
        return new RotatingImageGenerator(data, width, height);
    }

    public int getSize()
    {
        return m_size;
    }

    public int[] getDims()
    {
        int[] dims = { m_width, m_height };
        return dims;
    }

    private RotatingImageGenerator(byte[] data, int width, int height)
    {
        m_data = data;
        m_width = width;
        m_height = height;
        m_size = width * height;   
    }

    byte[] getBytes(double deg)
    {
        byte[] img = new byte[m_size];


        int cols = m_width;
        int rows = m_height;

        double fi = 3.141592653589793238462 * deg / 180.0;
        double cosFi = 16.0 * Math.cos(fi);
        double sinFi = 16.0 * Math.sin(fi);

        int cx = cols/2;
        int cy = rows/2;

        int colsm2 = cols-2;
        int rowsm2 = rows-2;

        for (int y = 0; y < rows; y++)
        {
            int lineOffset = y*cols;
            int dcy = y - cy;
            for (int x = 0; x < cols; x++)
            {
                int dcx = x - cx;

                int tnx = (int)(cosFi*dcx + sinFi*dcy);
                int tny = (int)(-sinFi*dcx + cosFi*dcy);

                int nx = (tnx >> 4) + cx;
                int ny = (tny >> 4) + cy;

                if (nx < 0 || ny < 0 || nx > colsm2 || ny > rowsm2)
                {
                    img[lineOffset + x] = (byte)0;
                }
                else
                {
                    int srcOffset = ny*cols;
                    int xf = tnx & 0x0F;
                    int yf = tny & 0x0F;

                    int v00 = (16 - xf) * (16 - yf) * (m_data[srcOffset + nx] + 128);
                    int v10 = xf * (16 - yf) * (m_data[srcOffset + nx +1] + 128);
                    int v01 = (16 - xf) * yf * (m_data[srcOffset + cols + nx] + 128);
                    int v11 = xf * yf * (m_data[srcOffset + cols + nx + 1] + 128);
                    int val = ((v00 + v01 + v10 + v11 + 128) / 256) & 0xFF;
                    img[lineOffset + x] = (byte)(val - 128);
                }
            }
        }

        return img;
    }

};

