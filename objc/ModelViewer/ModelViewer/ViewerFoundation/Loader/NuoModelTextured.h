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



class NuoModelTextured : public NuoModelBase
{
protected:
    
    std::string _texPath;
    
    struct Item
    {
        vector_float4 _position;
        vector_float4 _normal;
        vector_float2 _texCoord;
        
        bool operator == (const Item& i2);
        
        Item();
    };
    
    std::vector<Item> _buffer;
    
public:
    NuoModelTextured();
    
    virtual void AddPosition(size_t sourceIndex, const std::vector<float>& positionsBuffer) override;
    virtual void AddNormal(size_t sourceIndex, const std::vector<float>& normalBuffer) override;
    virtual void GenerateIndices() override;
    virtual void GenerateNormals() override;
    
    virtual size_t GetVerticesNumber() override;
    virtual vector_float4 GetPosition(size_t index) override;
    
    virtual void* Ptr() override;
    virtual size_t Length() override;
};



#endif /* NuoModelTextured_hpp */
