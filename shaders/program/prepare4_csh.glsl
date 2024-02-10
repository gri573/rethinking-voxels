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

#include "/lib/vx/voxelReading.glsl"
#include "/lib/util/random.glsl"

#if MAX_TRACE_COUNT < 128
    #define MAX_LIGHT_COUNT 128
#else
    #define MAX_LIGHT_COUNT 512
#endif
shared int lightCount;
shared ivec4 cumulatedPos;
shared ivec4 cumulatedNormal;
shared int finalLightCount;
shared ivec4[MAX_LIGHT_COUNT] positions;
shared float[MAX_LIGHT_COUNT] weights;
shared uint[128] lightHashMap;

int packPosition(ivec3 pos) {
    pos += voxelVolumeSize/2;
    return pos.x + (pos.y << 9) + (pos.z << 18);
}
int packPosition(vec3 pos) {
    return packPosition(ivec3(pos + 1000) - 1000);
}
uint posToHash(int pos) {
    return 3591 * uint(pos) % uint(128*32);
}

ivec2 getFlipPair(int index, int stage) {
    int groupSize = 1<<stage;
    return ivec2(index / groupSize * groupSize * 2) +
           ivec2(index%groupSize, 2 * groupSize - index%groupSize - 1);
}
ivec2 getDispersePair(int index, int stage) {
    int groupSize = 1<<stage;
    return ivec2(index / groupSize * groupSize * 2) +
           ivec2(index%groupSize, groupSize + index%groupSize);
}

float getWeight(int index, vec3 meanPos, vec3 meanNormal) {
    vec3 dPos = positions[index].xyz + 0.5 - meanPos;
    return (3.0 + dot(normalize(dPos), meanNormal))/(5.0 + dot(dPos, dPos));
}

void flipPair(int index, int stage, vec3 meanPos, vec3 meanNormal) {
    ivec2 indexPair = getFlipPair(index, stage);
    if (
        indexPair.y < lightCount && 
        weights[indexPair.x] < weights[indexPair.y]
    ) {
        ivec4 temp = positions[indexPair.x];
        float temp2 = weights[indexPair.x];
        positions[indexPair.x] = positions[indexPair.y];
        positions[indexPair.y] = temp;
        weights[indexPair.x] = weights[indexPair.y];
        weights[indexPair.y] = temp2;
    }
}

void dispersePair(int index, int stage, vec3 meanPos, vec3 meanNormal) {
    ivec2 indexPair = getDispersePair(index, stage);
    if (
        indexPair.y < lightCount &&
        weights[indexPair.x] < weights[indexPair.y]
    ) {
        ivec4 temp = positions[indexPair.x];
        float temp2 = weights[indexPair.x];
        positions[indexPair.x] = positions[indexPair.y];
        positions[indexPair.y] = temp;
        weights[indexPair.x] = weights[indexPair.y];
        weights[indexPair.y] = temp2;
    }
}

