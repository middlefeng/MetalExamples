#import "MBEOBJMesh.h"
#import "MBEOBJGroup.h"

#include "MBETypes.h"
#include "tiny_obj_loader.h"

@implementation MBEOBJMesh

@synthesize indexBuffer=_indexBuffer;
@synthesize vertexBuffer=_vertexBuffer;

- (instancetype)initWithGroup:(MBEOBJGroup *)group device:(id<MTLDevice>)device
{
    if ((self = [super init]))
    {
        _vertexBuffer = [device newBufferWithBytes:[group.vertexData bytes]
                                            length:[group.vertexData length]
                                           options:MTLResourceOptionCPUCacheModeDefault];
        [_vertexBuffer setLabel:[NSString stringWithFormat:@"Vertices (%@)", group.name]];
        
        MBEVertex* vertexArray = (MBEVertex*)[group.vertexData bytes];
        size_t count = [group.vertexData length] / sizeof(MBEVertex);
        for (size_t i = 0; i < 10; i++)
        {
            MBEVertex current = vertexArray[i];
            NSLog(@"Position: %f, %f, %f.", current.position.x, current.position.y, current.position.z);
        }
        
        _indexBuffer = [device newBufferWithBytes:[group.indexData bytes]
                                           length:[group.indexData length]
                                          options:MTLResourceOptionCPUCacheModeDefault];
        [_indexBuffer setLabel:[NSString stringWithFormat:@"Indices (%@)", group.name]];
        
        uint16* indexArray = (uint16*)[group.indexData bytes];
        size_t indexCount = [group.indexData length] / sizeof(uint16);
        for (size_t i = 0; i < 10; i++)
        {
            uint16 index = indexArray[i];
            NSLog(@"Index: %u.", index);
        }

    }
    return self;
}

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
        
        /*MBEVertex* vertexArray = (MBEVertex*)vertex.data();
        for (size_t i = 0; i < 10; i++)
        {
            MBEVertex current = vertexArray[i];
            NSLog(@"Position: %f, %f, %f.", current.position.x, current.position.y, current.position.z);
        }
        
        std::vector<uint16> index(shapes[0].mesh.indices.size());
        
        NSLog(@"Index Count: %lu.", shapes[0].mesh.indices.size());
        
        for (size_t i = 0; i < shapes[0].mesh.indices.size(); ++i)
        {
            if (i > 25003)
            {
                uint16 vertex = shapes[0].mesh.indices[i].vertex_index;
                uint16 normal = shapes[0].mesh.indices[i].normal_index;
            }
            index[i] = shapes[0].mesh.indices[i].vertex_index;
        }*/
        
        _indexBuffer = [device newBufferWithBytes:indices.data()
                                           length:indices.size() * sizeof(uint32)
                                          options:MTLResourceOptionCPUCacheModeDefault];
        
        /*uint16* indexArray = (uint16*)index.data();
        for (size_t i = 0; i < 10; i++)
        {
            uint16 index = indexArray[i];
            NSLog(@"Index: %u.", index);
        }*/
    }
    return self;
}

@end
