// Tweak to revent the animation of lava causing brightness pulsing
color.rgb /= max(GetLuminance(texture2DLod(tex, texCoord, 100.0).rgb) * 2.5, 0.001);

#ifdef NETHER
    vec3 worldPos = playerPos + cameraPosition;
    vec2 lavaPos = (floor(worldPos.xz * 16.0) + worldPos.y * 32.0) * 0.000666;
    vec2 wind = vec2(frameTimeCounter * 0.012, 0.0);

    float noiseSample = texture2D(noisetex, lavaPos + wind).g;
    noiseSample = noiseSample - 0.5;
    noiseSample *= 0.1;
    color.rgb = pow(color.rgb, vec3(1.0 + noiseSample));
#endif

noDirectionalShading = true;
lmCoordM = vec2(0.0);
emission = GetLuminance(color.rgb) * 5.5;

maRecolor = vec3(clamp(pow2(pow2(pow2(smoothstep1(emission * 0.35)))), 0.12, 0.4) * 1.3) * vec3(1.0, vec2(0.7));

#if RAIN_PUDDLES >= 1
    noPuddles = 1.0;
#endif