void main() {
    int index = int(gl_LocalInvocationID.x + gl_WorkGroupSize.x * gl_LocalInvocationID.y);
    float dither = nextFloat();
    if (gl_LocalInvocationID.xy == uvec2(0)) {
        lightCount = 0;
        cumulatedPos = ivec4(0);
        cumulatedNormal = ivec4(0);
    }
    if (index < 128) {
        lightHashMap[index] = 0;
    }
    barrier();
    memoryBarrierShared();
    ivec2 readTexelCoord = ivec2(gl_GlobalInvocationID.xy) * 2 + ivec2(frameCounter % 2, frameCounter / 2 % 2);
    ivec2 writeTexelCoord = ivec2(gl_GlobalInvocationID.xy);
    vec4 normalDepthData = texelFetch(colortex8, readTexelCoord, 0);
    ivec3 vxPosFrameOffset = ivec3((floor(previousCameraPosition) - floor(cameraPosition)) * 1.1);
    bool validData = (normalDepthData.a < 1.5 && length(normalDepthData.rgb) > 0.1 && all(lessThan(readTexelCoord, ivec2(view + 0.1))));
    vec3 vxPos = vec3(1000);
    if (validData) {
        vec4 playerPos = gbufferModelViewInverse * (gbufferProjectionInverse * (vec4((readTexelCoord + 0.5) / view, 1 - normalDepthData.a, 1) * 2 - 1));
        playerPos /= playerPos.w;
        vxPos = playerPos.xyz + fract(cameraPosition) + max(0.05, 1.2 * infnorm(playerPos.xyz/voxelVolumeSize)) * normalDepthData.xyz;
        ivec4 discretizedVxPos = ivec4(100 * vxPos, 100);
        ivec4 discretizedNormal = ivec4(10 * normalDepthData.xyz, 10);
        for (int i = 0; i < 4; i++) {
            atomicAdd(cumulatedPos[i], discretizedVxPos[i]);
            atomicAdd(cumulatedNormal[i], discretizedNormal[i]);
        }
        vec3 dir = randomSphereSample();
        float ndotl = dot(dir, normalDepthData.xyz);
        if (ndotl < 0) {
            dir *= -1;
            ndotl *= -1;
        }
        vec3 rayNormal0;
        vec4 rayHit0 = voxelTrace(vxPos, LIGHT_TRACE_LENGTH * dir, rayNormal0);
        if (rayHit0.a > 16) {
            int packedPos = packPosition(rayHit0.xyz - 0.05 * rayNormal0);
            uint hash = posToHash(packedPos);
            if ((atomicOr(lightHashMap[hash/32], 1<<hash%32) & uint(1)<<hash%32) == 0) {
                int lightIndex = atomicAdd(lightCount, 1);
                if (lightIndex < MAX_LIGHT_COUNT) {
                    positions[lightIndex] = ivec4(rayHit0.xyz - 0.05 * rayNormal0 + 1000, 1) - ivec4(1000, 1000, 1000, 0);
                    vec3 lightPos = positions[lightIndex].xyz + 0.5;
                    float dirLen = length(lightPos - vxPos);
                    weights[lightIndex] =
                        length(getColor(lightPos).xyz) *
                        ndotl *
                        (sqrt(1 - min(1.0, dirLen / LIGHT_TRACE_LENGTH))) /
                        (dirLen + 0.1);
                } else {
                    atomicMin(lightCount, MAX_LIGHT_COUNT);
                }
            }
        }
    }
    vec3 meanPos = vec3(cumulatedPos.xyz)/cumulatedPos.w;
    vec3 meanNormal = vec3(cumulatedNormal.xyz)/cumulatedNormal.w;
    meanNormal *= length(meanNormal);

    barrier();
    if (index < MAX_LIGHT_COUNT) {
        ivec4 prevFrameLight = imageLoad(colorimg11, writeTexelCoord);
        prevFrameLight.xyz += vxPosFrameOffset;

        uint hash = posToHash(packPosition(prevFrameLight.xyz));
        bool known = (
            prevFrameLight.w == 0 ||
            (imageLoad(occupancyVolume, prevFrameLight.xyz + voxelVolumeSize/2).r >> 16 & 1) == 0
        );
        if (!known) {
            known = (atomicOr(lightHashMap[hash/32], uint(1)<<hash%32) & uint(1)<<hash%32) != 0;
        }

        if (!known) {
            int thisLightIndex = atomicAdd(lightCount, 1);
            if (thisLightIndex < MAX_LIGHT_COUNT) {
                positions[thisLightIndex] = ivec4(prevFrameLight.xyz, 0);
                vec3 lightPos = positions[thisLightIndex].xyz + 0.5;
                float ndotl = mix(dot(normalize(lightPos - meanPos), meanNormal), 0.7, length(meanNormal));
                float dirLen = length(lightPos - meanPos);
                weights[thisLightIndex] =
                    length(getColor(lightPos).xyz) *
                    ndotl *
                    (sqrt(1 - min(1.0, dirLen / LIGHT_TRACE_LENGTH))) /
                    (dirLen + 0.1);
            } else {
                atomicMin(lightCount, MAX_LIGHT_COUNT);
            }
        }
    }
    barrier();
    if (index < 4 * MAX_LIGHT_COUNT) {
        ivec2 offset = (index%4/2*2-1) * ivec2(index%2, (index+1)%2);
        int otherLightIndex = index / 4;
        ivec4 prevFrameLight = imageLoad(colorimg11, ivec2(gl_WorkGroupSize.xy) * (ivec2(gl_WorkGroupID.xy) + offset) + ivec2(otherLightIndex % gl_WorkGroupSize.x, otherLightIndex / gl_WorkGroupSize.x));
        prevFrameLight.xyz += vxPosFrameOffset;
        uint hash = posToHash(packPosition(prevFrameLight.xyz));
        bool known = (
            prevFrameLight.w == 0 ||
            (imageLoad(occupancyVolume, prevFrameLight.xyz + voxelVolumeSize/2).r >> 16 & 1) == 0
        );
        if (!known) {
            known = (atomicOr(lightHashMap[hash/32], uint(1)<<hash%32) & uint(1)<<hash%32) != 0;
        }
        if (!known) {
            int thisLightIndex = atomicAdd(lightCount, 1);
            if (thisLightIndex < MAX_LIGHT_COUNT) {
                positions[thisLightIndex] = ivec4(prevFrameLight.xyz, 0);
                vec3 lightPos = positions[thisLightIndex].xyz + 0.5;
                float ndotl = mix(dot(normalize(lightPos - meanPos), meanNormal), 0.7, length(meanNormal));
                float dirLen = length(lightPos - meanPos);
                weights[thisLightIndex] =
                    length(getColor(lightPos).xyz) *
                    ndotl *
                    (sqrt(1 - min(1.0, dirLen / LIGHT_TRACE_LENGTH))) /
                    (dirLen + 0.1);
            } else {
                atomicMin(lightCount, MAX_LIGHT_COUNT);
            }
        }
    }
    barrier();
    memoryBarrierShared();
    bool participateInSorting = index < MAX_LIGHT_COUNT/2;
    #include "/lib/misc/prepare4_BM_sort.glsl"

    if (index >= MAX_TRACE_COUNT && index < (lightCount + 2 * MAX_TRACE_COUNT)/3) {
        vec3 lightPos = positions[index].xyz + 0.5;
        vec3 dir = lightPos - meanPos;
        float dirLen = length(dir);
        vec4 rayHit1 = coneTrace(meanPos, (1.0 - 0.1 / (dirLen + 0.1)) * dir, 0.3 / dirLen, dither);
        if (rayHit1.w > 0.01) atomicAdd(positions[index].w, 1);
    }
    vec3 writeColor = vec3(0);
    for (uint thisLightIndex = lightCount * uint(!validData); thisLightIndex < min(lightCount, MAX_TRACE_COUNT); thisLightIndex++) {
        vec3 lightPos = positions[thisLightIndex].xyz + 0.5;
        float ndotl0 = infnorm(vxPos - 0.5 * normalDepthData.xyz - lightPos) < 0.5 ? 1.0 : max(0, dot(normalize(lightPos - vxPos), normalDepthData.xyz));
        ivec3 lightCoords = ivec3(lightPos + 1000) - 1000 + voxelVolumeSize / 2;
        int lightData = imageLoad(occupancyVolume, lightCoords).r;
        vec3 dir = lightPos - vxPos;
        float dirLen = length(dir);
        if (dirLen < LIGHT_TRACE_LENGTH && ndotl0 > 0.001) {
            float lightBrightness = 1;//getLightLevel(ivec3(lightPos + 1000) - 1000 + voxelVolumeSize/2) * 0.04;
            lightBrightness *= lightBrightness;
            float ndotl = ndotl0 * lightBrightness;
            vec4 rayHit1 = coneTrace(vxPos, (1.0 - 0.1 / (dirLen + 0.1)) * dir, 0.3 / dirLen, dither);
            if (rayHit1.w > 0.01) {
                vec3 lightColor = getColor(lightPos).xyz;
                writeColor += lightColor * rayHit1.w * ndotl * (sqrt(1 - dirLen / LIGHT_TRACE_LENGTH)) / (dirLen + 0.1);
                atomicAdd(positions[thisLightIndex].w, 1);
            }
        }
    }
//    writeColor = meanNormal * 0.5 + 0.5;
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
    if (index < lightCount) writeColor = vec3(10 * weights[index]);
    imageStore(colorimg10, writeTexelCoord, vec4(writeColor, finalLightCount));
    barrier();
    memoryBarrierShared();
    ivec4 lightPosToStore = (index < lightCount && positions[index].w > 0) ? positions[index] : ivec4(0);
    imageStore(colorimg11, writeTexelCoord, lightPosToStore);
}
#endif
