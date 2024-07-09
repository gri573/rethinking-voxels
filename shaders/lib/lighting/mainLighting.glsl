vec3 fractCamPos = cameraPositionInt.y == -98257195 ? fract(cameraPosition) : cameraPositionFract;

//Lighting Includes//
#include "/lib/colors/lightAndAmbientColors.glsl"
#include "/lib/lighting/ggx.glsl"

#if SHADOW_QUALITY > -1 && (defined OVERWORLD || defined END)
    #include "/lib/lighting/shadowSampling.glsl"
#endif

#if defined CLOUDS_REIMAGINED && defined CLOUD_SHADOWS
    #include "/lib/atmospherics/clouds/cloudCoord.glsl"
#endif

#ifdef LIGHT_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#if defined MOON_PHASE_INF_LIGHT || defined MOON_PHASE_INF_REFLECTION
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

#if defined PER_PIXEL_LIGHT && !defined GBUFFERS_WATER
    uniform sampler2D colortex12;
    #ifdef BLOCKLIGHT_HIGHLIGHT
        uniform sampler2D colortex14;
    #endif
#endif
#include "/lib/vx/irradianceCache.glsl"

#include "/lib/materials/shadowChecks.glsl"

vec3 highlightColor = normalize(pow(lightColor, vec3(0.37))) * (0.3 + 1.5 * sunVisibility2) * (1.0 - 0.85 * rainFactor);

