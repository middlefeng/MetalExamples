//
//  NuoModelTextured.hpp
//  ModelViewer
//
//  Created by middleware on 9/5/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#ifndef NuoModelTextured_hpp
#define NuoModelTextured_hpp


#include "NuoModelBase.h"


struct NuoItemTextured
{
    vector_float4 _position;
    vector_float4 _normal;
    vector_float2 _texCoord;
    
    NuoItemTextured();
    
    bool operator == (const NuoItemTextured& other);
};



template <class ItemBase>
class NuoModelTextureBase : public NuoModelCommon<ItemBase>
{
public:
    
    void AddTexCoord(size_t sourceIndex, const std::vector<float>& texCoordBuffer) override;
    
};



template <class ItemBase>
void NuoModelTextureBase<ItemBase>::AddTexCoord(size_t sourceIndex, const std::vector<float>& texCoordBuffer)
{
    size_t sourceOffset = sourceIndex * 2;
    size_t targetOffset = NuoModelCommon<ItemBase>::_buffer.size() - 1;
    
    NuoModelCommon<ItemBase>::_buffer[targetOffset]._texCoord.x = texCoordBuffer[sourceOffset];
    NuoModelCommon<ItemBase>::_buffer[targetOffset]._texCoord.y = texCoordBuffer[sourceOffset + 1];
}





#endif /* NuoModelTextured_hpp */
