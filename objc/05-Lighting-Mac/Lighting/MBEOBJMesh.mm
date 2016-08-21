#import "MBEOBJMesh.h"

#include "MBETypes.h"
#include "tiny_obj_loader.h"

@implementation MBEOBJMesh

@synthesize indexBuffer = _indexBuffer;
@synthesize vertexBuffer = _vertexBuffer;

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
        
        float xMin = 0.0f, xMax = 0.0f;
        float yMin = 0.0f, yMax = 0.0f;
        float zMin = 0.0f, zMax = 0.0f;
        
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
                
                xMin = std::min(xMin, vertex.position.x);
                xMax = std::max(xMax, vertex.position.x);
                yMin = std::min(yMin, vertex.position.y);
                yMax = std::max(yMax, vertex.position.y);
                zMin = std::min(zMin, vertex.position.z);
                zMax = std::max(zMax, vertex.position.z);
                
                vertex.normal.x = attrib.normals[index.normal_index * 3];
                vertex.normal.y = attrib.normals[index.normal_index * 3 + 1];
                vertex.normal.z = attrib.normals[index.normal_index * 3 + 2];
                vertex.normal.w = 1.0;
                
                vertecis.push_back(vertex);
                indices.push_back(indexCurrent++);
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
