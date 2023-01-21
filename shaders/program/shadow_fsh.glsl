#extension GL_ARB_shader_image_load_store : enable

#include "/lib/common.glsl"

in vec2 texCoord;
flat in int spriteSize;
in vec2 lmCoord;
in vec3 normal;
in vec4 vertexCol;
in vec3 pos;
flat in int mat;

uniform sampler2D tex;
uniform sampler2D shadowcolor1;
uniform int isEyeInWater;
uniform ivec2 atlasSize;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
#if ADVANCED_LIGHT_TRACING > 0 
#ifdef INST_LP 
layout (rgba16) uniform image2D colorimg8;
layout (rgba16) uniform image2D colorimg9;
#endif
#endif
vec2[9] offsets = vec2[9](
    vec2(0.3, -0.2), vec2(0.2, 0), vec2(0.2, 0.2), vec2(0, 0.23), vec2(-0.2, 0.4), vec2(-0.8, 0), vec2(-0.9, -0.2), vec2(0, -0.2), vec2(0, 0)
);

#include "/lib/vx/voxelMapping.glsl"

void main() {
    bool emissive, alphatest, crossmodel, cuboid, full, entity, notrace, connectSides;
    vec3 lightcol = vec3(0); // lightcol contains either light color or gl_Color.rgb
    int lightlevel = 0;
    ivec3[2] bounds = ivec3[2](ivec3(0), ivec3(16));
    if (mat != 50004) {
        #include "/lib/materials/shadowchecks_fsh.glsl"
        // check for a relatively saturated colour among the brighter parts of the texture, then use that as emission colour
        if (emissive && length(lightcol) < 0.001) {
            vec4[10] lightcols0;
            vec4 lightcol0 = texture2D(tex, texCoord);
            lightcol0.rgb *= lightcol0.a;
            const vec3 avoidcol = vec3(1); // pure white is unsaturated and should be avoided
            float avgbrightness = max(lightcol0.x, max(lightcol0.y, lightcol0.z));
            lightcol0.rgb += 0.00001;
            lightcol0.w = avgbrightness - dot(normalize(lightcol0.rgb), avoidcol);
            lightcols0[9] = lightcol0;
            float maxbrightness = avgbrightness;
            for (int i = 0; i < 9; i++) {
                lightcols0[i] = texture2D(tex, texCoord + offsets[i] * spriteSize / atlasSize);
                lightcols0[i].xyz *= lightcols0[i].w;
                lightcols0[i].xyz += 0.00001;
                float thisbrightness = max(lightcols0[i].x, max(lightcols0[i].y, lightcols0[i].z));
                avgbrightness += thisbrightness;
                maxbrightness = max(maxbrightness, thisbrightness);
                lightcols0[i].w = thisbrightness - dot(normalize(lightcols0[i].rgb), avoidcol);
            }
            avgbrightness /= 10.0;
            for (int i = 0; i < 10; i++) {
                if (lightcols0[i].w > lightcol0.w && max(lightcols0[i].x, max(lightcols0[i].y, lightcols0[i].z)) > (avgbrightness + maxbrightness) * 0.5) {
                    lightcol0 = lightcols0[i];
                }
            }
            lightcol = lightcol0.rgb / max(max(lightcol0.r, lightcol0.g), lightcol0.b) * maxbrightness;
        }
        if (emissive && isEyeInWater == 1) lightlevel = lightlevel * 4 / 3;
        if (!emissive) lightcol = vertexCol.rgb;
    }
    ivec4 packedData0 = ivec4(
        int(lightcol.r * 255.9) + int(lightcol.g * 255.9) * 256,
        int(lightcol.b * 255.9) + (int(texCoord.x * 4095) / 16) * 256,
        int(texCoord.x * 4095) % 16 + int(texCoord.y * 4095) * 16,
        mat); // material index
    bounds[1] -= 1;
    int blocktype = (alphatest ? 1 : 0) + (crossmodel ? 2 : 0) + (full ? 4 : 0) + (emissive ? 8 : 0) + (cuboid ? 16 : 0) + (notrace ? 32 : 0) + (connectSides ? 64 : 0) + (entity ? 128 : 0);
    int spritelog = 0;
    while (spriteSize >> spritelog + 1 != 0 && spritelog < 15) spritelog++;

    ivec4 packedData1 = ivec4(0);
    if (cuboid) packedData1.xy = ivec2(
        bounds[0].x + (bounds[0].y << 4) + (bounds[0].z << 8) + (bounds[1].x << 12),
        bounds[1].y + (bounds[1].z << 4)
    );
    if (entity || crossmodel) {
        packedData1.x = int(256 * fract(pos.x)) + (int(256 * fract(pos.y)) << 8);
        packedData1.y = int(256 * fract(pos.z));
    }
    #if ADVANCED_LIGHT_TRACING > 0 && defined INST_LP
    if (emissive) {
        vec3 prevPos = pos + floor(cameraPosition) - floor(previousCameraPosition);
        ivec4 prevData = ivec4(imageLoad(colorimg8, getVxPixelCoords(prevPos)) * 65535 + 0.5);
        if (prevData.x >> 8 != mat % 255 + 1) {
            for (int x = -lightlevel; x <= lightlevel; x++) {
                int dist0 = abs(x);
                for (int y = dist0 - lightlevel; y <= lightlevel - dist0; y++) {
                    int dist1 = dist0 + abs(y);
                    for (int z = dist1 - lightlevel; z <= lightlevel - dist1; z++) {
                        int dist = dist1 + abs(z);
                        vec3 otherPos = prevPos - vec3(x, y, z);
                        if (isInRange(otherPos)) {
                            ivec2 coord = getVxPixelCoords(otherPos);
                            ivec4 lightData0 = ivec4(imageLoad(colorimg8, coord) * 65535 + 0.5);
                            ivec4 lightData1 = ivec4(imageLoad(colorimg9, coord) * 65535 + 0.5);
                            if (lightData0.w >> 8 < lightlevel - dist + (length(128 + vec3(x, y, z) - vec3(lightData0.z % 256, lightData0.z >> 8, lightData0.w % 256)) < 2 ? 2 : 0)) {
                                lightData1.zw = lightData1.xy;
                                lightData1.xy = lightData0.zw;
                                lightData0.zw = ivec2(
                                    x + 128 + ((y + 128) << 8),
                                    z + 128 + ((lightlevel - dist) << 8)
                                );
                                imageStore(colorimg8, coord, lightData0 / 65535.0);
                                imageStore(colorimg9, coord, lightData1 / 65535.0);
                            } else if (lightData1.y >> 8 < lightlevel - dist + (length(128 + vec3(x, y, z) - vec3(lightData1.x % 256, lightData1.x >> 8, lightData1.y % 256)) < 2 ? 2 : 0)) {
                                lightData1.zw = lightData1.xy;
                                lightData1.xy = ivec2(
                                    x + 128 + ((y + 128) << 8),
                                    z + 128 + ((lightlevel - dist) << 8)
                                );
                                imageStore(colorimg9, coord, lightData1 / 65535.0);
                            } else if (lightData1.w >> 8 < lightlevel - dist + (length(128 + vec3(x, y, z) - vec3(lightData1.z % 256, lightData1.z >> 8, lightData1.w % 256)) < 2 ? 2 : 0)) {
                                lightData1.zw = ivec2(
                                    x + 128 + ((y + 128) << 8),
                                    z + 128 + ((lightlevel - dist) << 8)
                                );
                                imageStore(colorimg9, coord, lightData1 / 65535.0);
                            }
                        }
                    }
                }
            }
        }
    }
    #endif
    packedData1.y += (blocktype << 8);
    packedData1.zw = ivec2(
        spritelog + 16 * lightlevel + 2048 * int(lmCoord.y * 16),
        0
    );
    
    if (mat == 50004) {
        packedData0.xy = ivec2(pos.xz) + 32767;
        packedData0.zw = ivec2(0, 65535);
    }

    /*RENDERTARGETS:0,1*/
    gl_FragData[0] = vec4(packedData0) / 65535;
    gl_FragData[1] = vec4(packedData1) / 65535;
}