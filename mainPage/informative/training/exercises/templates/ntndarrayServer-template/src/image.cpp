/* image.cpp */
/**
 * Copyright - See the COPYRIGHT that is included with this distribution.
 * EPICS pvData is distributed subject to a Software License Agreement found
 * in file LICENSE that is included with this distribution.
 */
/**
 * @author dgh
 * @author mse
 * @date 2016.05.17
 */


#include <pv/pvData.h>
#include <cmath>
#include <fstream>

#include "image.h"

using namespace epics::pvData;

namespace epics { namespace ntndarrayServer { 

RotatingImageGeneratorPtr RotatingImageGenerator::create(const uint8_t* data, size_t width, size_t height)
{
    return RotatingImageGeneratorPtr(new RotatingImageGenerator(data,
        width, height));
}

RotatingImageGeneratorPtr RotatingImageGenerator::create(const std::string & filename)
{
    std::vector<uint8_t> tmp;
    std::ifstream ifs;

    ifs.open(filename.c_str());

    size_t width;
    ifs >> width;
    size_t height;
    ifs >> height;

    size_t size = width * height;
    tmp.reserve(size);

    size_t value;
    for (size_t i = 0; i < size; ++i)
    {
        ifs >> std::hex >> value;
        tmp.push_back(static_cast<uint8_t>(value));
    }

    return RotatingImageGeneratorPtr(new RotatingImageGenerator(&tmp[0],
        width, height));
}

RotatingImageGenerator::RotatingImageGenerator(const uint8_t* data, size_t width, size_t height)
: m_width(width), m_height(height), m_size(width*height)
{
    bytes.reserve(m_size);
    for (const uint8_t* p = data; p != data + m_size; ++p)
        bytes.push_back(*p);

    m_data = &bytes[0];
}


void RotatingImageGenerator::fillSharedVector(PVUByteArray::svector & sv, float deg)
{
    int32 cols = m_width;
    int32 rows = m_height;

    double fi = 3.141592653589793238462 * deg / 180.0;
    double cosFi = 16.0 * cos(fi);
    double sinFi = 16.0 * sin(fi);

    int32 cx = cols/2;
    int32 cy = rows/2;

    int32 colsm2 = cols-2;
    int32 rowsm2 = rows-2;

    sv.resize(m_size);
    uint8_t* img = sv.data();

    for (int32 y = 0; y < rows; y++)
    {
        uint8_t* imgline = img + y*cols;
        int32 dcy = y - cy;
        for (int32 x = 0; x < cols; x++)
        {
            int32 dcx = x - cx;

            int32 tnx = static_cast<int32>(cosFi*dcx + sinFi*dcy);
            int32 tny = static_cast<int32>(-sinFi*dcx + cosFi*dcy);

            int32 nx = (tnx >> 4) + cx;
            int32 ny = (tny >> 4) + cy;

            if (nx < 0 || ny < 0 || nx > colsm2 || ny > rowsm2)
            {
                imgline[x] = 0;
            }
            else
            {
                const uint8_t* srcline = m_data + ny*cols;

                int32 xf = tnx & 0x0F;
                int32 yf = tny & 0x0F;

                int32 v00 = (16 - xf) * (16 - yf) * (srcline[nx]);
                int32 v10 = xf * (16 - yf) * (srcline[nx + 1]);
                int32 v01 = (16 - xf) * yf * (srcline[cols + nx]);
                int32 v11 = xf * yf * (srcline[cols + nx + 1]);
                uint8_t val = static_cast<uint8_t>((v00 + v01 + v10 + v11) / 256);
                imgline[x] = val;

            }
        }
    }
}

}}


