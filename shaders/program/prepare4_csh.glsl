#include "/lib/common.glsl"

#ifdef CSH

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;
const vec2 workGroupsRender = vec2(0.5, 0.5);

uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
vec2 view = vec2(viewWidth, viewHeight);
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferPreviousModelView;
uniform sampler2D colortex8;
layout(rgba16f) uniform image2D colorimg10;
layout(rgba16i) uniform iimage2D colorimg11;

#include "/lib/vx/SSBOs.glsl"
#include "/lib/vx/raytrace.glsl"
#include "/lib/util/random.glsl"

#define MAX_LIGHT_COUNT 48

shared int lightCount;
shared int finalLightCount;
shared ivec4[MAX_LIGHT_COUNT] positions;
shared int[MAX_LIGHT_COUNT] mergeOffsets;

void main() {
    if (gl_LocalInvocationID.xy == uvec2(0)) {
        lightCount = 0;
    }
    barrier();
    memoryBarrierShared();
    ivec2 readTexelCoord = ivec2(gl_GlobalInvocationID.xy) * 2 + ivec2(frameCounter % 2, frameCounter / 2 % 2);
    ivec2 writeTexelCoord = ivec2(gl_GlobalInvocationID.xy);
    vec4 normalDepthData = texelFetch(colortex8, readTexelCoord, 0);
    ivec3 vxPosFrameOffset = ivec3((floor(previousCameraPosition) - floor(cameraPosition)) * 1.1);
    bool validData = (normalDepthData.a < 1.5 && length(normalDepthData.rgb) > 0.1 && all(lessThan(readTexelCoord, ivec2(view + 0.1))));
    vec3 vxPos = vec3(1000);
    int index = int(gl_LocalInvocationID.x + gl_WorkGroupSize.x * gl_LocalInvocationID.y);
    if (validData) {
        vec4 playerPos = gbufferModelViewInverse * (gbufferProjectionInverse * (vec4((readTexelCoord + 0.5) / view, 1 - normalDepthData.a, 1) * 2 - 1));
        playerPos /= playerPos.w;
        #if PIXEL_SHADOW > 0
            vxPos = floor(playerToVx(playerPos.xyz) * (PIXEL_SHADOW) + 0.005 * normalDepthData.xyz) / (PIXEL_SHADOW) + max(0.1, 0.005 * length(playerPos.xyz)) * normalDepthData.xyz;
        #else
            vxPos = playerToVx(playerPos.xyz) + max(0.1, 0.005 * length(playerPos.xyz)) * normalDepthData.xyz;
        #endif
        vec3 dir = randomSphereSample();
        if (dot(dir, normalDepthData.xyz) < 0) dir *= -1;
        ray_hit_t rayHit0 = raytrace(vxPos, LIGHT_TRACE_LENGTH * dir);
        if (rayHit0.emissive) {
            int lightIndex = atomicAdd(lightCount, 1);
            if (lightIndex < MAX_LIGHT_COUNT) {
                positions[lightIndex] = ivec4(rayHit0.pos - 0.05 * rayHit0.normal + 1000, 1) - ivec4(1000, 1000, 1000, 0);
                mergeOffsets[lightIndex] = 0;
            } else {
                atomicMin(lightCount, MAX_LIGHT_COUNT);
            }
        }
    }
    barrier();
    memoryBarrierShared();
    if (index < 4) {
        ivec2 offset = (ivec2(index) + ivec2(-1, -2)) % 2;// * ((index - MAX_LIGHT_COUNT) / 2 * 2 - 1);
        int otherLightIndex = frameCounter % min(MAX_LIGHT_COUNT, lightCount * 2 + 2);
        ivec4 prevFrameLight = imageLoad(colorimg11, ivec2(gl_WorkGroupSize.xy * (gl_WorkGroupID.xy + offset)) + ivec2(otherLightIndex % gl_WorkGroupSize.x, otherLightIndex / gl_WorkGroupSize.x));
        bool known = (prevFrameLight.xyz == ivec3(0) || prevFrameLight.w == 0);
        prevFrameLight.xyz += vxPosFrameOffset;
        if (!known) {
            int thisLightIndex = atomicAdd(lightCount, 1);
            if (thisLightIndex < MAX_LIGHT_COUNT) {
                positions[thisLightIndex] = ivec4(prevFrameLight.xyz, 0);
                mergeOffsets[thisLightIndex] = 0;
            } else {
                atomicMin(lightCount, MAX_LIGHT_COUNT);
            }
        }
    }
    barrier();
    memoryBarrierShared();
    int oldLightCount = lightCount;
    int mergeOffset = 0;
    ivec4 thisPos = ivec4(0);
    int k = index + 1;
    if (index < oldLightCount) {
        thisPos = positions[index];
        while (k < oldLightCount && positions[k].xyz != thisPos.xyz) k++;
        if (k < oldLightCount) {
            atomicAdd(mergeOffsets[k], -1000);
            mergeOffset = 1;
            for (k++; k < oldLightCount; k++) {
                atomicAdd(mergeOffsets[k], 1);
            }
        }
    }
    barrier();
    memoryBarrierShared();
    if (index < oldLightCount) {
        if (mergeOffsets[index] > 0) {
            positions[index - mergeOffsets[index]] = thisPos;
        }
        if (mergeOffset > 0) {
            atomicAdd(lightCount, -1);
        }
    }
    barrier();
    memoryBarrierShared();
    oldLightCount = lightCount;
    barrier();
    memoryBarrierShared();
    if (index < MAX_LIGHT_COUNT) {
        ivec4 prevFrameLight = imageLoad(colorimg11, writeTexelCoord);
        bool known = (prevFrameLight.xyz == ivec3(0) || prevFrameLight.w == 0);// || nextUint() % 100 == 0);
        prevFrameLight.xyz += vxPosFrameOffset;
        for (int k = 0; k < oldLightCount; k++) {
            if (prevFrameLight.xyz == positions[k].xyz) {
                known = true;
                break;
            }
        }
        if (!known) {
            int thisLightIndex = atomicAdd(lightCount, 1);
            if (thisLightIndex < MAX_LIGHT_COUNT) {
                positions[thisLightIndex] = ivec4(prevFrameLight.xyz, 0);
            } else {
                atomicMin(lightCount, MAX_LIGHT_COUNT);
            }
        }
    }
    barrier();
    memoryBarrierShared();
    vec3 writeColor = vec3(0);
    #ifdef TRACE_ALL_LIGHTS
        for (uint thisLightIndex = lightCount * uint(!validData); thisLightIndex < lightCount; thisLightIndex++) {
    #else
        if (lightCount > 0 && validData) {
            uint thisLightIndex = nextUint() % lightCount;
        #endif
        vec3 lightPos = positions[thisLightIndex].xyz + 0.5;
        float ndotl0 = max(0, dot(normalize(lightPos - vxPos), normalDepthData.xyz));
        ivec3 lightCoords = vxPosToVxCoords(lightPos);
        int mat = readBlockVolume(lightCoords);
        int baseIndex = getBaseIndex(mat);
        int emissiveVoxelCount = mat < MATERIALCOUNT ? readEmissiveCount(baseIndex) : 0;
        bool entity = false;
        int entityOccupancy = readEntityOccupancy(lightCoords);
        if (emissiveVoxelCount > 0) {
            int subEmissiveIndex = int(nextUint() % emissiveVoxelCount);
            vec3 localPos = readEmissiveLoc(baseIndex, subEmissiveIndex);
            vec3 meanLocalPos = readEmissiveLoc(baseIndex, emissiveVoxelCount);
            if (any(lessThan(localPos, vec3(-0.5)))) {
                lightPos = vec3(-10000);
            }
            localPos += (vec3(nextFloat(), nextFloat(), nextFloat()) - 0.5) / (1<<(min(VOXEL_DETAIL_AMOUNT, 3)-1));
            lightPos = floor(lightPos) + (localPos - meanLocalPos) * LIGHTSOURCE_SIZE_MULT + meanLocalPos;
        } else if (entityOccupancy != 0) {
            vec3 emissiveLocs[8];
            for (int k = 0; k < 8; k++) {
                ivec3 offset = ivec3(k%2, k/2%2, k/4%2);
                if ((entityOccupancy >> (k + 8) & 1) != 0) {
                    entity = true;
                    emissiveLocs[emissiveVoxelCount++] = (offset + vec3(nextFloat(), nextFloat(), nextFloat()) - 1.0) * 0.5;
                }
            }
            if (entity) {
                int subEmissiveIndex = int(nextUint() % emissiveVoxelCount);
                lightPos += emissiveLocs[subEmissiveIndex];
            } else {
                lightPos = vec3(-10000);
            }
        } else {
            lightPos = vec3(-10000);
        }
        vec3 dir = lightPos - vxPos;
        float dirLen = length(dir);
        if (dirLen < LIGHT_TRACE_LENGTH) {
            float lightBrightness = readLightLevel(vxPosToVxCoords(lightPos)) * 0.04;
            lightBrightness *= lightBrightness;
            float ndotl = ndotl0 * lightBrightness;
            ray_hit_t rayHit1 = raytrace(vxPos, (1.0 + 0.1 / (length(dir) + 0.1)) * dir);
            if (length(rayHit1.rayColor.rgb) > 0.003 && rayHit1.emissive && infnorm(rayHit1.pos - 0.05 * rayHit1.normal - positions[thisLightIndex].xyz - 0.5) < 0.51 + float(entity)) {
                writeColor += rayHit1.rayColor.rgb * float(rayHit1.emissive) * ndotl * (sqrt(1 - dirLen / LIGHT_TRACE_LENGTH)) / (dirLen + 0.1);
                positions[thisLightIndex].w = 1;
            }
        }
    }
    #ifndef TRACE_ALL_LIGHTS
        writeColor *= lightCount;
    #endif
    if (gl_LocalInvocationID == uvec3(0)) {
        finalLightCount = 0;
    }
    barrier();
    memoryBarrierShared();
    if (index < lightCount && positions[index].w > 0) {
        atomicAdd(finalLightCount, 1);
    }
    barrier();
    memoryBarrierShared();

    imageStore(colorimg10, writeTexelCoord, vec4(writeColor, finalLightCount));
    barrier();
    memoryBarrierShared();
    ivec4 lightPosToStore = (index < lightCount && positions[index].w > 0) ? positions[index] : ivec4(0);
    imageStore(colorimg11, writeTexelCoord, lightPosToStore);
}
#endif
