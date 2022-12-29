#include "/lib/colors/lightAndAmbientColors.glsl"
#include "/lib/atmospherics/sky.glsl"
#include "/lib/atmospherics/cloudCoord.glsl"
#include "/lib/vx/bigLighting.glsl"

const float cloudStretch = CLOUD_STRETCH;
const float cloudHeight  = cloudStretch * 2.0;

/*float cloudColorFactor = pow2(min(max(SdotU + 0.07, 0.0) / 0.09, 1.0));
vec3 cloudDayLightColor = mix(vec3(1.0), pow(lightColor, vec3(cloudColorFactor * 0.5)) * 0.5, invNoonFactor);
vec3 cloudLightColor   =  mix(lightColor * 0.7, cloudDayLightColor, sunVisibility);
vec3 cloudAmbientColor = mix(nightClearLightColor * 0.3, ambientColor * 0.5, cloudColorFactor);*/
vec3 cloudRainColor = mix(nightMiddleSkyColor, dayMiddleSkyColor, sunFactor) * 0.6;
vec3 cloudAmbientColor = mix(ambientColor * (sunVisibility2 * 0.65 + 0.35), cloudRainColor * 0.5, rainFactor);
vec3 cloudLightColor   = mix(lightColor * (0.9 + 0.2 * noonFactor), cloudRainColor, rainFactor);

#if CLOUD_QUALITY >= 3
    float InterleavedGradientNoise() {
        float n = 52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y);
        #ifdef TAA
            return fract(n + 1.61803398875 * mod(float(frameCounter), 3600.0));
        #else
            return fract(n);
        #endif
    }
#endif

#if CLOUD_QUALITY >= 2
    vec3 GetShadowOnCloudPosition(vec3 tracePos) {
        vec3 wpos = PlayerToShadow(tracePos - cameraPosition);
        float distb = sqrt(wpos.x * wpos.x + wpos.y * wpos.y);
        float distortFactor = 1.0 - shadowMapBias + distb * shadowMapBias;
        vec3 shadowPosition = vec3(vec2(wpos.xy / distortFactor), wpos.z * 0.2);
        return shadowPosition * 0.5 + 0.5;
    }

    bool GetShadowOnCloud(vec3 tracePos, float cloudAltitude, float lowerPlaneAltitude, float higherPlaneAltitude) {
        const float cloudShadowOffset = 0.5;

        vec3 shadowPosition0 = GetShadowOnCloudPosition(tracePos);
        if (length(shadowPosition0.xy * 2.0 - 1.0) < 1.0) {
            float shadowsample0 = shadow2D(shadowtex0, shadowPosition0).z;

            if (shadowsample0 == 0.0) return true;
        }

        return false;
    }
#endif

bool GetCloudNoise(vec3 tracePos, float cloudAltitude) {
    vec2 coord = GetRoundedCloudCoord(ModifyTracePos(tracePos.xyz, cloudAltitude).xz);
    
    float noise = texture2D(colortex3, coord).r;
    float threshold = clamp(abs(cloudAltitude - tracePos.y) / cloudStretch, 0.001, 0.999);
    threshold = pow2(pow2(pow2(threshold)));
    return noise > (threshold * 0.5 + 0.25);
}

