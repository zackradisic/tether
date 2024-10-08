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
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

struct InstanceData {
    float4 color [[attribute(1)]];
    float2 offset [[attribute(2)]];
};

struct Uniforms {
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut vertex_main(VertexIn vertexIn [[stage_in]],
                             constant InstanceData *instanceData [[buffer(1)]],
                             constant Uniforms &uniforms [[buffer(2)]],
                             uint instance_id [[instance_id]])
{
    VertexOut vertexOut;
    float2 temp = vertexIn.position.xy + instanceData[instance_id].offset;
    vertexOut.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(temp.xy, 0.9, 1);
    // float2 temp = vertexIn.position.xy;
    // vertexOut.position = uniforms.projectionMatrix * ((uniforms.modelViewMatrix * float4(temp.xy, 0.9, 1)) + float4(instanceData[instance_id].offset, 0, 0));
    // vertexOut.color = instanceData[instance_id].color;
    float instance_id_float = float(instance_id);
    // vertexOut.color = float4(instanceData[instance_id].color.rgb * mix(2, 4, instance_id_float), instanceData[instance_id].color.a);
    // vertexOut.color = float4(instanceData[instance_id].color.rgb * mix(1.1, 1.4, instance_id_float), instanceData[instance_id].color.a);
    vertexOut.color = float4(instanceData[instance_id].color.rgb * 2.0, instanceData[instance_id].color.a);
    return vertexOut;
}

fragment float4 fragment_main(VertexOut fragmentIn [[stage_in]]) {
    return float4(fragmentIn.color.rgba);
}
