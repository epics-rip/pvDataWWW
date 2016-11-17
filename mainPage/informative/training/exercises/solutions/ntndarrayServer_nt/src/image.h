/* image.h */
/**
 * Copyright - See the COPYRIGHT that is included with this distribution.
 * EPICS pvData is distributed subject to a Software License Agreement found
 * in file LICENSE that is included with this distribution.
 */
/**
 * @author dgh
 * @date 2016.05.17
 */


#include <pv/pvData.h>
#include <cmath>



namespace epics { namespace ntndarrayServer { 


class RotatingImageGenerator
{
public:
    POINTER_DEFINITIONS(RotatingImageGenerator);
    static RotatingImageGenerator::shared_pointer create(const uint8_t* data, size_t width, size_t height);

    static RotatingImageGenerator::shared_pointer create(const std::string & filename);

    size_t getWidth() { return m_width; }
    size_t getHeight() { return m_height; }
    size_t getSize() { return m_size; }

    void fillSharedVector(epics::pvData::PVUByteArray::svector & sv, float deg);

private:
    RotatingImageGenerator(const uint8_t* data, size_t width, size_t height);

    const uint8_t* m_data;
    size_t m_width;
    size_t m_height;
    size_t m_size;

    std::vector<uint8_t> bytes;
};

typedef RotatingImageGenerator::shared_pointer RotatingImageGeneratorPtr;

}}