vec4 GetVolumetricClouds(float cloudAltitude, float distanceThreshold, inout float cloudLinearDepth, bool sun, float sky, vec3 playerPos, float lViewPos, float VdotS, float VdotU, float dither) {
	vec4 volumetricClouds = vec4(0.0);
    vec3 nPlayerPos = normalize(playerPos);
    if (lViewPos >= far * 1.5) lViewPos = 1000000000.0;

    float higherPlaneAltitude = cloudAltitude + cloudStretch;
    float lowerPlaneAltitude  = cloudAltitude - cloudStretch;

    float lowerPlaneDistance  = (lowerPlaneAltitude - cameraPosition.y) / nPlayerPos.y;
    float higherPlaneDistance = (higherPlaneAltitude - cameraPosition.y) / nPlayerPos.y;
    float minPlaneDistance = min(lowerPlaneDistance, higherPlaneDistance);
          minPlaneDistance = max(minPlaneDistance, 0.0);
    float maxPlaneDistance = max(lowerPlaneDistance, higherPlaneDistance);
          maxPlaneDistance = min(maxPlaneDistance, distanceThreshold);
    if (maxPlaneDistance < 0.0) return vec4(0.0);
    float planeDistanceDif = maxPlaneDistance - minPlaneDistance;

    #if CLOUD_QUALITY >= 4
        int sampleCount = max(int(planeDistanceDif), 12);
    #else
        int sampleCount = max(int(planeDistanceDif) / 8, 12);
    #endif

    float stepMult = planeDistanceDif / sampleCount;
    vec3 tracePos = cameraPosition + minPlaneDistance * nPlayerPos;
    vec3 traceAdd = nPlayerPos * stepMult;
    tracePos += traceAdd * dither;
    tracePos.y -= traceAdd.y;

    float VdotSM = sunVisibility > 0.5 ? VdotS : - VdotS;
          VdotSM = max0(VdotSM) * shadowTime * 0.25;

    float skyMult1 = 1.0 - 0.2 * (1.0 - sky) * max(sunVisibility2, nightFactor);
    float skyMult2 = 1.0 - 0.33333 * sky;
    float skyMult3 = pow2(sky * 3.333333 - 2.333333);

    for (int i = 0; i < sampleCount; i++) {
        tracePos += traceAdd;

        vec3 cloudPlayerPos = tracePos - cameraPosition;
        float lTracePos = length(cloudPlayerPos);
        float cloudMult = 1.0;
        if (lTracePos > distanceThreshold) break;
        if (lTracePos > lViewPos - 1.0) {
            if (sky < 0.7) continue;
            else cloudMult = skyMult3;
        }

        if (GetCloudNoise(tracePos.xyz, cloudAltitude)) {
            float lightMult = 1.0;
            #if CLOUD_QUALITY >= 2
                if (GetShadowOnCloud(tracePos, cloudAltitude, lowerPlaneAltitude, higherPlaneAltitude)) {
                    if (eyeBrightness.y != 240) continue;
                    else {
                        lightMult = 0.25;
                    }
                }
            #endif

            float cloudShading = 1.0 - (higherPlaneAltitude - tracePos.y) / cloudHeight;

            #if CLOUD_QUALITY >= 3
                float cloudShadingM = 1.0 - pow2(cloudShading);

                float gradientNoise = InterleavedGradientNoise();

                vec3 cLightPos = ModifyTracePos(tracePos.xyz, cloudAltitude);
                vec3 cLightPosAdd = normalize(ViewToPlayer(lightVec * 1000000000.0)) * vec3(0.08);
                cLightPosAdd *= shadowTime;

                float light = 2.0;
                cLightPos += (1.0 + gradientNoise) * cLightPosAdd;
                light -= texture2D(colortex3, GetRoundedCloudCoord(cLightPos.xz)).r * cloudShadingM;
                cLightPos += gradientNoise * cLightPosAdd;
                light -= texture2D(colortex3, GetRoundedCloudCoord(cLightPos.xz)).r * cloudShadingM;
                
                if (sunVisibility < 0.5) VdotSM = -VdotSM;
                float VdotSM2 = VdotSM + 0.5 * cloudShading + 0.08;
                cloudShading = VdotSM2 * light * lightMult;
                vec3 cloudBlColor = 2.0 * getBigLight(tracePos - floor(cameraPosition));
            #else
                vec3 cloudBlColor = vec3(0.0);
            #endif

            vec3 colorSample = cloudBlColor + cloudAmbientColor + cloudLightColor * (0.07 + cloudShading);
			vec3 cloudSkyColor = GetSky(VdotU, VdotS, dither, true, false);
            float cloudFogFactor = clamp((distanceThreshold - lTracePos) / distanceThreshold, 0.0, 0.75);
            colorSample = mix(cloudSkyColor, colorSample * skyMult1, cloudFogFactor * skyMult2);
            colorSample *= pow2(1.0 - max(blindness, darknessFactor));
            
            cloudLinearDepth = sqrt(lTracePos / far);
            volumetricClouds.a = pow(cloudFogFactor * 1.33333, 0.5 + float(sun)) * cloudMult;
            volumetricClouds.rgb = colorSample;
            break;
        }
    }

    return volumetricClouds;
}
