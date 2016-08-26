#include <metal_stdlib>
#include <metal_matrix>

using namespace metal;

struct Light
{
    float3 direction;
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
};

constant Light light = {
    .direction = { 0.13, 0.72, 0.68 },
    .ambientColor = { 0.05, 0.05, 0.05 },
    .diffuseColor = { 0.9, 0.9, 0.9 },
    .specularColor = { 1, 1, 1 }
};

struct Material
{
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
    float specularPower;
};

/*
constant Material material = {
    .ambientColor = { 0.7, 0.7, 0.7 },
    .diffuseColor = { 0.7, 0.7, 0.7 },
    .specularColor = { 1, 1, 1 },
    .specularPower = 30
};
*/

struct Uniforms
{
    float4x4 modelViewProjectionMatrix;
    float4x4 modelViewMatrix;
    float3x3 normalMatrix;
};

struct Vertex
{
    float4 position;
    float4 normal;
    
    float4 ambientColor;
    float4 diffuseColor;
    float4 specularColor;
    float4 specularPower;
};

struct ProjectedVertex
{
    float4 position [[position]];
    float3 eye;
    float3 normal;
    
    float3 ambientColor  [[flat]];
    float3 diffuseColor  [[flat]];
    float3 specularColor [[flat]];
    float specularPower  [[flat]];
};

vertex ProjectedVertex vertex_project(device Vertex *vertices [[buffer(0)]],
                                      constant Uniforms &uniforms [[buffer(1)]],
                                      uint vid [[vertex_id]])
{
    ProjectedVertex outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * vertices[vid].position;
    outVert.eye =  -(uniforms.modelViewMatrix * vertices[vid].position).xyz;
    outVert.normal = uniforms.normalMatrix * vertices[vid].normal.xyz;
    
    outVert.ambientColor = vertices[vid].ambientColor.xyz;
    outVert.diffuseColor = vertices[vid].diffuseColor.xyz;
    outVert.specularColor = vertices[vid].specularColor.xyz;
    outVert.specularPower = vertices[vid].specularPower[0];

    return outVert;
}

fragment float4 fragment_light(ProjectedVertex vert [[stage_in]])
{
    float3 ambientTerm = light.ambientColor * vert.ambientColor;
    
    float3 normal = normalize(vert.normal);
    float diffuseIntensity = saturate(dot(normal, light.direction));
    float3 diffuseTerm = light.diffuseColor * vert.diffuseColor * diffuseIntensity;
    
    float3 specularTerm(0);
    if (diffuseIntensity > 0)
    {
        float3 eyeDirection = normalize(vert.eye);
        float3 halfway = normalize(light.direction + eyeDirection);
        float specularFactor = pow(saturate(dot(normal, halfway)), vert.specularPower);
        specularTerm = light.specularColor * vert.specularColor * specularFactor;
    }
    
    return float4(ambientTerm + diffuseTerm + specularTerm, 1);
}
