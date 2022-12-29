//Lighting Uniforms//
uniform float darknessLightFactor;

#if HELD_LIGHTING_MODE >= 1
	uniform int heldBlockLightValue;
	uniform int heldBlockLightValue2;
#endif

//Lighting Includes//
#include "/lib/colors/lightAndAmbientColors.glsl"
#include "/lib/lighting/ggx.glsl"

#ifdef CLOUD_SHADOWS
    #include "/lib/atmospherics/cloudCoord.glsl"
#endif

#include "/lib/vx/getLighting.glsl"
#include "/lib/vx/voxelMapping.glsl"

//Lighting Variables//
float eyeBrightnessM2 = eyeBrightnessM * eyeBrightnessM;
float noonFactor20 = pow(noonFactor, 20.0);        
vec3 highlightColor = normalize(pow(lightColor, vec3(0.37))) * (0.5 + 1.3 * sunVisibility2) * (1.0 - 0.85 * rainFactor);

//Lighting//
void DoLighting(inout vec3 color, inout vec3 shadowMult, vec3 playerPos, vec3 viewPos, float lViewPos, vec3 normalM, vec2 lightmap,
                bool noSmoothLighting, bool noDirectionalShading, bool noVanillaAO, int subsurfaceMode,
                float smoothnessG, float highlightMult, float emission, int mat) {
    // Prepare Variables
    float lightmapY2 = pow2(lightmap.y);
    float lightmapYM = smoothstep1(lightmap.y);
    float subsurfaceHighlight = 0.0;
    vec3 ambientMult = vec3(1.0);
    vec3 shadowLighting = lightColor;
    vec3 nViewPos = normalize(viewPos);
    vec3 worldNormal = normalize(ViewToPlayer(normal*1000.0));
    playerPos += 0.001 * worldNormal;
    #if PIXEL_SHADOW > 0 && !defined GBUFFERS_HAND
        playerPos = floor((playerPos + cameraPosition) * PIXEL_SHADOW + 0.001) / PIXEL_SHADOW - cameraPosition + 0.5 / PIXEL_SHADOW;
    #endif
    vec3 vxPos = getVxPos(playerPos);
    vec3 previousVxPos = getPreviousVxPos(playerPos);

    #if defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING || defined DIRECTIONAL_SHADING
        float NdotN = dot(normalM, northVec);
        float absNdotN = abs(NdotN);
    #endif

    // Real-Time Shadows
    #if defined OVERWORLD || defined END
        float NdotL = dot(normalM, lightVec);
        float NdotLmax0 = max(NdotL, 0.0);
        float NdotLM = NdotLmax0 * 0.9999;

        #ifndef GBUFFERS_TEXTURED
                #ifdef GBUFFERS_TERRAIN
                    if (subsurfaceMode != 0) {
                        NdotLM = clamp(mod(subsurfaceMode, 3), 0.5, 1.0);
                    }
                #endif
            #if defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                #ifdef GBUFFERS_TERRAIN
                     else
                #endif
                NdotLM = mix(NdotLM, (NdotL + 0.4) * 0.714, absNdotN * pow2(pow2(pow2(1.0 - NdotLM))));
            #endif
        #else
            NdotLM = 1.0;
        #endif

        #if defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
            #if !defined ENTITY_SHADOWS && (defined GBUFFERS_ENTITIES || defined GBUFFERS_BLOCK)
                shadowLighting = mix(shadowLighting * 0.75, ambientColor, 0.5 * pow2(pow2(1.0 - NdotLM)));
                NdotLM = NdotLM * 0.75 + 0.25;
            #endif
        #endif

        if (shadowMult.r > 0.00001) {
            if (NdotLM > 0.0001) {
                vec3 shadowMultBeforeLighting = shadowMult;
                #ifdef SUN_SHADOWS
                float shadowLength = min(vxRange / 2.0 - abs(vxPos.x), min(VXHEIGHT * VXHEIGHT - 2.0 * abs(vxPos.y), vxRange / 2.0 - abs(vxPos.z)));

                if (shadowLength > 0.000001) {
/*                    float offset = 0.0009765;

                    vec3 playerPosM = playerPos;
                    
                    #if PIXEL_SHADOW > 0 && !defined GBUFFERS_HAND
                        playerPosM = floor((playerPosM + cameraPosition) * PIXEL_SHADOW + 0.001) / PIXEL_SHADOW - cameraPosition + 0.5 / PIXEL_SHADOW;
                    #endif
                    #ifndef GBUFFERS_TEXTURED
                        // Shadow bias without peter-panning
                        vec3 bias = worldNormal * min(0.12 + length(playerPos) / 200.0, 0.5) * (2.0 - NdotLmax0);

                        // Fix light leaking in caves
                        #ifdef GBUFFERS_TERRAIN
                            #ifdef PERPENDICULAR_TWEAKS
                                if (subsurfaceMode == 2) {
                                    bias *= vec3(0.0, 0.0, -0.75);
                                } else
                            #endif
                            if (subsurfaceMode == 1) bias *= 1.0 - lightmapYM;
                        #endif
                        if (lightmapYM < 0.999) {
                            #ifdef GBUFFERS_ENTITIES
                                vec3 centerplayerPos = floor(playerPosM + cameraPosition) - cameraPosition + 0.5;
                                playerPosM = mix(centerplayerPos, playerPosM, 0.5 + 0.5 * lightmapYM);
                            #elif defined GBUFFERS_HAND
                                playerPosM = mix(vec3(0.0), playerPosM, 0.2 + 0.8 * lightmapYM);
                            #else
                                vec3 edgeFactor = 0.2 * (0.5 - fract(playerPosM + cameraPosition + worldNormal * 0.01));

                                #ifdef GBUFFERS_WATER
                                    bias *= 0.5;
                                    playerPosM += (1.0 - lightmapYM) * edgeFactor;
                                #endif

                                playerPosM += (1.0 - pow2(pow2(max(glColor.a, lightmapYM)))) * edgeFactor;
                            #endif
                        }

                        playerPosM += bias;
                    #else
                        vec3 centerplayerPos = floor(playerPosM + cameraPosition) - cameraPosition + 0.5;
                        playerPosM = mix(centerplayerPos, playerPosM + vec3(0.0, 0.02, 0.0), lightmapYM);
                    #endif
            
                    vec3 shadowPos = calculateShadowPos(playerPosM);

                    #ifdef TAA
                        float gradientNoise = InterleavedGradientNoise();
                    #else
                        float gradientNoise = 0.5;
                    #endif

                    bool leaves = false;
                    #ifdef GBUFFERS_TERRAIN
                        if (subsurfaceMode == 0) {
                            #if defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                                offset *= 1.0 + pow2(absNdotN);
                            #endif
                        } else {
                            float VdotL = dot(nViewPos, lightVec);
                            float lightFactor = pow(max(VdotL, 0.0), 10.0) * float(isEyeInWater == 0);
                            if (subsurfaceMode == 1) {
                                offset = 0.0010235 * lightmapYM + 0.0009765;
                                shadowPos.z -= max(NdotL * 0.0001, 0.0) * lightmapYM;
                                subsurfaceHighlight = lightFactor * 0.8;
                                #ifndef SHADOW_FILTERING
                                    shadowPos.z -= 0.0002;
                                #endif
                            } else {
                                leaves = true;
                                offset = 0.0005235 * lightmapYM + 0.0009765;
                                shadowPos.z -= 0.000175 * lightmapYM;
                                subsurfaceHighlight = lightFactor * 0.6;
                                #ifndef SHADOW_FILTERING
                                    NdotLM = mix(NdotL, NdotLM, 0.5);
                                #endif
                            }
                        }
                    #endif
*/
                    #ifdef PP_SUN_SHADOWS
                    shadowMult *= getSunLight(vxPos, subsurfaceMode != 0);
                    #else
                    shadowMult *= getSunLight(subsurfaceMode != 0, previousVxPos, worldNormal);
                    #endif
                }
                #else
                float shadowLength = 0;
                #endif
                float shadowSmooth = 16.0;
                if (shadowLength < shadowSmooth) {
                    float shadowMixer = max0(shadowLength / shadowSmooth);
                    #ifdef OVERWORLD
                        float skyLightShadowMult = pow2(pow2(lightmapY2));
                    #else
                        float skyLightShadowMult = 1.0;
                    #endif
                    
                    #ifdef GBUFFERS_TERRAIN
                        if (subsurfaceMode != 0) {
                            float shadowMixerM = pow2(shadowMixer);

                            if (subsurfaceMode == 1) skyLightShadowMult *= mix(0.6 + 0.3 * pow2(noonFactor), 1.0, shadowMixerM);
                            else skyLightShadowMult *= mix(NdotL * 0.4999 + 0.5, 1.0, shadowMixerM);

                            subsurfaceHighlight *= shadowMixer;
                        }
                    #endif

                    shadowMult = mix(vec3(skyLightShadowMult * shadowMultBeforeLighting), shadowMult, shadowMixer);
                }

                #ifdef CLOUD_SHADOWS
                    if (shadowMult.r > 0.0001) {
                        vec3 worldPos = playerPos + cameraPosition;

                        float EdotL = dot(eastVec, lightVec);
                        float EdotLM = tan(acos(EdotL));

                        float distToCloudLayer1 = CLOUD_ALT1 - worldPos.y;
                        float cloudOffset1 = distToCloudLayer1 / EdotLM;
                        vec2 cloudPos1 = GetRoundedCloudCoord(ModifyTracePos(worldPos + vec3(cloudOffset1, 0,0), CLOUD_ALT1).xz);
                        float cloudSample = texture2D(gaux3, cloudPos1).r;
                        cloudSample *= clamp(distToCloudLayer1 * 0.1, 0.0, 1.0);

                        #ifdef SECOND_CLOUD_LAYER
                            float distToCloudLayer2 = CLOUD_ALT2 - worldPos.y;
                            float cloudOffset2 = distToCloudLayer2 / EdotLM;
                            vec2 cloudPos2 = GetRoundedCloudCoord(ModifyTracePos(worldPos + vec3(cloudOffset2, 0,0), CLOUD_ALT2).xz);
                            float cloudSample2 = texture2D(gaux3, cloudPos2).r;
                            cloudSample2 *= clamp(distToCloudLayer2 * 0.1, 0.0, 1.0);

                            cloudSample = max(cloudSample, cloudSample2);
                        #endif
                        
                        shadowMult *= 1.0 - 0.85 * cloudSample * sqrt3(1.0 - abs(EdotL));
                    }
                #endif
            }

            shadowMult *= max(NdotLM * shadowTime, 0.0);
        }
        #ifdef GBUFFERS_WATER
            else { // Low Quality Water
                shadowMult = vec3(pow2(lightmapY2) * max(NdotLM * shadowTime, 0.0));
            }
        #endif
    #endif

    // Blocklight
    #if HELD_LIGHTING_MODE >= 1
        vec3 heldLightR =  heldItemId <= 0 || heldItemId > 9999 ? vec3(0) : vec3(heldItemId % 16, (heldItemId >> 4) % 16, (heldItemId >> 8) % 16);
        vec3 heldLightL =  heldItemId2 <= 0 || heldItemId2 > 9999 ? vec3(0) : vec3(heldItemId2 % 16, (heldItemId2 >> 4) % 16, (heldItemId2 >> 8) % 16);
        vec3 heldLight = (heldLightR + heldLightL) / 15.0 + 0.001;
        float heldLight0 = max(heldBlockLightValue, heldBlockLightValue2);
        if (length(heldLight) > 0.5) heldLight0 = max(heldLight0, 8);
        heldLight /= max(heldLight.r, max(heldLight.g, heldLight.b));
        float lViewPosL = lViewPos;
        #if HELD_LIGHTING_MODE == 1
            heldLight0 *= 0.75;
            lViewPosL *= 1.5;
        #endif
        heldLight0 = max(0.0, (heldLight0 - lViewPosL) * 0.066666);
        heldLight *= heldLight0;
    #endif
    float lightmapXM;
    if (!noSmoothLighting) {
        float lightmapXMSteep = pow2(pow2(lightmap.x * lightmap.x))  * (2.30 - 0.25 * vsBrightness);
        float lightmapXMCalm = max((lightmap.x - 0.05) * 0.925, 0.0) * (2.00 + 0.25 * vsBrightness);
        lightmapXM = pow(lightmapXMSteep + lightmapXMCalm, 1.5);
    } else lightmapXM = lightmap.x * lightmap.x * 3.0;

    // Minimum Light
    #if !defined END && MINIMUM_LIGHT_MODE > 0
        #if MINIMUM_LIGHT_MODE == 1
            vec3 minLighting = vec3(0.05);
        #elif MINIMUM_LIGHT_MODE == 2
            vec3 minLighting = vec3(0.075 + vsBrightness * 0.145);
        #elif MINIMUM_LIGHT_MODE == 3
            vec3 minLighting = vec3(0.3);
        #elif MINIMUM_LIGHT_MODE == 4
            vec3 minLighting = vec3(0.5);
        #endif

        minLighting *= 1.0 - lightmapYM;
    #else
        vec3 minLighting = vec3(0.0);
    #endif

    // Lighting Tweaks
    #ifdef OVERWORLD
        ambientMult = vec3(mix(lightmapYM, pow2(lightmapYM) * lightmapYM, rainFactor));

        if (isEyeInWater != 1) {
            float dayFactor = lightmapY2 * (sunVisibility2 * 0.4 + (0.6 - 0.6 * pow2(invNoonFactor))) * (6.0 - 5.0 * rainFactor);
            dayFactor = max0(dayFactor - emission * 1000000.0);
            lightmapXM *= pow(max(lightmap.x, 0.001), dayFactor);

            float nightMult = 1.0 + 0.002 * max0(96.0 - lViewPos) * (1.0 - sunVisibility2);
            ambientMult *= nightMult;
            shadowLighting *= nightMult * (0.5 + 0.5 * lightmapYM);
        } else {
            lightmapXM *= 1.8;
            shadowLighting *= 0.25 + 0.75 * lightmapYM;
            minLighting *= 1.4;
        }
    #endif

    // Directional Shading
    float directionShade = 1.0;
    #ifdef DIRECTIONAL_SHADING
        if (!noDirectionalShading) {
            float NdotE = dot(normalM, eastVec);
            float absNdotE = abs(NdotE);
            float absNdotE2 = pow2(absNdotE);

            #if !defined NETHER || MC_VERSION < 11600
                float NdotUM = 0.75 + NdotU * 0.25;
            #else
                float NdotUM = 0.75 + max(NdotU, 0.0) * 0.25;
            #endif
            float NdotNM = 1.0 + 0.075 * absNdotN;
            float NdotEM = 1.0 - 0.1 * absNdotE2;
            directionShade = NdotUM * NdotEM * NdotNM;

            shadowLighting *= 1.0 + absNdotE2 * 0.75;

            #if defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                // Fake GI
                ambientColor = mix(ambientColor, shadowLighting, (0.05 + 0.03 * subsurfaceMode) * absNdotN * lightmapY2);
                //ambientColor += sunsetClearLightColor * 0.1 * pow2((dot(sunVec, eastVec) > 0.0 ? NdotE : -NdotE) + 1.0) * pow2(pow2(1.0 - nightFactor)) * invRainFactor;

                // Epic hack to get a bit more natural looking lighting during noon
                if (subsurfaceMode == 0) {
                    ambientMult = mix(
                        ambientMult,
                        shadowLighting + ambientMult * 0.25,
                        (0.65 - 0.65 * absNdotN) * absNdotE2 * (noonFactor20) * pow(lightmapYM, 128.0)
                    );
                    shadowLighting *= 1.0 + pow2(absNdotN) * noonFactor20;
                }
            #endif
        }
    #endif

    // Combine Lighting
    float shadowLength = min(vxRange / 2.0 - abs(vxPos.x), min(VXHEIGHT * VXHEIGHT - 2.0 * abs(vxPos.y), vxRange / 2.0 - abs(vxPos.z)));
    vec3 blockLighting;
    #ifdef GBUFFERS_ENTITIES
    if (length(lmCoord - vec2(240, 0) / 255) > 0.5) {
    #endif
        blockLighting = isInRange(vxPos) ? mix(getBlockLight(vxPos, worldNormal, mat), lightmapXM * blocklightCol, 1 - clamp(shadowLength / 8.0, 0, 1)) : lightmapXM * blocklightCol;
    #ifdef GBUFFERS_ENTITIES
    } else {
        blockLighting = blocklightCol * 5.0;
    }
    #endif
    vec3 bigLighting = getBigLight(vxPos, worldNormal);
    #if HELD_LIGHTING_MODE >= 1
    blockLighting = sqrt(blockLighting * blockLighting + heldLight * heldLight);
    #endif
    vec3 sceneLighting = shadowLighting * shadowMult + (ambientColor + bigLighting) * ambientMult;
    float dotSceneLighting = dot(sceneLighting, sceneLighting);
    
    // Vanilla Ambient Occlusion
    float vanillaAO = 1.0;
    if (subsurfaceMode != 0) vanillaAO = min1(glColor.a * 1.15);
    else if (!noVanillaAO) {
        #ifdef GBUFFERS_TERRAIN
            vanillaAO = pow(
                pow1_5(min1(glColor.a + 0.08)),
                1.0 + dotSceneLighting * 0.02 + max0(NdotU) * (0.15 + 0.25 * pow2(noonFactor * pow2(lightmapY2)))
            );
        #else
            vanillaAO = glColor.a;
        #endif
        vanillaAO = vanillaAO * 0.9 + 0.1;
    }

    // Night Vision
    vec3 nightVisionLighting = nightVision * vec3(0.5, 0.5, 0.75);

    // Light Highlight
    vec3 lightHighlight = vec3(0.0);
    #ifdef LIGHT_HIGHLIGHT
        float specularHighlight = GGX(normalM, nViewPos, lightVec, NdotLmax0, smoothnessG);

        specularHighlight *= highlightMult;

        lightHighlight = isEyeInWater != 1 ? shadowMult : pow(shadowMult, vec3(0.25)) * 0.35;
        lightHighlight *= (subsurfaceHighlight + specularHighlight) * highlightColor;
    #endif

    // Final Lighting
    color.rgb *= directionShade * vanillaAO * (blockLighting + sceneLighting + minLighting + nightVisionLighting) + emission;
    //color.rgb = mix(color.rgb, sceneLighting * 0.5, clamp01(0.004 * dotSceneLighting * vanillaAO)); // Extra Highlight
    color.rgb += lightHighlight;
    
    // Darkness Pulse
    color.rgb *= pow2(1.0 - darknessLightFactor);
}
