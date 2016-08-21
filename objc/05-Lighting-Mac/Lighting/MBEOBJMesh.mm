#import "MBEOBJMesh.h"

#include "MBETypes.h"
#include "tiny_obj_loader.h"

@implementation MBEOBJMesh

@synthesize indexBuffer=_indexBuffer;
@synthesize vertexBuffer=_vertexBuffer;

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
                
                vertex.normal.x = attrib.normals[index.normal_index * 3];
                vertex.normal.y = attrib.normals[index.normal_index * 3 + 1];
                vertex.normal.z = attrib.normals[index.normal_index * 3 + 2];
                vertex.normal.w = 1.0;
                
                vertecis.push_back(vertex);
                indices.push_back(indexCurrent++);
            }
        }
        
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
