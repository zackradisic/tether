//
//  Shaders.metal
//  tether2
//
//  Created by Zack Radisic on 05/06/2023.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position  [[attribute(0)]];
    float2 texCoords [[attribute(1)]];
    float4 color     [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 texCoords;
};

struct Uniforms {
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut vertex_main(VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut vertexOut;
    vertexOut.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(vertexIn.position.xy, 0, 1);
//    vertexOut.position = float4(vertexIn.position.xy, 0, 1);
    
    // note that this will be fucked up if we do non-uniform scaling because of the nuances of normals
    vertexOut.texCoords = vertexIn.texCoords.xy;
    vertexOut.color = vertexIn.color;
    return vertexOut;
}

fragment float4 fragment_main(VertexOut fragmentIn [[stage_in]],
                              texture2d<float> tex [[texture(0)]],
                              sampler smp [[sampler(0)]]) {
//        float alpha = tex.sample(smp, fragmentIn.texCoords.xy).r;
//        return float4(fragmentIn.color.xyz, alpha);
    
//    return float4(1, 1, 1, tex.sample(smp, fragmentIn.texCoords.xy).a);
    
//    return float4(1, 1, 1, tex.sample(smp, fragmentIn.texCoords.xy).a) * fragmentIn.color;
    
    return tex.sample(smp, fragmentIn.texCoords.xy);
    
    

//    float4 color = float4(1, 1, 1, tex.sample(smp, fragmentIn.texCoords.xy).a) * fragmentIn.color;
//    return color;
    
//        return fragmentIn.color;
}
