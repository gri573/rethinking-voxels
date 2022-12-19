#ifndef LIGHTING
#define LIGHTING
#ifndef SHADOWCOL0
#define SHADOWCOL0
uniform sampler2D shadowcolor0;
#endif
#ifndef SHADOWCOL1
#define SHADOWCOL1
uniform sampler2D shadowcolor1;
#endif
#ifndef COLORTEX8
#define COLORTEX8
uniform sampler2D colortex8;
#endif
#ifndef COLORTEX9
#define COLORTEX9
uniform sampler2D colortex9;
#endif
#ifdef SUN_SHADOWS
#ifndef COLORTEX10
#define COLORTEX10
uniform sampler2D colortex10;
#endif
#endif
#include "/lib/vx/voxelReading.glsl"
#include "/lib/vx/voxelMapping.glsl"
#include "/lib/vx/raytrace.glsl"
vec2 tex8size0 = vec2(textureSize(colortex8, 0));
//#define DEBUG_OCCLUDERS
#ifdef ADVANCED_LIGHT_TRACING
#ifndef PP_BL_SHADOWS
vec3 getOcclusion(vec3 vxPos, vec3 normal) {
    int k = 0;
    normal *= 4.0 * max(max(abs(vxPos.x) / vxRange, abs(vxPos.y) / (VXHEIGHT * VXHEIGHT)), abs(vxPos.z) / vxRange);
    // zoom in to the highest-resolution available sub map
    for (; isInRange(2 * vxPos, 1) && k < OCCLUSION_CASCADE_COUNT - 1; k++) {
        vxPos *= 2;
    }
    vec3 occlusion = vec3(0);
    #if OCCLUSION_FILTER > 0
    vxPos += normal - 0.5;
    vec3 floorPos = floor(vxPos);
    float totalInt = 1; // total intensity (calculating weighted average of surrounding occlusion data)
    for (int j = 0; j < 8; j++) {
        vec3 offset = vec3(j%2, (j>>1)%2, (j>>2)%2);
        vec3 cornerPos = floorPos + offset;
        // intensity multiplier for linear interpolation
        float intMult = (1 - abs(vxPos.x - cornerPos.x)) * (1 - abs(vxPos.y - cornerPos.y)) * (1 - abs(vxPos.z - cornerPos.z));
        // skip this corner if it is across a block boundary, to disregard dark spots on the insides of surfaces
        if (length(floor(cornerPos / float(1 << k)) - floor((vxPos + 0.5) / float(1 << k))) > 0.5) {
            totalInt -= intMult;
            continue;
        }
        #else
        vec3 cornerPos = vxPos;
        float intMult = 1.0;
        #endif
        ivec4 lightData = ivec4(texelFetch(colortex8, getVxPixelCoords(cornerPos + 0.5), 0) * 65535 + 0.5);
        for (int i = 0; i < 3; i++) occlusion[i] += ((lightData.y >> 3 * k + i) % 2) * intMult;
    #if OCCLUSION_FILTER > 0
    }
    occlusion /= totalInt;
    #endif
    return occlusion;
}
#else
vec3[3] getOcclusion(vec3 vxPos, vec3 normal, vec4[3] lights) {
    //vxPos += 0.01 * normal;
    vec3[3] occlusion = vec3[3](vec3(0), vec3(0), vec3(0));
    for (int k = 0; k < 3; k++) {
        if (dot(normal, lights[k].xyz) >= 0.0 || max(max(abs(lights[k].x), abs(lights[k].y)), lights[k].z) < 0.512) {
            vec3 endPos = vxPos;
            vec3 goalPos = vxPos + lights[k].xyz;
            vec3 offset = hash33(vxPos * 50 + 7 * frameCounter) * 2.0 - 1.0;
            lights[k].xyz += 0.1 * offset;
            int goalMat = readVxMap(goalPos).mat;
            vec4 rayColor = raytrace(endPos, lights[k].xyz, ATLASTEX, true);
            int endMat = readVxMap(endPos).mat;
            float dist = max(max(abs(endPos.x - goalPos.x), abs(endPos.y - goalPos.y)), abs(endPos.z - goalPos.z));
            if (dist < 0.5 || (lights[k].w > 1.5 && goalMat == endMat && dist < 2.5)) {
                rayColor.rgb = length(rayColor) < 0.001 ? vec3(1.0) : rayColor.rgb;
                float rayBrightness = max(max(rayColor.r, rayColor.g), rayColor.b);
                rayColor.rgb /= sqrt(rayBrightness);
                rayColor.rgb *= clamp(4 - 4 * rayColor.a, 0, 1);
                #ifdef DEBUG_OCCLUDERS
                if (frameCounter % 100 < 50) occlusion[k] = rayColor.rgb;
                else occlusion[k][k] = 1.0;
                #else
                occlusion[k] = rayColor.rgb;
                #endif
            } 
        }
    }
    return occlusion;
}
#endif
// get the blocklight value at a given position. optionally supply a normal vector to account for dot product shading
vec3 getBlockLight(vec3 vxPos, vec3 normal, int mat) {
    vec3 vxPosOld = vxPos + floor(cameraPosition) - floor(previousCameraPosition);
    if (isInRange(vxPosOld) && isInRange(vxPos)) {
        vec3 lightCol = vec3(0);
        ivec2 vxCoordsFF = getVxPixelCoords(vxPosOld);
        ivec4 lightData0 = ivec4(texelFetch(colortex8, vxCoordsFF, 0) * 65535 + 0.5);
        if (lightData0.w >> 8 == 0) return vec3(0);
        ivec4 lightData1 = (lightData0.w >> 8 > 0) ? ivec4(texelFetch(colortex9, vxCoordsFF, 0) * 65535 + 0.5) : ivec4(0);
        vec4[3] lights = vec4[3](
            vec4(lightData0.z % 256, lightData0.z >> 8, lightData0.w % 256, (lightData0.w >> 8)) - vec4(128, 128, 128, 0),
            vec4(lightData1.x % 256, lightData1.x >> 8, lightData1.y % 256, (lightData1.y >> 8)) - vec4(128, 128, 128, 0),
            vec4(lightData1.z % 256, lightData1.z >> 8, lightData1.w % 256, (lightData1.w >> 8)) - vec4(128, 128, 128, 0)
        );
        #if SMOOTH_LIGHTING == 2
        float intMult0 = (1 - abs(fract(vxPos.x) - 0.5)) * (1 - abs(fract(vxPos.y) - 0.5)) * (1 - abs(fract(vxPos.z) - 0.5));
        #endif
        vec3 ndotls;
        bvec3 isHere;
        bool calcNdotLs = (normal == vec3(0));
        vec3[3] lightCols;
        ivec3 lightMats;
        vec3 brightnesses;
        for (int k = 0; k < 3; k++) {
            lights[k].xyz += 0.5 - fract(vxPos);
            isHere[k] = (max(max(abs(lights[k].x), abs(lights[k].y)), abs(lights[k].z)) < 0.511);
            vxData lightSourceData = readVxMap(getVxPixelCoords(vxPos + lights[k].xyz));
            //if (isHere[k]) lights[k].w -= 1;
            #if SMOOTH_LIGHTING == 2
            brightnesses[k] = isHere[k] ? lights[k].w : lights[k].w * intMult0;
            #elif SMOOTH_LIGHTING == 1
            brightnesses[k] = - abs(lights[k].x) - abs(lights[k].y) - abs(lights[k].z);
            #else
            brightnesses[k] = lights[k].w;
            #endif
            ndotls[k] = ((isHere[k] && (lightSourceData.mat / 10000 * 10000 + (lightSourceData.mat % 2000) / 4 * 4 == mat || true)) || calcNdotLs) ? 1 : max(0, dot(normalize(lights[k].xyz), normal));
            lightCols[k] = lightSourceData.lightcol * (lightSourceData.emissive ? 1.0 : 0.0);
            lightMats[k] = lightSourceData.mat;
            #if SMOOTH_LIGHTING == 1
            brightnesses[k] = max(brightnesses[k] + lightSourceData.lightlevel, 0.0);
            #endif
        }
        ndotls = min(ndotls * 2, 1);
        #if SMOOTH_LIGHTING == 2
        vec3 offsetDir = sign(fract(vxPos) - 0.5);
        vec3 floorPos = floor(vxPosOld);
        for (int k = 1; k < 8; k++) {
            vec3 offset = vec3(k%2, (k>>1)%2, (k>>2)%2);
            vec3 cornerPos = floorPos + offset * offsetDir + 0.5;
            if (!isInRange(cornerPos)) continue;
            float intMult = (1 - abs(cornerPos.x - vxPosOld.x)) * (1 - abs(cornerPos.y - vxPosOld.y)) * (1 - abs(cornerPos.z - vxPosOld.z));
            ivec2 cornerVxCoordsFF = getVxPixelCoords(cornerPos);
            ivec4 cornerLightData0 = ivec4(texelFetch(colortex8, cornerVxCoordsFF, 0) * 65535 + 0.5);
            ivec4 cornerLightData1 = (cornerLightData0.w >> 8 > 0) ? ivec4(texelFetch(colortex9, cornerVxCoordsFF, 0) * 65535 + 0.5) : ivec4(0);
            vec4[3] cornerLights = vec4[3](
                vec4(cornerLightData0.z % 256, cornerLightData0.z >> 8, cornerLightData0.w % 256, (cornerLightData0.w >> 8)) - vec4(128, 128, 128, 0),
                vec4(cornerLightData1.x % 256, cornerLightData1.x >> 8, cornerLightData1.y % 256, (cornerLightData1.y >> 8)) - vec4(128, 128, 128, 0),
                vec4(cornerLightData1.z % 256, cornerLightData1.z >> 8, cornerLightData1.w % 256, (cornerLightData1.w >> 8)) - vec4(128, 128, 128, 0)
            );
            for (int j = 0; j < 3 && cornerLights[j].w > 0; j++) {
                int cornerLightMat = readVxMap(getVxPixelCoords(cornerLights[j].xyz + vxPos)).mat;
                for (int i = 0; i < 3; i++) {
                    int i0 = (i + j) % 3;
                    if (length(vec3(lights[i0].xyz - cornerLights[j].xyz - offset * offsetDir)) < (cornerLightMat == lightMats[i0] ? 1.5 : 0.5)) {
                        lights[i0].w += cornerLights[j].w * intMult * (isHere[i0] ? 0 : 1);
                        break;
                    }
                }
            }
        }
        #endif
        #ifdef PP_BL_SHADOWS
        vec3[3] occlusionData = getOcclusion(vxPos, normal, lights);
        #else
        #ifdef DEBUG_OCCLUDERS
        vec3 occlusionData0 = getOcclusion(vxPosOld, normal);
        vec3[3] occlusionData = vec3[3](vec3(occlusionData0.x, 0, 0), vec3(0, occlusionData0.y, 0), vec3(0, 0, occlusionData0.z));
        #else
        vec3 occlusionData = getOcclusion(vxPosOld, normal);
        #endif
        #endif
        for (int k = 0; k < 3; k++) lightCol += lightCols[k] * occlusionData[k] * pow(brightnesses[k] * BLOCKLIGHT_STRENGTH / 20.0, BLOCKLIGHT_STEEPNESS) * ndotls[k];
        return lightCol;
    } else return vec3(0);
}
#else
vec3 getBlockLight(vec3 vxPos, vec3 normal, int mat) {
    vxPos += normal * 0.5;
    vec3 lightCol = vec3(0);
    float totalInt = 0.0001;
    vec3 vxPosOld = vxPos + floor(cameraPosition) - floor(previousCameraPosition);
    vec3 floorPos = floor(vxPosOld);
    vec3 offsetDir = sign(fract(vxPos) - 0.5);
    for (int k = 0; k < 8; k++) {
        vec3 offset = vec3(k%2, (k>>1)%2, (k>>2)%2);
        vec3 cornerPos = floorPos + offset * offsetDir + 0.5;
        if (!isInRange(cornerPos)) continue;
        ivec2 cornerVxCoordsFF = getVxPixelCoords(cornerPos);
        vec4 cornerLightData0 = texelFetch(colortex8, cornerVxCoordsFF, 0);
        float intMult = (1 - abs(cornerPos.x - vxPosOld.x)) * (1 - abs(cornerPos.y - vxPosOld.y)) * (1 - abs(cornerPos.z - vxPosOld.z));
        lightCol += intMult * cornerLightData0.xyz;
        totalInt += intMult;
    }
    return 3 * lightCol;// / totalInt;
}
#endif