//Lighting//
void DoLighting(inout vec4 color, inout vec3 shadowMult, vec3 playerPos, vec3 viewPos, float lViewPos, vec3 geoNormal, vec3 normalM,
                vec3 worldGeoNormal, vec2 lightmap, bool noSmoothLighting, bool noDirectionalShading, bool noVanillaAO,
                bool centerShadowBias, int subsurfaceMode, float smoothnessG, float materialMask, float highlightMult, float emission) {
    float lightmapY2 = pow2(lightmap.y);
    float lightmapYM = smoothstep1(lightmap.y);
    float subsurfaceHighlight = 0.0;
    float ambientMult = 1.0;
    vec3 lightColorM = lightColor;
    vec3 ambientColorM = ambientColor;
    vec3 nViewPos = normalize(viewPos);

    vec3 vxPos = playerPos + fractCamPos;
    vec3 worldNormalM = mat3(gbufferModelViewInverse) * normalM;
    #if PIXEL_SHADOW > 0 && !defined GBUFFERS_HAND
        vxPos = floor(vxPos * PIXEL_SHADOW + 0.001) / PIXEL_SHADOW + 0.5 / PIXEL_SHADOW;
    #endif
    float voxelFactor = pow(min(1, 2 * infnorm(vxPos/voxelVolumeSize)), 10);

    #if defined LIGHT_COLOR_MULTS && !defined GBUFFERS_WATER // lightColorMult is defined early in gbuffers_water
        lightColorMult = GetLightColorMult();
    #endif

    #ifdef OVERWORLD
        float skyLightShadowMult = pow2(pow2(lightmapY2));
    #else
        float skyLightShadowMult = 1.0;
    #endif

    #if defined SIDE_SHADOWING || defined DIRECTIONAL_SHADING
        float NdotN = dot(normalM, northVec);
        float absNdotN = abs(NdotN);
    #endif

    #if defined CUSTOM_PBR || defined GENERATED_NORMALS
        float NPdotU = abs(dot(geoNormal, upVec));
    #endif

    // Shadows
    #if defined OVERWORLD || defined END
        float NdotL = dot(normalM, lightVec);
        #ifdef GBUFFERS_WATER
            //NdotL = mix(NdotL, 1.0, 1.0 - color.a);
        #endif
        #ifdef CUSTOM_PBR
            float geoNdotL = dot(geoNormal, lightVec);
            float geoNdotLM = geoNdotL > 0.0 ? geoNdotL * 10.0 : geoNdotL;
            NdotL = min(geoNdotLM, NdotL);

            NdotL *= 1.0 - 0.7 * (1.0 - pow2(pow2(NdotUmax0))) * NPdotU;
        #endif
        #if SHADOW_QUALITY == -1 && defined GBUFFERS_TERRAIN || defined DREAM_TWEAKED_LIGHTING
            if (subsurfaceMode == 1) {
                NdotU = 1.0;
                NdotUmax0 = 1.0;
                NdotL = dot(upVec, lightVec);
            } else if (subsurfaceMode == 2) {
                highlightMult *= NdotL;
                NdotL = mix(NdotL, 1.0, 0.35);
            }

            subsurfaceMode = 0;
        #endif
        float NdotLmax0 = max0(NdotL);
        float NdotLM = NdotLmax0 * 0.9999;

        #ifndef GBUFFERS_TEXTURED
            #if defined GBUFFERS_TERRAIN
                if (subsurfaceMode != 0) {
                    #if defined CUSTOM_PBR && defined POM && POM_QUALITY >= 128 && POM_LIGHTING_MODE == 2
                        shadowMult *= max(pow2(pow2(dot(normalM, geoNormal))), sqrt2(NdotLmax0));
                    #endif
                    NdotLM = 1.0;
                }
                #ifdef SIDE_SHADOWING
                    else
                #endif
            #endif
            #ifdef SIDE_SHADOWING
                NdotLM = max0(NdotL + 0.4) * 0.714;

                #ifdef END
                    NdotLM = sqrt3(NdotLM);
                #endif
            #endif
        #else
            NdotLM = 1.0;
        #endif

        #if ENTITY_SHADOWS_DEFINE == -1 && (defined GBUFFERS_ENTITIES || defined GBUFFERS_BLOCK)
            lightColorM = mix(lightColorM * 0.75, ambientColorM, 0.5 * pow2(pow2(1.0 - NdotLM)));
            NdotLM = NdotLM * 0.75 + 0.25;
        #endif

        if (shadowMult.r > 0.00001) {
            #if SHADOW_QUALITY > -1
                if (NdotLM > 0.0001) {
                    vec3 shadowMultBeforeLighting = shadowMult;
                    float shadowLength = min(shadowDistance, far) * 0.9166667 - lViewPos; //consistent08JJ622

                    if (shadowLength > 0.000001) {
                        #if SHADOW_SMOOTHING == 4 || SHADOW_QUALITY == 0
                            float offset = 0.00098;
                        #elif SHADOW_SMOOTHING == 3
                            float offset = 0.00075;
                        #elif SHADOW_SMOOTHING == 2
                            float offset = 0.0005;
                        #elif SHADOW_SMOOTHING == 1
                            float offset = 0.0003;
                        #endif

                        vec3 playerPosM = playerPos;

                        #if PIXEL_SHADOW > 0 && !defined GBUFFERS_HAND
                            playerPosM = floor((playerPosM + cameraPosition) * PIXEL_SHADOW + 0.001) / PIXEL_SHADOW - cameraPosition + 0.5 / PIXEL_SHADOW;
                        #endif

                        #ifndef GBUFFERS_TEXTURED
                            // Shadow bias without peter-panning
                            float distanceBias = pow(dot(playerPos, playerPos), 0.75);
                            distanceBias = 0.12 + 0.0008 * distanceBias;
                            vec3 bias = worldGeoNormal * distanceBias * (2.0 - 0.95 * NdotLmax0); // 0.95 fixes pink petals noon shadows

                            #ifdef GBUFFERS_TERRAIN
                                if (subsurfaceMode == 2) {
                                    bias *= vec3(0.0, 0.0, -0.75);
                                } else if (subsurfaceMode == 1) {
                                    bias = vec3(0.0);
                                    centerShadowBias = true;
                                }
                            #endif

                            // Fix light leaking in caves
                            if (lightmapYM < 0.999) {
                                #ifdef GBUFFERS_HAND
                                    playerPosM = mix(vec3(0.0), playerPosM, 0.2 + 0.8 * lightmapYM);
                                #else
                                    if (centerShadowBias) {
                                        #ifdef OVERWORLD
                                            vec3 centerPos = floor(playerPosM + cameraPosition) - cameraPosition + 0.5;
                                            playerPosM = mix(centerPos, playerPosM, 0.5 + 0.5 * lightmapYM);
                                        #endif
                                    } else {
                                        vec3 edgeFactor = 0.2 * (0.5 - fract(playerPosM + cameraPosition + worldGeoNormal * 0.01));

                                        #ifdef GBUFFERS_WATER
                                            bias *= 0.7;
                                            playerPosM += (1.0 - lightmapYM) * edgeFactor;
                                        #endif

                                        playerPosM += (1.0 - pow2(pow2(max(glColor.a, lightmapYM)))) * edgeFactor;
                                    }
                                #endif
                            }

                            playerPosM += bias;
                        #else
                            vec3 centerplayerPos = floor(playerPosM + cameraPosition) - cameraPosition + 0.5;
                            playerPosM = mix(centerplayerPos, playerPosM + vec3(0.0, 0.02, 0.0), lightmapYM);
                        #endif

                        vec3 shadowPos = GetShadowPos(playerPosM);

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
                                } else if (subsurfaceMode == 2) {
                                    leaves = true;
                                    offset = 0.0005235 * lightmapYM + 0.0009765;
                                    shadowPos.z -= 0.000175 * lightmapYM;
                                    subsurfaceHighlight = lightFactor * 0.6;
                                    #ifndef SHADOW_FILTERING
                                        NdotLM = mix(NdotL, NdotLM, 0.5);
                                    #endif
                                } else {
                                    
                                }
                            }
                        #endif

                        shadowMult *= GetShadow(shadowPos, lViewPos, lightmap.y, offset, leaves);
                    }

                    float shadowSmooth = 16.0;
                    if (shadowLength < shadowSmooth) {
                        float shadowMixer = max0(shadowLength / shadowSmooth);

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
                }
            #else
                shadowMult *= skyLightShadowMult;
            #endif

            #ifdef CLOUD_SHADOWS
                vec3 worldPos = playerPos + cameraPosition;

                #ifdef CLOUDS_REIMAGINED
                    float EdotL = dot(eastVec, lightVec);
                    float EdotLM = tan(acos(EdotL));

                    #if SUN_ANGLE != 0
                        float NVdotLM = tan(acos(dot(northVec, lightVec)));
                    #endif

                    float distToCloudLayer1 = cloudAlt1i - worldPos.y;
                    vec3 cloudOffset1 = vec3(distToCloudLayer1 / EdotLM, 0.0, 0.0);
                    #if SUN_ANGLE != 0
                        cloudOffset1.z += distToCloudLayer1 / NVdotLM;
                    #endif
                    vec2 cloudPos1 = GetRoundedCloudCoord(ModifyTracePos(worldPos + cloudOffset1, cloudAlt1i).xz, 0.35);
                    float cloudSample = texture2D(gaux4, cloudPos1).b;
                    cloudSample *= clamp(distToCloudLayer1 * 0.1, 0.0, 1.0);

                    #ifdef DOUBLE_REIM_CLOUDS
                        float distToCloudLayer2 = cloudAlt2i - worldPos.y;
                        vec3 cloudOffset2 = vec3(distToCloudLayer2 / EdotLM, 0.0, 0.0);
                        #if SUN_ANGLE != 0
                            cloudOffset2.z += distToCloudLayer2 / NVdotLM;
                        #endif
                        vec2 cloudPos2 = GetRoundedCloudCoord(ModifyTracePos(worldPos + cloudOffset2, cloudAlt2i).xz, 0.35);
                        float cloudSample2 = texture2D(gaux4, cloudPos2).b;
                        cloudSample2 *= clamp(distToCloudLayer2 * 0.1, 0.0, 1.0);

                        cloudSample = max(cloudSample, cloudSample2);
                    #endif

                    cloudSample *= sqrt3(1.0 - abs(EdotL));
                    shadowMult *= 1.0 - 0.85 * cloudSample;
                #else
                    vec2 csPos = worldPos.xz + worldPos.y * 0.25;
                    csPos.x += syncedTime;
                    csPos *= 0.000002 * CLOUD_UNBOUND_SIZE_MULT;

                    vec2 shadowoffsets[8] = vec2[8](
                        vec2( 0.0   , 1.0   ),
                        vec2( 0.7071, 0.7071),
                        vec2( 1.0   , 0.0   ),
                        vec2( 0.7071,-0.7071),
                        vec2( 0.0   ,-1.0   ),
                        vec2(-0.7071,-0.7071),
                        vec2(-1.0   , 0.0   ),
                        vec2(-0.7071, 0.7071));
                    float cloudSample = 0.0;
                    for (int i = 0; i < 8; i++) {
                        cloudSample += texture2D(noisetex, csPos + 0.005 * shadowoffsets[i]).b;
                    }

                    shadowMult *= smoothstep1(pow2(min1(cloudSample * 0.2)));
                #endif
            #endif

            shadowMult *= max(NdotLM * shadowTime, 0.0);
        }
        #ifdef GBUFFERS_WATER
            else { // Low Quality Water
                shadowMult = vec3(pow2(lightmapY2) * max(NdotLM * shadowTime, 0.0));
            }
        #endif
    #endif

    // Blocklight
    float lightmapXM;
    if (!noSmoothLighting) {
        float lightmapXMSteep = pow2(pow2(lightmap.x * lightmap.x))  * (3.8 - 0.6 * vsBrightness);
        float lightmapXMCalm = (lightmap.x) * (1.8 + 0.6 * vsBrightness);
        lightmapXM = pow(lightmapXMSteep + lightmapXMCalm, 2.25);
    } else lightmapXM = pow2(lightmap.x) * lightmap.x * 10.0;

    #if BLOCKLIGHT_FLICKERING > 0
        vec2 flickerNoise = texture2D(noisetex, vec2(frameTimeCounter * 0.06)).rb;
        lightmapXM *= mix(1.0, min1(max(flickerNoise.r, flickerNoise.g) * 1.7), pow2(BLOCKLIGHT_FLICKERING * 0.1));
    #endif

    vec3 blockLighting = lightmapXM * blocklightCol;

    // Minimum Light
    #if !defined END && MINIMUM_LIGHT_MODE > 0
        #if MINIMUM_LIGHT_MODE == 1
            vec3 minLighting = vec3(0.0038);
        #elif MINIMUM_LIGHT_MODE == 2
            vec3 minLighting = vec3(0.005625 + vsBrightness * 0.043);
        #elif MINIMUM_LIGHT_MODE == 3
            vec3 minLighting = vec3(0.0625);
        #elif MINIMUM_LIGHT_MODE >= 4
            vec3 minLighting = vec3(0.07 * pow2(MINIMUM_LIGHT_MODE - 2.5));
        #endif
        minLighting *= vec3(0.45, 0.475, 0.6);
        minLighting *= 1.0 - lightmapYM;
    #else
        vec3 minLighting = vec3(0.0);
    #endif

    minLighting += nightVision * vec3(0.5, 0.5, 0.75);

    // Lighting Tweaks
    #ifdef OVERWORLD
        ambientMult = mix(lightmapYM, pow2(lightmapYM) * lightmapYM, rainFactor);

        #ifdef GI
            ambientMult = mix(1, ambientMult, voxelFactor);
        #endif

        #if SHADOW_QUALITY == -1
            float tweakFactor = 1.0 + 0.6 * (1.0 - pow2(pow2(pow2(noonFactor))));
            lightColorM /= tweakFactor;
            ambientMult *= mix(tweakFactor, 1.0, 0.5 * NdotUmax0);
        #endif

        #if AMBIENT_MULT != 100
            #define AMBIENT_MULT_M (AMBIENT_MULT - 100) * 0.006
            vec3 shadowMultP = shadowMult / (0.1 + 0.9 * sqrt2(max0(NdotLM)));
            ambientMult *= 1.0 + pow2(pow2(max0(1.0 - dot(shadowMultP, shadowMultP)))) * AMBIENT_MULT_M *
                           (0.5 + 0.2 * sunFactor + 0.8 * noonFactor) * (1.0 - rainFactor * 0.5);
        #endif

        if (isEyeInWater != 1) {
            float lxFactor = (sunVisibility2 * 0.4 + (0.6 - 0.6 * pow2(invNoonFactor))) * (6.0 - 5.0 * rainFactor);
            lxFactor *= lightmapY2 + lightmapY2 * 2.0 * pow2(shadowMult.r);
            lxFactor = max0(lxFactor - emission * 1000000.0);
            blockLighting *= pow(lightmapXM / 60.0 + 0.001, 0.09 * lxFactor);

            // Less light in the distance / more light closer to the camera during rain or night to simulate thicker fog
            float rainLF = 0.1 * rainFactor;
            float lightFogTweaks = 1.0 + max0(96.0 - lViewPos) * (0.002 * (1.0 - sunVisibility2) + 0.0104 * rainLF) - rainLF;
            ambientMult *= lightFogTweaks;
            lightColorM *= lightFogTweaks;
        }
    #endif

    #ifdef GBUFFERS_HAND
        ambientMult *= 1.3; // To improve held map visibility
    #endif

    // Directional Shading
    float directionShade = 1.0;
    #ifdef DIRECTIONAL_SHADING
        if (!noDirectionalShading) {
            float NdotE = dot(normalM, eastVec);
            float absNdotE = abs(NdotE);
            float absNdotE2 = pow2(absNdotE);

            #if !defined NETHER
                float NdotUM = 0.75 + NdotU * 0.25;
            #else
                float NdotUM = 0.75 + abs(NdotU + 0.5) * 0.16666;
            #endif
            float NdotNM = 1.0 + 0.075 * absNdotN;
            float NdotEM = 1.0 - 0.1 * absNdotE2;
            directionShade = NdotUM * NdotEM * NdotNM;

            #ifdef OVERWORLD
                lightColorM *= 1.0 + absNdotE2 * 0.75;
            #elif defined NETHER
                directionShade *= directionShade;
                ambientColorM += lavaLightColor * pow2(absNdotN * 0.5 + max0(-NdotU)) * (0.7 + 0.35 * vsBrightness);
            #endif

            #if defined CUSTOM_PBR || defined GENERATED_NORMALS
                float cpbrAmbFactor = NdotN * NPdotU;
                cpbrAmbFactor = 1.0 - 0.3 * cpbrAmbFactor;
                ambientColorM *= cpbrAmbFactor;
                minLighting *= cpbrAmbFactor;
            #endif

            #if defined OVERWORLD && defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                // Fake bounced light
                ambientColorM = mix(ambientColorM, lightColorM, (0.05 + 0.03 * subsurfaceMode) * absNdotN * lightmapY2);

                // Get a bit more natural looking lighting during noon
                lightColorM *= 1.0 + max0(1.0 - subsurfaceMode) * pow(noonFactor, 20.0) * (pow2(absNdotN) - absNdotE2 * 0.1);
            #endif
        }
    #endif

    #ifdef DREAM_TWEAKED_LIGHTING
        ambientColorM = mix(ambientColorM, lightColorM, 0.25) * 1.5;
        lightColorM = lightColorM * 0.3;
    #endif

    // Voxel-based Lighting
    vec3 voxelBlockLighting =
        #if defined PER_PIXEL_LIGHT && !defined GBUFFERS_WATER
            4.0 * texelFetch(colortex12, ivec2(gl_FragCoord.xy), 0).rgb;
        #else
            4.0 * readSurfaceVoxelBlocklight(vxPos, worldNormalM);
        #endif
    #if defined PER_PIXEL_LIGHT && !defined GBUFFERS_WATER && !defined GBUFFERS_HAND
        float allowPerPixelLight = 1.0;
        vec4 normalDepthData = texelFetch(colortex8, ivec2(gl_FragCoord), 0);
        if (length(normalDepthData.rgb - worldNormalM) > 0.3 || abs(1.0 - normalDepthData.a - gl_FragCoord.z) > 0.001) {
            voxelBlockLighting = 4.0 * readSurfaceVoxelBlocklight(vxPos, worldNormalM);
            allowPerPixelLight = 0.0;
        }
    #endif
    #ifdef GI
        vec3 giLighting = 1.8 * readIrradianceCache(vxPos, mat3(gbufferModelViewInverse) * normalM) * GI_STRENGTH;
        float lGiLighting = length(giLighting);
        if (lGiLighting > 0.01) giLighting *= log(lGiLighting + 1.0) / lGiLighting;

        #ifdef OVERWORLD
            float vanillaAmbience = mix(lightmapYM, pow2(lightmapYM) * lightmapYM, rainFactor);
        #else
            float vanillaAmbience = 1.0;
        #endif
        ambientColorM = mix(max(giLighting, ambientColorM * vanillaAmbience * GI_AMBIENT_MIN), ambientColorM, voxelFactor);
    #endif

    int localMat = 
    #if defined GBUFFERS_TERRAIN || defined GBUFFERS_WATER
        mat;
    #elif defined GBUFFERS_BLOCK
        blockEntityId;
    #elif defined GBUFFERS_ENTITIES
        entityId;
    #else
        0;
    #endif

    if (isEmissive(localMat)) {
        voxelBlockLighting = max(blockLighting, voxelBlockLighting * max(0.0, 1.0 - voxelFactor));
    }

    // Combine Lighting
    blockLighting = mix(voxelBlockLighting, blockLighting, voxelFactor);
    vec3 sceneLighting = lightColorM * shadowMult + ambientColorM * ambientMult;

    float dotSceneLighting = dot(sceneLighting, sceneLighting);

    blockLighting *= XLIGHT_I;

    #ifdef LIGHT_COLOR_MULTS
        sceneLighting *= lightColorMult;
    #endif
    #ifdef MOON_PHASE_INF_LIGHT
        sceneLighting *= moonPhaseInfluence;
    #endif

    // Vanilla Ambient Occlusion
    float vanillaAO = 1.0;
    #if VANILLAAO_I > 0
        if (subsurfaceMode != 0) vanillaAO = min1(glColor.a * 1.15);
        else if (!noVanillaAO) {
            #ifdef GBUFFERS_TERRAIN
                vanillaAO = min1(glColor.a + 0.08);
                #ifdef OVERWORLD
                    vanillaAO = pow(
                        pow1_5(vanillaAO),
                        1.0 + dotSceneLighting * 0.02 + NdotUmax0 * (0.15 + 0.25 * pow2(noonFactor * pow2(lightmapY2)))
                    );
                #elif defined NETHER
                    vanillaAO = pow(
                        pow1_5(vanillaAO),
                        1.0 + NdotUmax0 * 0.5
                    );
                #else
                    vanillaAO = pow(
                        vanillaAO,
                        0.75 + NdotUmax0 * 0.25
                    );
                #endif
            #else
                vanillaAO = glColor.a;
            #endif
            vanillaAO = vanillaAO * 0.9 + 0.1;

            #if VANILLAAO_I != 100
                #define VANILLAAO_IM VANILLAAO_I * 0.01
                vanillaAO = pow(vanillaAO, VANILLAAO_IM);
            #endif
        }
    #endif

    // Light Highlight
    vec3 lightHighlight = vec3(0.0);
    #ifdef LIGHT_HIGHLIGHT
        float specularHighlight = GGX(normalM, nViewPos, lightVec, NdotLmax0, smoothnessG);

        specularHighlight *= highlightMult;

        lightHighlight = isEyeInWater != 1 ? shadowMult : pow(shadowMult, vec3(0.25)) * 0.35;
        lightHighlight *= (subsurfaceHighlight + specularHighlight) * highlightColor;

        #ifdef LIGHT_COLOR_MULTS
            lightHighlight *= lightColorMult;
        #endif
        #ifdef MOON_PHASE_INF_REFLECTION
            lightHighlight *= pow2(moonPhaseInfluence);
        #endif
    #endif

    #if defined BLOCKLIGHT_HIGHLIGHT && defined PER_PIXEL_LIGHT && !defined GBUFFERS_WATER
        #ifdef GBUFFERS_HAND
            const float allowPerPixelLight = 1.0;
        #endif
        vec3 blocklightHighlight = allowPerPixelLight * 4 * texelFetch(colortex14, texelCoord, 0).rgb;
        #ifdef CUSTOM_PBR
            #if RP_MODE == 2 // seusPBR
                float metalness = materialMask * 255.1 < 240.0 ? materialMask * 255.1/240.0 : 0.0;
            #elif RP_MODE == 3 // labPBR
                float metalness = float(materialMask > 230.0/255.1 && materialMask < 241.0 / 255.1);
            #else
                float metalness = 0.0;
            #endif
            blocklightHighlight *= mix(vec3(1.0), pow2(color.rgb / infnorm(color.rgb + 0.0001)), metalness);
        #endif
        lightHighlight += blocklightHighlight;
    #endif
    // Mix Colors
    vec3 finalDiffuse = pow2(directionShade * vanillaAO) * (blockLighting + pow2(sceneLighting) + minLighting) + pow2(emission);
    finalDiffuse = sqrt(max(finalDiffuse, vec3(0.0))); // sqrt() for a bit more realistic light mix, max() to prevent NaNs

    // Apply Lighting
    color.rgb *= finalDiffuse;
    color.rgb += lightHighlight;
    color.rgb *= pow2(1.0 - darknessLightFactor);
}
