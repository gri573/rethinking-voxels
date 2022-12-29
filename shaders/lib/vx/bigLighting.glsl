#ifndef BIG_LIGHTING
#define BIG_LIGHTING
#ifndef SHADOWCOL0
#define SHADOWCOL0
uniform sampler2D shadowcolor0;
#endif
#include "/lib/materials/lightColorSettings.glsl"
vec3 getBigLight(vec3 vxPos, vec3 normal) {
    vec3 bigLighting = vec3(0);
    ivec4 lightningData = ivec4(texelFetch(shadowcolor0, ivec2(0), 0) * 65535 + 0.5);
    if (lightningData.z == 0) {
        vec2 lightningPos = vec2(lightningData.xy - 32767);
        float NdotLightning = max(0.5, dot(normalize(vec3(normalize(lightningPos - vxPos.xz), 0.5)).xzy, normal) * 0.75 + 0.25);
        bigLighting += NdotLightning * vec3(LIGHTNING_COL_R, LIGHTNING_COL_G, LIGHTNING_COL_B) * BRIGHTNESS_LIGHTNING / length(vxPos - vec3(lightningPos, vxPos.y + 20).xzy);
    }
    for (int k = 0; k < 20; k++) {
        ivec4 beaconData = ivec4(texelFetch(shadowcolor0, ivec2(0, k), 0) * 65535 + 0.5);
        if (beaconData.z == 0) {
            vec2 beaconPos = vec2(beaconData.xy - 32767);
            vec3 beaconCol = vec3(beaconData.w % 16, beaconData.w / 16 % 16, beaconData.w / 256 % 16) / 15.0;
            float NdotBeacon = max(0.5, dot(normalize(vec3(normalize(beaconPos - vxPos.xz), 0.5)).xzy, normal) * 0.75 + 0.25);
            bigLighting += NdotBeacon * beaconCol * BRIGHTNESS_BEACONBEAM / length(vxPos - vec3(beaconPos, vxPos.y + 10).xzy);

        }
    }
    return bigLighting;
}
vec3 getBigLight(vec3 vxPos) {
    return getBigLight(vxPos, vec3(0));
}
#endif