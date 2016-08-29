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



NuoModelSimple::NuoModelSimple()
{
}



void NuoModelSimple::AssignPosition(size_t targetOffset, size_t sourceIndex,
                                    const std::vector<float>& positionsBuffer)
{
    size_t sourceOffset = sourceIndex * 3;
    
    _buffer[targetOffset]._position.x = positionsBuffer[sourceOffset];
    _buffer[targetOffset]._position.y = positionsBuffer[sourceOffset + 1];
    _buffer[targetOffset]._position.z = positionsBuffer[sourceOffset + 2];
    _buffer[targetOffset]._position.w = 1.0f;
}


void NuoModelSimple::AssignNormal(size_t targetOffset, size_t sourceIndex,
                                  const std::vector<float>& normalBuffer)
{
    size_t sourceOffset = sourceIndex * 3;
    
    _buffer[targetOffset]._normal.x = normalBuffer[sourceOffset];
    _buffer[targetOffset]._normal.y = normalBuffer[sourceOffset + 1];
    _buffer[targetOffset]._normal.z = normalBuffer[sourceOffset + 2];
    _buffer[targetOffset]._normal.w = 0.0f;
}



void* NuoModelSimple::Ptr()
{
    return (void*)_buffer.data();
}
