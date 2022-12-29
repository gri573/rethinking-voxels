#ifndef INCLUDE_LIGHT_AND_AMBIENT_COLORS
#define INCLUDE_LIGHT_AND_AMBIENT_COLORS

#if defined OVERWORLD
    #ifndef COMPOSITE
	    vec3 noonClearLightColor = vec3(0.7, 0.55, 0.5) * 1.9; //ground and cloud color
    #else
        vec3 noonClearLightColor = vec3(0.5, 0.55, 0.7) * 1.5; //light shaft color
    #endif
    vec3 noonClearAmbientColor = pow(skyColor, vec3(0.65)) * 0.85;

    #ifndef COMPOSITE
	    vec3 sunsetClearLightColor = pow(vec3(0.6, 0.41, 0.24), vec3(1.5 + invNoonFactor)) * 6.0; //ground and cloud color
    #else
        vec3 sunsetClearLightColor = pow(vec3(0.62, 0.39, 0.24), vec3(1.5 + invNoonFactor)) * 6.8; //light shaft color
    #endif
    vec3 sunsetClearAmbientColor   = noonClearAmbientColor * vec3(1.0, 0.85, 0.8);

    #if !defined COMPOSITE && !defined DEFERRED1
        vec3 nightClearLightColor = vec3(0.15, 0.14, 0.20) * (0.4 + vsBrightness * 0.4); //ground color
    #elif defined DEFERRED1
        vec3 nightClearLightColor = vec3(0.11, 0.14, 0.20); //cloud color
    #else
        vec3 nightClearLightColor = vec3(0.07, 0.12, 0.27) * (0.25 + vsBrightness * 0.25); //light shaft color
    #endif
    vec3 nightClearAmbientColor   = vec3(0.09, 0.12, 0.17) * (1.55 + vsBrightness * 0.77);

    vec3 dayRainLightColor   = vec3(0.1, 0.12, 0.24) * (0.75 + vsBrightness * 0.25);
    vec3 dayRainAmbientColor = vec3(0.17, 0.21, 0.3) * (1.5 + vsBrightness);

    vec3 nightRainLightColor   = vec3(0.008, 0.009, 0.024) * (0.5 + vsBrightness);
    vec3 nightRainAmbientColor = vec3(0.16, 0.20, 0.3) * (0.75 + vsBrightness * 0.6);

    vec3 dayLightColor   = mix(noonClearLightColor, sunsetClearLightColor, invNoonFactor);
    vec3 dayAmbientColor = mix(noonClearAmbientColor, sunsetClearAmbientColor, invNoonFactor);

    vec3 clearLightColor   = mix(nightClearLightColor, dayLightColor, sunVisibility2);
    vec3 clearAmbientColor = mix(nightClearAmbientColor, dayAmbientColor, sunVisibility2);

    #ifndef COMPOSITE
        vec3 rainLightColor   = mix(nightRainLightColor, dayRainLightColor, sunVisibility2) * 2.5; //ground and cloud color
    #else
        vec3 rainLightColor   = mix(nightRainLightColor, dayRainLightColor, sunVisibility2) * 2.5; //light shaft color
    #endif
    vec3 rainAmbientColor = mix(nightRainAmbientColor, dayRainAmbientColor, sunVisibility2);

    vec3 lightColor   = mix(clearLightColor, rainLightColor, rainFactor);
    vec3 ambientColor = mix(clearAmbientColor, rainAmbientColor, rainFactor);
#elif defined NETHER
    vec3 netherColor  = max(normalize(sqrt(fogColor)), vec3(0.0));
    vec3 lightColor   = vec3(0.0);
    vec3 ambientColor = netherColor * (0.35 + 0.1 * vsBrightness);
#elif defined END
    vec3 endLightColor = vec3(0.68, 0.51, 1.07);
    vec3 lightColor    = endLightColor * (0.09 + 0.03 * vsBrightness);
    vec3 ambientColor  = endLightColor * (0.45 + 0.10 * vsBrightness);
#endif

#endif