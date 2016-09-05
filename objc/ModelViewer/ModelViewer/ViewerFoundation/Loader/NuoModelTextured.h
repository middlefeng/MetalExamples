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
class NuoModelTexture : public NuoModelCommon<NuoItemTextured>
{
public:
};




#endif /* NuoModelTextured_hpp */
