//
//  NuoModelLoader.m
//  ModelViewer
//
//  Created by middleware on 8/26/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#import "NuoModelLoader.h"

#include "NuoModelBase.h"
#include "NuoMaterial.h"

#include "tiny_obj_loader.h"



typedef std::vector<tinyobj::shape_t> ShapeVector;
typedef std::shared_ptr<ShapeVector> PShapeVector;




static void DoSplitShapes(const PShapeVector result, const tinyobj::shape_t shape)
{
    tinyobj::mesh_t mesh = shape.mesh;
    
    assert(mesh.num_face_vertices.size() == mesh.material_ids.size());
    
    
    size_t faceAccount = mesh.num_face_vertices.size();
    size_t i = 0;
    for (i = 0; i < faceAccount - 1; ++i)
    {
        unsigned char numPerFace1 = mesh.num_face_vertices[i];
        unsigned char numPerFace2 = mesh.num_face_vertices[i+1];
        
        int material1 = mesh.material_ids[i];
        int material2 = mesh.material_ids[i+1];
        
        if (numPerFace1 != numPerFace2 || material1 != material2)
        {
            tinyobj::shape_t splitShape;
            tinyobj::shape_t remainShape;
            splitShape.name = shape.name;
            remainShape.name = shape.name;
            
            std::vector<tinyobj::index_t>& addedIndices = splitShape.mesh.indices;
            std::vector<tinyobj::index_t>& remainIndices = remainShape.mesh.indices;
            addedIndices.insert(addedIndices.begin(),
                                mesh.indices.begin(),
                                mesh.indices.begin() + i * numPerFace1);
            remainIndices.insert(remainIndices.begin(),
                                 mesh.indices.begin() + i * numPerFace1,
                                 mesh.indices.end());
            
            std::vector<unsigned char>& addedNumberPerFace = splitShape.mesh.num_face_vertices;
            std::vector<unsigned char>& remainNumberPerFace = remainShape.mesh.num_face_vertices;
            addedNumberPerFace.insert(addedNumberPerFace.begin(),
                                      mesh.num_face_vertices.begin(),
                                      mesh.num_face_vertices.begin() + i);
            remainNumberPerFace.insert(remainNumberPerFace.begin(),
                                       mesh.num_face_vertices.begin() + i,
                                       mesh.num_face_vertices.end());
            
            std::vector<int>& addedMaterial = splitShape.mesh.material_ids;
            std::vector<int>& remainMaterial = remainShape.mesh.material_ids;
            addedMaterial.insert(addedMaterial.begin(),
                                 mesh.material_ids.begin(),
                                 mesh.material_ids.begin() + i);
            remainMaterial.insert(remainMaterial.begin(),
                                  mesh.material_ids.begin() + i,
                                  mesh.material_ids.end());
            
            result->push_back(splitShape);
            DoSplitShapes(result, remainShape);
            break;
        }
    }
    
    if (i == faceAccount - 1)
        result->push_back(shape);
}



static tinyobj::shape_t DoMergeShapes(std::vector<tinyobj::shape_t> shapes)
{
    tinyobj::shape_t result;
    result.name = shapes[0].name;
    
    for (const auto& shape : shapes)
    {
        result.mesh.indices.insert(result.mesh.indices.end(),
                                   shape.mesh.indices.begin(),
                                   shape.mesh.indices.end());
        result.mesh.material_ids.insert(result.mesh.material_ids.end(),
                                        shape.mesh.material_ids.begin(),
                                        shape.mesh.material_ids.end());
        result.mesh.num_face_vertices.insert(result.mesh.num_face_vertices.end(),
                                             shape.mesh.num_face_vertices.begin(),
                                             shape.mesh.num_face_vertices.end());
    }
    
    return result;
}




static void DoMergeShapesInVector(const PShapeVector result, std::vector<tinyobj::material_t>& materials)
{
    typedef std::map<NuoMaterial, std::vector<tinyobj::shape_t>> ShapeMap;
    ShapeMap shapesMap;
    
    NuoMaterial nonMaterial;
    
    for (size_t i = 0; i < result->size(); ++i)
    {
        const auto& shape = (*result)[i];
        int shapeMaterial = shape.mesh.material_ids[0];
        
        if (shapeMaterial < 0)
        {
            shapesMap[nonMaterial].push_back(shape);
        }
        else
        {
            tinyobj::material_t material = materials[(size_t)shapeMaterial];
            NuoMaterial materialIndex(material);
            shapesMap[materialIndex].push_back(shape);
        }
    }
    
    result->clear();
    
    for (auto itr = shapesMap.begin(); itr != shapesMap.end(); ++itr)
    {
        std::vector<tinyobj::shape_t>& shapes = itr->second;
        result->push_back(DoMergeShapes(shapes));
    }
}




static PShapeVector GetShapeVector(const tinyobj::shape_t shape, std::vector<tinyobj::material_t> &materials)
{
    PShapeVector result = std::make_shared<ShapeVector>();
    DoSplitShapes(result, shape);
    DoMergeShapesInVector(result, materials);
    
    return result;
}




@implementation NuoModelLoader



-(NSArray<NuoMesh*>*)loadModelObjects:(NSString*)objPath withType:(NSString*)type
{
    tinyobj::attrib_t attrib;
    std::vector<tinyobj::shape_t> shapes;
    std::vector<tinyobj::material_t> materials;
    std::string err;
    
    tinyobj::LoadObj(&attrib, &shapes, &materials, &err, objPath.UTF8String);
    
    typedef std::map<NuoMaterial, std::vector<tinyobj::shape_t>> ShapeMap;
    ShapeMap shapesMap;
    
    for (const tinyobj::shape_t& shape : shapes)
    {
        shape.mesh.material_ids
        ShapeMap[]
    }
    
    
    
    
    
    
    std::shared_ptr<NuoModelBase> modelBase = CreateModel(type.UTF8String);
    
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

@end
