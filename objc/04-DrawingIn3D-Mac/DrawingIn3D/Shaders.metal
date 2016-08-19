#include <metal_stdlib>

using namespace metal;

struct Vertex
{
    float4 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};

struct VertexOut
{
    float4 position [[position]];
    float4 color;
};

struct Uniforms
{
    float4x4 modelViewProjectionMatrix;
};


vertex VertexOut vertex_project(device Vertex *vertices [[buffer(0)]],
                             constant Uniforms *uniforms [[buffer(1)]],
                             uint vid [[vertex_id]])
{
    VertexOut vertexOut;
    vertexOut.position = uniforms->modelViewProjectionMatrix * vertices[vid].position;
    vertexOut.color = vertices[vid].color;

    return vertexOut;
}

fragment half4 fragment_flatcolor(VertexOut vertexIn [[stage_in]])
{
    return half4(vertexIn.color);
}
