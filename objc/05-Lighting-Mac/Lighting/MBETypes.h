#import <simd/simd.h>
#import <Metal/Metal.h>

typedef uint32_t MBEIndex;
const MTLIndexType MBEIndexType = MTLIndexTypeUInt32;

typedef struct
{
    vector_float4 position;
    vector_float4 normal;
    
    vector_float3 ambientColor;
    vector_float3 diffuseColor;
    vector_float3 specularColor;
    
    float specularPower;
}
MBEVertex;


typedef struct __attribute((packed))
{
    matrix_float4x4 modelViewProjectionMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float3x3 normalMatrix;
}
MBEUniforms;
