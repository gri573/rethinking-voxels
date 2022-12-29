uniform sampler2DShadow shadowtex0;
uniform sampler2DShadow shadowtex1;
uniform sampler2D shadowcolor0;

vec2 shadowoffsets[8] = vec2[8](
    vec2( 0.0   , 1.0   ),
    vec2( 0.7071, 0.7071),
    vec2( 1.0   , 0.0   ),
    vec2( 0.7071,-0.7071),
    vec2( 0.0   ,-1.0   ),
    vec2(-0.7071,-0.7071),
    vec2(-1.0   , 0.0   ),
    vec2(-0.7071, 0.7071));

vec3 calculateShadowPos(vec3 playerPos) {
    vec3 shadowPos = PlayerToShadow(playerPos);
    float distb = sqrt(shadowPos.x * shadowPos.x + shadowPos.y * shadowPos.y);
    float distortFactor = distb * shadowMapBias + (1.0 - shadowMapBias);
    shadowPos.xy /= distortFactor;
    shadowPos.z *= 0.2;
    return shadowPos * 0.5 + 0.5;
}

vec3 SampleBasicShadow(vec3 shadowPos) {
    float shadow0 = shadow2D(shadowtex0, vec3(shadowPos.st, shadowPos.z)).x;

    vec3 shadowcol = vec3(0.0);
    if (shadow0 < 1.0) {
        if (rainFactor > 0.9999) return vec3(shadow0);
        float shadow1 = shadow2D(shadowtex1, vec3(shadowPos.st, shadowPos.z)).x;
        if (shadow1 > 0.9999) {
            shadowcol = texelFetch(shadowcolor0, ivec2(shadowPos.st * shadowMapResolution), 0).rgb * (shadow1 * 4.0 * invRainFactorSqrt);
        }
    }

    return shadowcol * (1.0 - shadow0) + shadow0;
}

vec3 SampleFilteredShadow(vec3 shadowPos, float offset, bool leaves) {
    vec3 shadow = SampleBasicShadow(vec3(shadowPos.st, shadowPos.z)) * 2.0;

    float shadowPosZM = shadowPos.z;
    for (int i = 0; i < 8; i++) {
        if (leaves) shadowPosZM = shadowPos.z - 0.000045 * i;
        shadow += SampleBasicShadow(vec3(offset * 1.2 * shadowoffsets[i] + shadowPos.st, shadowPosZM));
    }

    return shadow * 0.1;
}

#ifdef TAA
    float InterleavedGradientNoise() {
        float n = 52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y);
        #if !defined GBUFFERS_ENTITIES && !defined GBUFFERS_HAND && !defined GBUFFERS_TEXTURED
            return fract(n + 1.61803398875 * mod(float(frameCounter), 3600.0));
        #else
            return fract(n);
        #endif
    }

    vec2 offsetDist(float x, int s) {
        float n = fract(x * 1.414) * 3.1415;
        return vec2(cos(n), sin(n)) * 1.4 * x / s;
    }

    vec3 SampleTAAFilteredShadow(vec3 shadowPos, float offset, float gradientNoise, bool leaves) {
        vec3 shadow = vec3(0.0);

        #if !defined GBUFFERS_ENTITIES && !defined GBUFFERS_HAND && !defined GBUFFERS_TEXTURED
            int shadowSamples = 2;
            offset *= 1.3875;
        #else
            int shadowSamples = 4;
            offset *= 0.69375;
        #endif
        
        #if SHADOW_QUALITY == 1
            shadowSamples /= 2;
        #elif SHADOW_QUALITY == 3
            shadowSamples *= 2;
        #elif SHADOW_QUALITY == 4
            shadowSamples *= 6;
        #endif
        
        float shadowPosZM = shadowPos.z;
        for (int i = 0; i < shadowSamples; i++) {
            vec2 offset2 = offsetDist(gradientNoise + i, shadowSamples) * offset;
            if (leaves) shadowPosZM = shadowPos.z - 0.12 * offset * (gradientNoise + i) / shadowSamples;
            shadow += SampleBasicShadow(vec3(shadowPos.st + offset2, shadowPosZM));
            shadow += SampleBasicShadow(vec3(shadowPos.st - offset2, shadowPosZM));
        }
        
        shadow /= shadowSamples * 2.0;

        return shadow;
    }
#endif

vec3 GetShadow(vec3 shadowPos, float offset, float gradientNoise, bool leaves) {
    #if !defined ENTITY_SHADOWS && defined GBUFFERS_BLOCK
        offset *= 4.0;
    #else
        offset *= 1.0 + rainFactor2 * 3.0;
    #endif

    #ifdef SHADOW_FILTERING
        #ifdef TAA
            vec3 shadow = SampleTAAFilteredShadow(shadowPos, offset, gradientNoise, leaves);
        #else
            vec3 shadow = SampleFilteredShadow(shadowPos, offset, leaves);
        #endif
    #else
       vec3 shadow = SampleBasicShadow(shadowPos);
    #endif

    return shadow;
}