
#import "NuoMesh.h"

#include "MBETypes.h"
#include "tiny_obj_loader.h"



@implementation BoundingBox

@end



@implementation MBEOBJMesh

@synthesize indexBuffer = _indexBuffer;
@synthesize vertexBuffer = _vertexBuffer;

bool operator==(const MBEVertex& a, const MBEVertex& b)
{
    return a.position.x == b.position.x &&
            a.position.y == b.position.y &&
            a.position.z == b.position.z &&
            a.normal.x == b.normal.x &&
            a.normal.y == b.normal.y &&
            a.normal.z == b.normal.z;
}

@synthesize boundingBox = _boundingBox;

- (instancetype)initWithPath:(NSString*)path device:(id<MTLDevice>)device
{
    if ((self = [super init]))
    {
        tinyobj::attrib_t attrib;
        std::vector<tinyobj::shape_t> shapes;
        std::vector<tinyobj::material_t> materials;
        std::string err;

        tinyobj::LoadObj(&attrib, &shapes, &materials, &err, path.UTF8String);
        
        std::vector<MBEVertex> vertecis;
        std::vector<uint32> indices;
        uint32 indexCurrent = 0;
        
        float xMin = 1e9f, xMax = -1e9f;
        float yMin = 1e9f, yMax = -1e9f;
        float zMin = 1e9f, zMax = -1e9f;
        
        for (const auto& shape : shapes)
        {
            for (size_t i = 0; i < shape.mesh.indices.size(); ++i)
            {
                tinyobj::index_t index = shape.mesh.indices[i];
                
                MBEVertex vertex;
                
                vertex.position.x = attrib.vertices[index.vertex_index * 3];
                vertex.position.y = attrib.vertices[index.vertex_index * 3 + 1];
                vertex.position.z = attrib.vertices[index.vertex_index * 3 + 2];
                vertex.position.w = 1.0;
                
                if (attrib.normals.size())
                {
                    vertex.normal.x = attrib.normals[index.normal_index * 3];
                    vertex.normal.y = attrib.normals[index.normal_index * 3 + 1];
                    vertex.normal.z = attrib.normals[index.normal_index * 3 + 2];
                    vertex.normal.w = 0.0;
                }
                else
                {
                    vertex.normal.xyzw = 0;
                }

                xMin = std::min(xMin, vertex.position.x);
                xMax = std::max(xMax, vertex.position.x);
                yMin = std::min(yMin, vertex.position.y);
                yMax = std::max(yMax, vertex.position.y);
                zMin = std::min(zMin, vertex.position.z);
                zMax = std::max(zMax, vertex.position.z);
                
                
                size_t checkBackward = 100;
                if (attrib.normals.size())
                {
                    auto search = std::find((vertecis.size() < checkBackward ? vertecis.begin() : vertecis.end()-checkBackward), vertecis.end(), vertex);
                    if (search != std::end(vertecis))
                    {
                        uint32_t indexExist = (uint32_t)(search - std::begin(vertecis));
                        indices.push_back(indexExist);
                    }
                    else
                    {
                        vertecis.push_back(vertex);
                        indices.push_back(indexCurrent++);
                    }
                }
                else
                {
                    vertecis.push_back(vertex);
                    indices.push_back(indexCurrent++);
                }
            }
        }
        
        if (!attrib.normals.size())
        {
            size_t indexCount = indices.size();
            for (size_t i = 0; i < indexCount; i += 3)
            {
                uint32_t i0 = indices[i];
                uint32_t i1 = indices[i + 1];
                uint32_t i2 = indices[i + 2];
                
                MBEVertex *v0 = &vertecis[i0];
                MBEVertex *v1 = &vertecis[i1];
                MBEVertex *v2 = &vertecis[i2];
                
                vector_float3 p0 = v0->position.xyz;
                vector_float3 p1 = v1->position.xyz;
                vector_float3 p2 = v2->position.xyz;
                
                vector_float3 cross = vector_cross((p1 - p0), (p2 - p0));
                vector_float4 cross4 = { cross.x, cross.y, cross.z, 0 };
                
                v0->normal += cross4;
                v1->normal += cross4;
                v2->normal += cross4;
            }
            
            for (size_t i = 0; i < vertecis.size(); ++i)
            {
                vertecis[i].normal = vector_normalize(vertecis[i].normal);
            }
        }

        _boundingBox = [[BoundingBox alloc] init];
        _boundingBox.centerX = (xMax + xMin) / 2.0;
        _boundingBox.centerY = (yMax + yMin) / 2.0;
        _boundingBox.centerZ = (zMax + zMin) / 2.0;
        _boundingBox.spanX = (xMax - xMin);
        _boundingBox.spanY = (yMax - yMin);
        _boundingBox.spanZ = (zMax - zMin);
        
        _vertexBuffer = [device newBufferWithBytes:vertecis.data()
                                            length:vertecis.size() * sizeof(MBEVertex)
                                           options:MTLResourceOptionCPUCacheModeDefault];
        
        _indexBuffer = [device newBufferWithBytes:indices.data()
                                           length:indices.size() * sizeof(uint32)
                                          options:MTLResourceOptionCPUCacheModeDefault];
    }
    
    return self;
}

@end
