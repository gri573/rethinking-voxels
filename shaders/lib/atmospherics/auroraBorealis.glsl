vec3 GetAuroraBorealis(vec3 viewPos, float VdotU, float dither) {
    float visibility = sqrt1(clamp01(VdotU * 1.5 - 0.225)) - sunVisibility - rainFactor;
    visibility *= 1.0 - VdotU * 0.75;

    #if AURORA_CONDITION == 1 || AURORA_CONDITION == 3
        visibility -= moonPhase;
    #endif
    #if AURORA_CONDITION == 2 || AURORA_CONDITION == 3
        visibility *= isSnowy;
    #endif

    if (visibility > 0.0) {
	    if (max(blindness, darknessFactor) > 0.1) return vec3(0.0);

        vec3 aurora = vec3(0.0);

        vec3 wpos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
             wpos.xz /= wpos.y;
        vec2 cameraPositionM = cameraPosition.xz * 0.0075;
             cameraPositionM.x += syncedTime * 0.04;
        
        int sampleCount = 25;
        int sampleCountP = sampleCount + 5;
        float ditherM = dither + 5.0;
        float auroraAnimate = frameTimeCounter * 0.0015;
        for (int i = 0; i < sampleCount; i++) {
            float current = pow2((i + ditherM) / sampleCountP);

            vec2 planePos = wpos.xz * (0.8 + current);
            planePos = floor(planePos * 11.0 + cameraPositionM) * 0.0007;

            float noise = texture2D(noisetex, planePos).b;
            noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));
            noise *= pow1_5(texture2D(noisetex, planePos * 100.0 + auroraAnimate).b);

            float currentM = 1.0 - current;
            aurora += noise * currentM * mix(vec3(7.0, 2.2, 12.0), vec3(6.0, 16.0, 12.0), pow2(pow2(currentM)));
        }
        
        return aurora * 1.3 * visibility / sampleCount;
    }

    return vec3(0.0);
}