vec3 GetWave(in vec3 pos, float waveSpeed) {
    float wind = frameTimeCounter * waveSpeed;

    float magnitude = sin(wind * 0.0027 + pos.z + pos.y) * 0.04 + 0.04;
    float d0 = sin(wind * 0.0127);
    float d1 = sin(wind * 0.0089);
    float d2 = sin(wind * 0.0114);
    vec3 wave;
    wave.x = sin(wind*0.0063 + d0 + d1 - pos.x + pos.z + pos.y) * magnitude;
    wave.z = sin(wind*0.0224 + d1 + d2 + pos.x - pos.z + pos.y) * magnitude;
    wave.y = sin(wind*0.0015 + d2 + d0 + pos.z + pos.y - pos.y) * magnitude;

    #ifdef NO_WAVING_INDOORS
        wave *= clamp(lmCoord.y - 0.87, 0.0, 0.1);
    #else
        wave *= 0.1;
    #endif

    return wave;
}

void DoWave_Foliage(inout vec3 playerPos, vec3 worldPos) {
    worldPos.y *= 0.5;

    vec3 wave = GetWave(worldPos, 170.0);
    wave.x = wave.x * 8.0 + wave.y * 4.0;
    wave.y = 0.0;
    wave.z = wave.z * 3.0;

    playerPos.xyz += wave;
}

void DoWave_GroundedFoliage(inout vec3 playerPos, vec3 worldPos) {
    if (gl_MultiTexCoord0.t < mc_midTexCoord.t || fract(worldPos.y + 0.21) > 0.26) {
        DoWave_Foliage(playerPos, worldPos);
    }
}

void DoWave_Leaves(inout vec3 playerPos, vec3 worldPos) {
    worldPos *= vec3(0.5, 0.25, 0.5);

    vec3 wave = GetWave(worldPos, 170.0);
    wave *= vec3(8.0, 3.0, 4.0);

    playerPos.xyz += wave;
}

void DoWave_Water(inout vec3 playerPos, vec3 worldPos) {
	if (fract(worldPos.y + 0.005) > 0.01) {
        float waterWaveTime = frameTimeCounter * 5.0;
        worldPos.xz *= 18.0;
        
        float wave  = sin(waterWaveTime * 0.7 + worldPos.x * 0.14 + worldPos.z * 0.07);
              wave += sin(waterWaveTime * 0.5 + worldPos.x * 0.10 + worldPos.z * 0.05);

        #ifdef NO_WAVING_INDOORS
            wave *= clamp(lmCoord.y - 0.87, 0.0, 0.1);
        #else
            wave *= 0.1;
        #endif

        playerPos.y += wave * 0.125;
    }
}

void DoWave(inout vec3 playerPos, int mat) {
    vec3 worldPos = playerPos.xyz + cameraPosition.xyz;

    #if defined GBUFFERS_TERRAIN || defined SHADOW
        #ifdef WAVING_FOLIAGE
            if (mat == 10004) { // Grounded Waving Foliage
                DoWave_GroundedFoliage(playerPos.xyz, worldPos);
            } else if (mat == 10020) { // Upper Layer Waving Foliage
                DoWave_Foliage(playerPos.xyz, worldPos);
            }
            
            #ifdef WAVING_LEAVES
                else
            #endif
        #endif

        #ifdef WAVING_LEAVES
            if (mat == 10008 || mat == 10012) { // Leaves, Vine
                DoWave_Leaves(playerPos.xyz, worldPos);
            }
        #endif
    #endif

    #if defined GBUFFERS_WATER || defined SHADOW
        #ifdef WAVING_WATER_VERTEX
            #if defined WAVING_ANYTHING_TERRAIN && defined SHADOW
                else
            #endif

            if (mat == 31000) { // Water
                DoWave_Water(playerPos.xyz, worldPos);
            }
        #endif
    #endif
}