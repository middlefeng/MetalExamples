//
//  NuoModelBase.hpp
//  ModelViewer
//
//  Created by middleware on 8/28/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#ifndef NuoModelBase_hpp
#define NuoModelBase_hpp

#include <vector>
#include <string>

#include <simd/simd.h>



const extern std::string kNuoModelType_Simple;



class NuoModelBase;



std::shared_ptr<NuoModelBase> CreateModel(std::string type);



class NuoModelBase : public std::enable_shared_from_this<NuoModelBase>
{
public:
    virtual void AssignPosition(size_t targetOffset, size_t sourceIndex,
                                const std::vector<float>& positionsBuffer) = 0;
    
    virtual void AssignNormal(size_t targetOffset, size_t sourceIndex,
                              const std::vector<float>& normalBuffer) = 0;
    
    virtual void* Ptr() = 0;
};



class NuoModelSimple : public NuoModelBase
{
private:
    struct Item
    {
        vector_float4 _position;
        vector_float4 _normal;
    };
    
    std::vector<Item> _buffer;
    
public:
    NuoModelSimple();
    
    virtual void AssignPosition(size_t targetOffset, size_t sourceIndex,
                                const std::vector<float>& positionsBuffer) override;
    
    virtual void AssignNormal(size_t targetOffset, size_t sourceIndex,
                              const std::vector<float>& normalBuffer) override;
    
    virtual void* Ptr() override;
};



#endif /* NuoModelBase_hpp */