vec3 getBlockLight(vec3 vxPos) {
    return getBlockLight(vxPos, vec3(0), 0);
}
#ifdef SUN_SHADOWS

vec2[9] shadowoffsets = vec2[9](
    vec2( 0.0       ,  0.0),
    vec2( 0.47942554,  0.87758256),
    vec2( 0.95954963,  0.28153953),
    vec2( 0.87758256, -0.47942554),
    vec2( 0.28153953, -0.95954963),
    vec2(-0.47942554, -0.87758256),
    vec2(-0.95954963, -0.28153953),
    vec2(-0.87758256,  0.47942554),
    vec2(-0.28153953,  0.95954963)
);

vec3 getWorldSunVector() {
    const vec2 sunRotationData = vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994));
    #ifdef OVERWORLD
        float ang = fract(timeAngle - 0.25);
        ang = (ang + (cos(ang * 3.14159265358979) * -0.5 + 0.5 - ang) / 3.0) * 6.28318530717959;
        return vec3(-sin(ang), cos(ang) * sunRotationData) + vec3(0.00001);
    #elif defined END
        return vec3(0.0, sunRotationData) + vec3(0.00001);
    #else
        return vec3(0.0);
    #endif
}
/*
//x is solid, y is translucent, pos.xy are position on shadow map, pos.z is shadow depth
vec2 sampleShadow(sampler2D shadowMap, vec3 pos) {
    vec2 isInShadow = vec2(0);
    vec2 floorPos = floor(pos.xy);
    for (int k = 0; k < 4; k++) {
        ivec2 offset = ivec2(k % 2, k / 2 % 2);
        float intMult = (1 - abs(floorPos.x + offset.x - pos.x)) * (1 - abs(floorPos.y + offset.y - pos.y));
        vec4 sunData = texelFetch(shadowMap, ivec2(floor(pos.xy) + offset), 0);
    }
    return isInShadow;
}
*/
#ifndef PP_SUN_SHADOWS
vec3 getSunLight(bool scatter, vec3 vxPos, vec3 worldNormal, bool causticMult) {
    vec3 sunDir = getWorldSunVector();
    sunDir *= sign(sunDir.y);
    vec2 tex8size0 = vec2(textureSize(colortex8, 0));
    mat3 sunRotMat = getRotMat(sunDir);
    vec3 shadowPos = getShadowPos(vxPos, sunRotMat);
    float shadowLength = length(shadowPos.xy);//max(abs(shadowPos.x), abs(shadowPos.y));
    if (length(worldNormal) > 0.0001) {
        float dShadowdLength = distortShadowDeriv(shadowLength);
        vxPos += worldNormal / (dShadowdLength * VXHEIGHT * 2.0);
        shadowPos = getShadowPos(vxPos, sunRotMat);
        shadowLength = length(shadowPos.xy);//max(abs(shadowPos.x), abs(shadowPos.y));
    }
    shadowPos.xy *= distortShadow(shadowLength) / shadowLength;
    vec3 sunColor = vec3(0);
    #if OCCLUSION_FILTER > 0
    for (int k = 0; k < 9; k++) {
    #else
    int k = 0;
    #endif
        vec4 sunData = texture2D(colortex10, ((shadowPos.xy * 0.5 + 0.5) * shadowMapResolution + shadowoffsets[k] * 1.8) / tex8size0);
        sunData.yz = (sunData.yz - 0.5) * 1.5 * vxRange;
        int sunColor0 = int(texelFetch(colortex10, ivec2((shadowPos.xy * 0.5 + 0.5) * shadowMapResolution + shadowoffsets[k] * 1.8), 0).r * 65535 + 0.5);
        vec3 sunColor1 = vec3(sunColor0 % 16, (sunColor0 >> 4) % 16, (sunColor0 >> 8) % 16) * (causticMult ? (sunColor0 >> 12) : 4.0) / 64.0;
        vec3 sunColor2 = shadowPos.z > sunData.y ? (shadowPos.z > sunData.z ? vec3(1) : sunColor1) : sunColor1 * (scatter ? max(0.7 + shadowPos.z - sunData.y, 0) : 0);
        sunColor += sunColor2;
    #if OCCLUSION_FILTER > 0
    }
    sunColor = min(0.2 * sunColor, vec3(1.0));
    #endif
    return sunColor;
}
vec3 getSunLight(vec3 vxPos, vec3 worldNormal, bool causticMult) {
    return getSunLight(false, vxPos, worldNormal, causticMult);
}
vec3 getSunLight(bool scatter, vec3 vxPos, vec3 worldNormal) {
    return getSunLight(scatter, vxPos, worldNormal, false);
}
vec3 getSunLight(vec3 vxPos, bool causticMult) {
    return getSunLight(vxPos, vec3(0), causticMult);
}
vec3 getSunLight(vec3 vxPos, vec3 worldNormal) {
    return getSunLight(vxPos, worldNormal, false);
}
vec3 getSunLight(vec3 vxPos) {
    return getSunLight(vxPos, false);
}
#else
vec3 getSunLight(vec3 vxPos, bool doScattering) {
    vec3 sunDir = getWorldSunVector();
    sunDir *= sign(sunDir.y);
    vec3 offset = hash33(vxPos * 50 + 7 * frameCounter) * 2.0 - 1.0;
    vec4 sunColor = raytrace(vxPos, doScattering, (sunDir + 0.01 * offset) * sqrt(vxRange * vxRange + VXHEIGHT * VXHEIGHT * VXHEIGHT * VXHEIGHT), ATLASTEX);
    const float alphaSteepness = 5.0;
    float colorMult = clamp(alphaSteepness - alphaSteepness * sunColor.a, 0, 1);
    float mixFactor = clamp(alphaSteepness * sunColor.a, 0, 1);
    sunColor.rgb = mix(vec3(1), sunColor.rgb * colorMult, mixFactor);
    sunColor.rgb /= sqrt(max(max(sunColor.r, sunColor.g), max(sunColor.b, 0.0001)));
    return sunColor.rgb;
}
vec3 getSunLight(vec3 vxPos) {
    return getSunLight(vxPos, false);
}
#endif
#endif
#endif