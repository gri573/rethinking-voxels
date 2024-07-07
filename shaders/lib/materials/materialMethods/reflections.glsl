#ifdef OVERWORLD
    #include "/lib/atmospherics/sky.glsl"
#endif
#if defined END && defined DEFERRED1
    #include "/lib/atmospherics/enderBeams.glsl"
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif
#ifdef VOXEL_RT_REFLECTIONS
    #include "/lib/vx/voxelReading.glsl"
    #include "/lib/vx/irradianceCache.glsl"
    #include "/lib/colors/lightAndAmbientColors.glsl"
    #if defined DEFERRED1 && defined REALTIME_SHADOWS && defined OVERWORLD
        #include "/lib/lighting/shadowSampling.glsl"
    #endif
#endif

vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}

vec3 refPos = vec3(0.0);

vec4 GetReflection(vec3 normalM, vec3 viewPos, vec3 nViewPos, vec3 playerPos, float lViewPos, float z0,
                   sampler2D depthtex, float dither, float skyLightFactor, float fresnel,
                   float smoothness, vec3 geoNormal, vec3 color, vec3 shadowMult, float highlightMult) {
    // Step 1: Prepare
    vec2 rEdge = vec2(0.6, 0.53);
    vec3 normalMR = normalM;

    #if defined GBUFFERS_WATER && WATER_STYLE == 1 && defined GENERATED_NORMALS
        normalMR = mix(geoNormal, normalM, 0.05);
    #endif

    vec3 nViewPosR = reflect(nViewPos, normalMR);
    float RVdotU = dot(normalize(nViewPosR), upVec);
    float RVdotS = dot(normalize(nViewPosR), sunVec);

    #if defined GBUFFERS_WATER && WATER_STYLE >= 2
        normalMR = mix(geoNormal, normalM, 0.8);
    #endif
    // End Step 1

    // Step 2: Calculate Terrain Reflection and Alpha
    vec4 reflection = vec4(0.0);
    #if defined DEFERRED1 || WATER_REFLECT_QUALITY >= 1
        #if defined DEFERRED1 || WATER_REFLECT_QUALITY >= 2 && !defined DH_WATER
            // Method 1: Ray Marched Reflection //

            // Ray Marching
            vec3 start = viewPos + normalMR * (lViewPos * 0.025 * (1.0 - fresnel) + 0.05);
            vec3 vector = reflect(nViewPos, normalize(normalMR));
            vector *= 0.5;
            vec3 viewPosRT = viewPos + vector;
            vec3 tvector = vector;

            int sr = 0;
            float dist = 0.0;
            vec3 rfragpos = vec3(0.0);
            for(int i = 0; i < 30; i++) {
                refPos = nvec3(gbufferProjection * vec4(viewPosRT, 1.0)) * 0.5 + 0.5;
                if (abs(refPos.x - 0.5) > rEdge.x || abs(refPos.y - 0.5) > rEdge.y) break;

                rfragpos = vec3(refPos.xy, texture2D(depthtex, refPos.xy).r);
                rfragpos = nvec3(gbufferProjectionInverse * vec4(rfragpos * 2.0 - 1.0, 1.0));
                dist = length(start - rfragpos);

                float err = length(viewPosRT - rfragpos);

                if (err < length(vector) * 3.0) {
                    sr++;
                    if (sr >= 6) break;
                    tvector -= vector;
                    vector *= 0.1;
                }
                vector *= 2.0;
                tvector += vector * (0.95 + 0.1 * dither);
                viewPosRT = start + tvector;
            }

            // Finalizing Terrain Reflection and Alpha
            if (refPos.z < 0.99997) {
                vec2 absPos = abs(refPos.xy - 0.5);
                vec2 cdist = absPos / rEdge;
                float border = clamp(1.0 - pow(max(cdist.x, cdist.y), 50.0), 0.0, 1.0);
                reflection.a = border;

                float lViewPosRT = length(rfragpos);

                if (reflection.a > 0.001) {
                    vec2 edgeFactor = pow2(pow2(pow2(cdist)));
                    refPos.y += (dither - 0.5) * (0.05 * (edgeFactor.x + edgeFactor.y));

                    #ifdef DEFERRED1
                        float smoothnessDM = pow2(smoothness);
                        float lodFactor = 1.0 - exp(-0.125 * (1.0 - smoothnessDM) * dist);
                        float lod = log2(viewHeight / 8.0 * (1.0 - smoothnessDM) * lodFactor) * 0.45;
                        #ifdef CUSTOM_PBR
                            if (z0 <= 0.56) lod *= 2.22;
                        #endif
                        lod = max(lod - 1.0, 0.0);

                        reflection.rgb = texture2DLod(colortex0, refPos.xy, lod).rgb;
                    #else
                        reflection = texture2D(gaux2, refPos.xy);
                        reflection.rgb = pow2(reflection.rgb + 1.0);
                    #endif

                    float skyFade = 0.0;
                    DoFog(reflection.rgb, skyFade, lViewPosRT, ViewToPlayer(rfragpos.xyz), RVdotU, RVdotS, dither);

                    edgeFactor.x = pow2(edgeFactor.x);
                    edgeFactor = 1.0 - edgeFactor;
                    reflection.a *= pow(edgeFactor.x * edgeFactor.y, 2.0 + 3.0 * GetLuminance(reflection.rgb));
                }

                float posDif = lViewPosRT - lViewPos;
                reflection.a *= clamp(posDif + 3.0, 0.0, 1.0);
            }
            #if defined DEFERRED1 && defined TEMPORAL_FILTER
                else refPos.z = 1.0;
            #endif
            #if !defined DEFERRED1 && defined DISTANT_HORIZONS
                else
            #endif
        #endif
        #if !defined DEFERRED1 && (WATER_REFLECT_QUALITY < 2 || defined DISTANT_HORIZONS) || defined DH_WATER
        {   // Method 2: Mirorred Image Reflection //

            #if WATER_REFLECT_QUALITY < 2
                float verticalStretch = 0.013; // for potato quality reflections
            #else
                float verticalStretch = 0.0025; // for distant horizons reflections
            #endif

            vec4 clipPosR = gbufferProjection * vec4(nViewPosR + verticalStretch * viewPos, 1.0);
            vec3 screenPosR = clipPosR.xyz / clipPosR.w * 0.5 + 0.5;
            vec2 screenPosRM = abs(screenPosR.xy - 0.5);

            if (screenPosRM.x < rEdge.x && screenPosRM.y < rEdge.y) {
                vec2 edgeFactor = pow2(pow2(pow2(screenPosRM / rEdge)));
                screenPosR.y += (dither - 0.5) * (0.03 * (edgeFactor.x + edgeFactor.y) + 0.004);

                screenPosR.z = texture2D(depthtex1, screenPosR.xy).x;
                vec3 viewPosR = ScreenToView(screenPosR);
                if (lViewPos <= 2.0 + length(viewPosR)) {
                    reflection = texture2D(gaux2, screenPosR.xy);
                    reflection.rgb = pow2(reflection.rgb + 1.0);
                }

                edgeFactor.x = pow2(edgeFactor.x);
                edgeFactor = 1.0 - edgeFactor;
                reflection.a *= edgeFactor.x * edgeFactor.y;
            }

            reflection.a *= reflection.a;
            reflection.a *= clamp01((dot(nViewPos, nViewPosR) - 0.45) * 10.0); // Fixes perpendicular ref
        }
        #endif
    #endif
    // End Step 2

    #if defined VOXEL_RT_REFLECTIONS && (defined DEFERRED1 || (WATER_REFLECT_QUALITY >= 2 && !defined DISTANT_HORIZONS && !defined DH_WATER))
        vec3 fractCamPos = cameraPositionInt.y == -98257195 ? fract(cameraPosition) : cameraPositionFract;
        // Step 2.5: fill missing reflections with voxel data
        if (reflection.a < 1.0 ) {
            vec3 voxelVector = mat3(gbufferModelViewInverse) * vector;
            vec4 voxelStart = gbufferModelViewInverse * vec4(start, 1.0);
            voxelStart.xyz += fractCamPos;
            vec3 hitPos = rayTrace(voxelStart.xyz + 0.1 * voxelVector, 50.0 * voxelVector, dither);
            if (length(voxelStart.xyz - hitPos) < 49.0 && getDistanceField(hitPos) < 0.1) {
                // do lighting on the reflected surface
                vec3 hitNormal = normalize(distanceFieldGradient(hitPos) + vec3(0.000001, -0.0000041, 0.0000003));
                int occupancyData = imageLoad(occupancyVolume, ivec3(hitPos + 0.5 * voxelVolumeSize - 0.1 * hitNormal)).r;
                vec4 voxelCol = getColor(hitPos - 0.1 * hitNormal);
                #if defined REALTIME_SHADOWS && defined OVERWORLD
                    vec3 shadowHitPos = GetShadowPos(hitPos - fractCamPos + 0.2 * hitNormal);
                #endif
                float skyLight = 0.0;
                int liveBitCount = 0;
                for (int k = 0; k < 3; k++) {
                    skyLight += 0.33 * ((occupancyData >> (28 + k)) & 1) * (k+1);
                    liveBitCount += ((occupancyData >> (28 + k)) & 1);
                }
                skyLight /= max(1, liveBitCount);
                skyLight *= 0.5 * hitNormal.y + 0.5;
                #if defined REALTIME_SHADOWS && defined OVERWORLD
                    vec3 sunShadow = SampleShadow(shadowHitPos, 1.2 + 3.8 * skyLight, 1.1 - 0.6 * skyLight);
                #else
                    vec3 sunShadow = vec3(skyLight * skyLight);
                #endif
                float RNdotS = dot(hitNormal, mat3(gbufferModelViewInverse) * sunVec);
                vec3 blockLight = readSurfaceVoxelBlocklight(hitPos, hitNormal);
                #ifdef GI
                    vec3 giLight = readIrradianceCache(hitPos, hitNormal);
                    vec3 ambientColorM = vec3(0);
                #else
                    const float giLight = 0.0;
                    vec3 ambientColorM = ambientColor;
                #endif
                voxelCol.rgb *= skyLight * ambientColorM + max(0.0, RNdotS + 0.1) * sunShadow * lightColor + blockLight + giLight;

                vec3 playerHitPos = hitPos - fractCamPos;
                float skyFade = 0.0;
                DoFog(voxelCol.rgb, skyFade, length(playerHitPos), playerHitPos, RVdotU, RVdotS, dither);

                reflection.rgb = mix(voxelCol.rgb, reflection.rgb, reflection.a);
                reflection.a += (1.0 - reflection.a) * voxelCol.a;
            }
        }
        // End Step 2.5
    #endif

    // Step 3: Add Sky Reflection
    #if defined DEFERRED1 || WATER_REFLECT_QUALITY >= 1
        if (reflection.a < 1.0)
    #endif
    {
        #ifdef OVERWORLD
            #if defined DEFERRED1 || WATER_REFLECT_QUALITY >= 2
                vec3 skyReflection = GetSky(RVdotU, RVdotS, dither, true, true);
            #else
                vec3 skyReflection = GetLowQualitySky(RVdotU, RVdotS, dither, true, true);
            #endif

            #ifdef ATM_COLOR_MULTS
                skyReflection *= atmColorMult;
            #endif
            #ifdef MOON_PHASE_INF_ATMOSPHERE
                skyReflection *= moonPhaseInfluence;
            #endif

            #ifdef DEFERRED1
                skyReflection *= skyLightFactor;
            #else
                float specularHighlight = GGX(normalM, nViewPos, lightVec, max(dot(normalM, lightVec), 0.0), smoothness);
                skyReflection += specularHighlight * highlightColor * shadowMult * highlightMult * invRainFactor;
                
                #if WATER_REFLECT_QUALITY >= 1
                    #ifdef SKY_EFFECT_REFLECTION
                        float cloudLinearDepth = 1.0;
                        float skyFade = 1.0;
                        vec3 auroraBorealis = vec3(0.0);
                        vec3 nightNebula = vec3(0.0);

                        #if AURORA_STYLE > 0
                            auroraBorealis = GetAuroraBorealis(nViewPosR, RVdotU, dither);
                            skyReflection += auroraBorealis;
                        #endif
                        #ifdef NIGHT_NEBULA
                            nightNebula += GetNightNebula(nViewPosR, RVdotU, RVdotS);
                            skyReflection += nightNebula;
                        #endif
                        
                        vec2 starCoord = GetStarCoord(nViewPosR, 0.5);
                        skyReflection += GetStars(starCoord, RVdotU, RVdotS);

                        #ifdef VL_CLOUDS_ACTIVE
                            vec3 worldNormalMR = normalize(mat3(gbufferModelViewInverse) * normalMR);
                            vec3 RCameraPos = cameraPosition + 2.0 * worldNormalMR * dot(playerPos, worldNormalMR);
                            vec3 RPlayerPos = normalize(mat3(gbufferModelViewInverse) * nViewPosR);
                            float RlViewPos = 100000.0;

                            vec4 clouds = GetClouds(cloudLinearDepth, skyFade, RCameraPos, RPlayerPos,
                                                    RlViewPos, RVdotS, RVdotU, dither, auroraBorealis, nightNebula);

                            skyReflection = mix(skyReflection, clouds.rgb, clouds.a);
                        #endif
                    #endif

                    skyReflection = mix(color * 0.5, skyReflection, skyLightFactor);
                #else
                    skyReflection = mix(color, skyReflection, skyLightFactor * 0.5);
                #endif
            #endif
        #elif defined END
            #ifdef DEFERRED1
                vec3 skyReflection = (endSkyColor + 0.4 * DrawEnderBeams(RVdotU, playerPos)) * skyLightFactor;
            #else
                vec3 skyReflection = endSkyColor * shadowMult;
            #endif

            #ifdef ATM_COLOR_MULTS
                skyReflection *= atmColorMult;
            #endif
        #else
            vec3 skyReflection = vec3(0.0);
        #endif

        reflection.rgb = mix(skyReflection, reflection.rgb, reflection.a);
    } 
    // End Step 3

    return reflection;
}