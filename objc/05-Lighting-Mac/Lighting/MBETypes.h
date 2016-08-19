#import <simd/simd.h>
#import <Metal/Metal.h>

typedef uint32_t MBEIndex;
const MTLIndexType MBEIndexType = MTLIndexTypeUInt32;

typedef struct __attribute((packed))
{
    vector_float3 position;
    vector_float3 normal;
    vector_float3 texCoord;
} MBEVertex;

typedef struct __attribute((packed))
{
    matrix_float4x4 modelViewProjectionMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float3x3 normalMatrix;
} MBEUniforms;
