//
//  NuoModelBase.cpp
//  ModelViewer
//
//  Created by middleware on 8/28/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#include "NuoModelBase.h"



const std::string kNuoModelType_Simple = "model_simple";



std::shared_ptr<NuoModelBase> CreateModel(std::string type)
{
    if (type == kNuoModelType_Simple)
        return std::make_shared<NuoModelSimple>();
    else
        return std::shared_ptr<NuoModelBase>();
}



void* NuoModelBase::IndicesPtr()
{
    return _indices.data();
}



NuoBox NuoModelBase::GetBoundingBox()
{
    float xMin = 1e9f, xMax = -1e9f;
    float yMin = 1e9f, yMax = -1e9f;
    float zMin = 1e9f, zMax = -1e9f;
    
    for (size_t i = 0; i < GetVerticesNumber(); ++i)
    {
        vector_float4 position = GetPosition(i);
        
        xMin = std::min(xMin, position.x);
        xMax = std::max(xMax, position.x);
        yMin = std::min(yMin, position.y);
        yMax = std::max(yMax, position.y);
        zMin = std::min(zMin, position.z);
        zMax = std::max(zMax, position.z);
    }
    
    return NuoBox { (xMax - xMin) / 2.0f, (yMax - yMin) / 2.0f, (zMax - zMin) / 2.0f,
                    xMax - xMin, yMax - yMin, zMax - zMin };
}



NuoModelSimple::NuoModelSimple()
{
}



bool NuoModelSimple::Item::operator == (const Item& i2)
{
    return
        (_position.x == i2._position.x) &&
        (_position.y == i2._position.y) &&
        (_position.z == i2._position.z) &&
        (_normal.x == i2._normal.x);
        (_normal.y == i2._normal.y);
        (_normal.z == i2._normal.z);
}



void NuoModelSimple::GenerateIndices()
{
    std::vector<Item> compactBuffer;
    size_t checkBackward = 100;
    uint32_t indexCurrent = 0;
    
    _indices.clear();
    
    for (size_t i = 0; i < _buffer.size(); ++i)
    {
        const Item& item = _buffer[i];
        
        if (item._normal.x != 0.0f && item._normal.y != 0.0f && item._normal.z != 0.0f)
        {
            auto search = std::find((compactBuffer.size() < checkBackward ? compactBuffer.begin() : compactBuffer.end() - checkBackward),
                                    compactBuffer.end(), item);
            if (search != std::end(compactBuffer))
            {
                uint32_t indexExist = (uint32_t)(search - std::begin(compactBuffer));
                _indices.push_back(indexExist);
            }
            else
            {
                compactBuffer.push_back(item);
                _indices.push_back(indexCurrent++);
            }
        }
        else
        {
            compactBuffer.push_back(item);
            _indices.push_back(indexCurrent++);
        }
    }
    
    _buffer.swap(compactBuffer);
}



void NuoModelSimple::AddPosition(size_t sourceIndex, const std::vector<float>& positionsBuffer)
{
    size_t sourceOffset = sourceIndex * 3;
    
    Item newItem;
    
    newItem._position.x = positionsBuffer[sourceOffset];
    newItem._position.y = positionsBuffer[sourceOffset + 1];
    newItem._position.z = positionsBuffer[sourceOffset + 2];
    newItem._position.w = 1.0f;
    
    _buffer.push_back(newItem);
}


void NuoModelSimple::AddNormal(size_t sourceIndex, const std::vector<float>& normalBuffer)
{
    size_t sourceOffset = sourceIndex * 3;
    size_t targetOffset = _buffer.size();
    
    _buffer[targetOffset]._normal.x = normalBuffer[sourceOffset];
    _buffer[targetOffset]._normal.y = normalBuffer[sourceOffset + 1];
    _buffer[targetOffset]._normal.z = normalBuffer[sourceOffset + 2];
    _buffer[targetOffset]._normal.w = 0.0f;
}



size_t NuoModelSimple::GetVerticesNumber()
{
    return _buffer.size();
}



vector_float4 NuoModelSimple::GetPosition(size_t index)
{
    return _buffer[index]._position;
}



void* NuoModelSimple::Ptr()
{
    return (void*)_buffer.data();
}
