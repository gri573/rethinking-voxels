/*---------------------------------------------------------------------
         ___ __  __ ____   ___  ____ _____  _    _   _ _____ 
        |_ _|  \/  |  _ \ / _ \|  _ \_   _|/ \  | \ | |_   _|
         | || |\/| | |_) | | | | |_) || | / _ \ |  \| | | |  
         | || |  | |  __/| |_| |  _ < | |/ ___ \| |\  | | |  
        |___|_|  |_|_|    \___/|_| \_\|_/_/   \_\_| \_| |_|  
         .
  -> -> -> EDITING THIS FILE HAS A HIGH CHANCE TO BREAK THE SHADERPACK
  -> -> -> DO NOT CHANGE ANYTHING UNLESS YOU KNOW WHAT YOU ARE DOING
  -> -> -> DO NOT EXPECT SUPPORT AFTER MODIFYING SHADER FILES
---------------------------------------------------------------------*/

//User Settings//

//voxel settings//

    #define SHADOWRES 1024 //[512 1024 2048 4096]

    #if SHADOWRES == 512
        const int shadowMapResolution = 512;
    #elif SHADOWRES == 1024
        const int shadowMapResolution = 1024;
    #elif SHADOWRES == 2048
        const int shadowMapResolution = 2048;
    #else
        const int shadowMapResolution = 4096;
    #endif
    
    #define VXHEIGHT 8 //[4 6 8 12 16]
    #define OCCLUSION_CASCADE_COUNT 5 //[1 2 3 4 5]

    #define BLOCKLIGHT_STRENGTH 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.5 1.7 2.0]
    #define BLOCKLIGHT_STEEPNESS 2.0 //[1.0 1.3 1.5 1.7 2.0]
    #define BLOCKLIGHT_SHAFT_STRENGTH 0.1 //[0.01 0.02 0.03 0.05 0.07 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.7 1.0 1.2 1.5 2 2.5 3]

    #define OCCLUSION_FILTER 1 //[0 1 2]
    #define OCCLUSION_BLEED_PREVENTION
    #define CAVE_SUNLIGHT_FIX 2 // [0 1 2]
    #define SMOOTH_LIGHTING 1 //[0 1]
  //#define PP_BL_SHADOWS
  //#define PP_SUN_SHADOWS
  //#define CORRECT_CUBOID_OFFSETS
    #define BLOCKLIGHT_SOURCE_SIZE 0.1 //[0.0 0.02 0.05 0.1 0.2 0.3 0.5]
  //#define INST_LP
    #define SUN_SHADOWS
    #define BIG_LIGHTS
    #ifdef NETHER
        #undef SUN_SHADOWS
    #endif
    #define SUN_ANGLE 0.5 //[-0.5 0 0.5]
    #define BLOCKLIGHT_CHECK_INTERVAL 17 //[4 5 7 10 15 17 20 30]
    #define VBL_NETHER_MULT 2.0 //[1.0 1.2 1.5 1.7 2.0 2.5 3.0 4.0]
    #define VBL_END_MULT 2.0 //[1.0 1.2 1.5 1.7 2.0 2.5 3.0 4.0]
    #define VBL_INTPOL
    #define ADVANCED_LIGHT_TRACING 1 //[0 1]
    #define FF_PROP_MUL 0.9999
    #define FF_PROP_SUB 0.003 //[0.0001 0.0003 0.0005 0.001 0.002 0.003 0.005 0.007 0.01]
    #define BFF_ABSORBTION_AMOUNT 0.05
    #define TRANSLUCENT_LIGHT_TINT 0.5 // [0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
    #define TRANSLUCENT_LIGHT_CONDUCTION 1.0 // [0.9 1.0 1.1 1.2 1.3 1.5]
    #if SHADOWRES == 512
        #if (VXHEIGHT == 4)
            const float shadowDistance = 64.0;
        #elif (VXHEIGHT == 6)
            const float shadowDistance = 42.0;
        #elif (VXHEIGHT == 8)
            const float shadowDistance = 32.0;
        #elif (VXHEIGHT == 12)
            const float shadowDistance = 21.0;
        #elif (VXHEIGHT == 16)
            const float shadowDistance = 16.0;
        #else
            const float shadowDistance = 50.0;
        #endif
    #elif SHADOWRES == 1024
        #if (VXHEIGHT == 4)
            const float shadowDistance = 128.0;
        #elif (VXHEIGHT == 6)
            const float shadowDistance = 85.0;
        #elif (VXHEIGHT == 8)
            const float shadowDistance = 64.0;
        #elif (VXHEIGHT == 12)
            const float shadowDistance = 42.0;
        #elif (VXHEIGHT == 16)
            const float shadowDistance = 32.0;
        #else
            const float shadowDistance = 70.0;
        #endif
    #elif SHADOWRES == 2048
        #if (VXHEIGHT == 4)
            const float shadowDistance = 256.0;
        #elif (VXHEIGHT == 6)
            const float shadowDistance = 170.0;
        #elif (VXHEIGHT == 8)
            const float shadowDistance = 128.0;
        #elif (VXHEIGHT == 12)
            const float shadowDistance = 85.0;
        #elif (VXHEIGHT == 16)
            const float shadowDistance = 64.0;
        #else
            const float shadowDistance = 120.0;
        #endif
    #elif SHADOWRES == 4096
        #if (VXHEIGHT == 4)
            const float shadowDistance = 512.0;
        #elif (VXHEIGHT == 6)
            const float shadowDistance = 341.0;
        #elif (VXHEIGHT == 8)
            const float shadowDistance = 256.0;
        #elif (VXHEIGHT == 12)
            const float shadowDistance = 170.0;
        #elif (VXHEIGHT == 16)
            const float shadowDistance = 128.0;
        #else
            const float shadowDistance = 200.0;
        #endif
    #else
        const float shadowDistance = 100.0;
    #endif
    #if (defined PP_SUN_SHADOWS || defined VOXEL_REFLECTIONS)
        #define DISTANCE_FIELD
    #endif
//regular settings//

    #define CMPR 3 //[0 1 2 3 4 5]

    #define RP_MODE 1 //[0 1]

    #if RP_MODE == 1
        #define IPBR
        //#define GENERATED_NORMALS
        //#define COATED_TEXTURES
    #endif

    #define SHADOW_QUALITY 2 //[1 2 3 4]

    //#define ENTITY_SHADOWS
    #define SSAO
    #define CLOUD_QUALITY 3 //[0 1 2 3 4]
    #define WATER_QUALITY 2 //[1 2]
    #define REFLECTION_QUALITY 3 //[0 2 3]
    #define LIGHTSHAFT_QUALITY 3 //[0 1 2 3 4]

    #define WATER_STYLE 1 //[1 2 3]
  //#define WAVESIM
    #define BORDER_FOG
    #define PIXEL_SHADOW 0 //[0 8 16 32 64 128]
    #define HAND_SWAYING 0 //[0 1 2 3]
    //#define LESS_LAVA_FOG
    #define SHOW_LIGHT_LEVEL 0 //[0 1 2 3]
    //#define WORLD_OUTLINE
    #define RAIN_PUDDLES 0 //[0 1 2]
    #define SELECTION_OUTLINE 0 //[0 1 2 3 4 5 6 7 8]
    //#define SNOWY_WORLD

    #define AURORA_BOREALIS
    #define AURORA_CONDITION 3 //[0 1 2 3]
    #define SUN_MOON_HORIZON
    #define NIGHT_STAR_AMOUNT 2 //[2 3]
    //#define CLOUD_SHADOWS
    //#define SECOND_CLOUD_LAYER
    #define CLOUD_ALT1 192.0 //[64.0 68.0 72.0 76.0 80.0 84.0 88.0 92.0 96.0 100.0 104.0 108.0 112.0 116.0 120.0 124.0 128.0 132.0 136.0 140.0 144.0 148.0 152.0 156.0 160.0 164.0 168.0 172.0 176.0 180.0 184.0 188.0 192.0 196.0 200.0 204.0 208.0 212.0 216.0 220.0 224.0 228.0 232.0 236.0 240.0 244.0 248.0 252.0 254.0 256.0]
    #define CLOUD_ALT2 288.0 //[272.0 274.0 276.0 278.0 280.0 282.0 284.0 286.0 288.0 290.0 292.0 294.0 296.0 298.0 300.0 302.0 306.0 308.0 310.0 312.0 314.0 316.0 318.0 320.0 322.0 324.0 326.0 328.0 330.0 332.0 334.0 336.0 338.0 340.0 342.0 344.0 346.0 348.0 350.0 352.0 354.0 356.0 358.0 360.0 362.0 364.0 366.0 368.0 370.0 372.0 374.0 376.0 378.0 380.0 382.0 384.0]

    #define BLOOM_STRENGTH 0.12 //[0.027 0.036 0.045 0.054 0.063 0.072 0.081 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19]
    #define FXAA
    //#define MOTION_BLURRING
    #define MOTION_BLURRING_STRENGTH 1.00 //[0.01 0.02 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.10 2.20 2.30 2.40 2.50 2.60 2.70 2.80 2.90 3.00 3.25 3.50 3.75 4.00 4.50 5.00 6.00 7.50 10.00]
    #define T_EXPOSURE 1.40 //[0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90]
    #define TM_WHITE_CURVE 2.0 //[1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
    #define T_LOWER_CURVE 1.20 //[0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define T_UPPER_CURVE 1.30 //[0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define T_SATURATION 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define T_VIBRANCE 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

    #define GLOWING_ORES 0 //[0 1 2]
    //#define GLOWING_MINERAL_BLOCKS
    //#define FANCY_GLASS
    //#define EMISSIVE_REDSTONE_BLOCK
    //#define GENERATED_WATER_NORMALS

    #define BLOCKLIGHT_COLOR_MODE 10 //[9 10 11]
    #define MINIMUM_LIGHT_MODE 2 //[0 1 2 3 4]
    #define HELD_LIGHTING_MODE 2 //[0 1 2]

    #define NO_WAVING_INDOORS
    #define WAVING_FOLIAGE
    //#define WAVING_LEAVES
    #define WAVING_WATER_VERTEX

//Internal Settings//

    #if RP_MODE >= 1 && REFLECTION_QUALITY >= 3
        #define PBR_REFLECTIONS
    #endif

    #if defined WAVING_FOLIAGE || defined WAVING_LEAVES
        #define WAVING_ANYTHING_TERRAIN
    #endif

    #define GLASS_OPACITY 0.25
    #define FANCY_NETHERPORTAL
    #define TRANSLUCENT_BLEND_FALLOFF_MULT 0.01
    
    #define SHADOW_FILTERING

    // Disable PERPENDICULAR_TWEAKS if you change sunPathRotation to anything but 0.0 or else you will get incorrect lighting
    const float sunPathRotation = 0.0;
    #define PERPENDICULAR_TWEAKS
    #define SIDE_SHADOWING

    #define LIGHT_HIGHLIGHT
    #define DIRECTIONAL_SHADING
    #define SSAO_QUALITY 1 //[1 2 3]

    #define CLOUD_STRETCH 5.5
    #define ATMOSPHERIC_FOG
    #define SCENE_AWARE_LIGHT_SHAFTS
    #define CAVE_FOG
    #define BLOOM_FOG

    #define TAA
    //#define TEMPORAL_FILTER

    #define GLOWING_ENTITY_FIX
    #define FLICKERING_FIX
    //#define SAFER_GENERATED_NORMALS

    #define BLOOM
    #define UNDERWATER_DISTORTION

//Define Handling//
    #ifndef OVERWORLD
        #undef LIGHT_HIGHLIGHT
        #undef CAVE_FOG
        #undef CLOUD_SHADOWS
        #undef AURORA_BOREALIS
        #undef SNOWY_WORLD
    #endif
    #ifdef NETHER
        #undef ATMOSPHERIC_FOG
        #undef SUN_SHADOWS
    #endif
    #ifdef END
        #undef BLOOM_FOG
    #endif
    #ifndef SUN_SHADOWS
        #undef CAVE_SUNLIGHT_FIX
    #endif
    #if defined GBUFFERS_TEXTURED || defined GBUFFERS_BASIC
        #undef LIGHT_HIGHLIGHT
        #undef DIRECTIONAL_SHADING
        #undef SIDE_SHADOWING
    #endif
    #ifdef GBUFFERS_WATER
        #undef LIGHT_HIGHLIGHT
    #endif

    #ifndef PERPENDICULAR_TWEAKS
        #undef CLOUD_SHADOWS
        #undef SIDE_SHADOWING
    #endif
    #ifndef BLOOM
        #undef BLOOM_FOG
    #endif
    #ifndef GLOWING_ENTITY_FIX
        #undef GBUFFERS_ENTITIES_GLOWING
    #endif
    #if SHADOW_QUALITY == 1
        //#undef SHADOW_FILTERING
    #endif
    #if CLOUD_QUALITY == 0
        #undef CLOUD_SHADOWS
    #endif

//Activate Settings//
    #ifdef ENTITY_SHADOWS
    #endif
    #ifdef GENERATED_WATER_NORMALS
    #endif

//Very Common Uniforms//
    uniform int worldTime;
    uniform int worldDay;

    uniform float rainFactor;
    uniform float screenBrightness;
    uniform float eyeBrightnessM;

    #ifdef VERTEX_SHADER
        uniform mat4 gbufferModelView;
    #endif

//Very Common Variables//
    //infinite... almost
    #define INF 100000.0

    const float shadowMapBias = 1.0 - 25.6 / shadowDistance;
    float timeAngle = worldTime / 24000.0;
    float noonFactor = sqrt(max(sin(timeAngle*6.28318530718),0.0));
    float nightFactor = max(sin(timeAngle*(-6.28318530718)),0.0);

    float rainFactor2 = rainFactor * rainFactor;
    float invRainFactor = 1.0 - rainFactor;
    float invRainFactorSqrt = 1.0 - rainFactor * rainFactor;
    float invNoonFactor = 1.0 - noonFactor;

    float vsBrightness = clamp(screenBrightness, 0.0, 1.0);

    int modifiedWorldDay = int(mod(worldDay, 100) + 5.0);
    float syncedTime = (worldTime + modifiedWorldDay * 24000) * 0.05;

    const float pi = 3.14159265359;
    const float OSIEBCA = 1.0 / 255.0; // One Step In Eight Bit Color Attachment

    const float blocklightColMult = 0.875;
    #if BLOCKLIGHT_COLOR_MODE == 9
        const vec3 blocklightCol = vec3(0.40, 0.32, 0.29) * blocklightColMult;
    #elif BLOCKLIGHT_COLOR_MODE == 10
        const vec3 blocklightCol = vec3(0.43, 0.32, 0.26) * blocklightColMult; // Default
    #elif BLOCKLIGHT_COLOR_MODE == 11
        const vec3 blocklightCol = vec3(0.44, 0.31, 0.22) * blocklightColMult;
    #endif

    const vec3 caveFogColorRaw = vec3(0.13, 0.13, 0.15);
    #if MINIMUM_LIGHT_MODE <= 1
        vec3 caveFogColor = caveFogColorRaw * 0.7;
    #elif MINIMUM_LIGHT_MODE == 2
        vec3 caveFogColor = caveFogColorRaw * (0.7 + 0.3 * vsBrightness); // Default
    #elif MINIMUM_LIGHT_MODE >= 3
        vec3 caveFogColor = caveFogColorRaw;
    #endif

    vec3 waterFogColor = vec3(0.07, 0.08, 0.13) * vec3(1.0 + vsBrightness);
    vec3 endSkyColor = vec3(0.095, 0.07, 0.15) * 1.5;

    #ifdef FRAGMENT_SHADER
        ivec2 texelCoord = ivec2(gl_FragCoord.xy);
    #endif

//Very Common Functions//

    //Hashing function by David Hoskins (https://www.shadertoy.com/view/4djSRW)
    // MIT License...
    /* Copyright (c)2014 David Hoskins.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.*/
    vec3 hash33(vec3 p3) {
        p3 = fract(p3 * vec3(.1031, .1030, .0973));
        p3 += dot(p3, p3.yxz+33.33);
        return fract((p3.xxy + p3.yxx)*p3.zyx);
    }

    #ifdef VERTEX_SHADER
        vec2 GetLightMapCoordinates() {
            vec2 lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
            return clamp((lmCoord - 0.03125) * 1.06667, 0.0, 1.0);
        }
        vec3 GetSunVector() {
            const vec2 sunRotationData = vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994));
            #ifdef OVERWORLD
                float ang = fract(timeAngle - 0.25);
                ang = (ang + (cos(ang * 3.14159265358979) * -0.5 + 0.5 - ang) / 3.0) * 6.28318530717959;
                return normalize((gbufferModelView * vec4(vec3(-sin(ang), cos(ang) * sunRotationData) * 2000.0, 1.0)).xyz);
            #elif defined END
                float ang = 0.0;
                return normalize((gbufferModelView * vec4(vec3(0.0, sunRotationData * 2000.0), 1.0)).xyz);
            #else
                return vec3(0.0);
            #endif
        }
    #endif

    float GetLuminance(vec3 color) {
        return dot(color, vec3(0.299, 0.587, 0.114));
    }

    vec3 DoLuminanceCorrection(vec3 color) {
        return color / GetLuminance(color);
    }

    float GetBiasFactor(float NdotLM) {
        float NdotLM2 = NdotLM * NdotLM;
        return 1.25 * (1.0 - NdotLM2 * NdotLM2) / NdotLM;
    }

    bool CheckForColor(vec3 albedo, vec3 check) { // Thanks to Builderb0y
        vec3 dif = albedo - check * 0.003921568;
        return dif == clamp(dif, vec3(-0.001), vec3(0.001));
    }

    int min1(int x) {
        return min(x, 1);
    }
    float min1(float x) {
        return min(x, 1.0);
    }
    int max0(int x) {
        return max(x, 0);
    }
    float max0(float x) {
        return max(x, 0.0);
    }
    int clamp01(int x) {
        return clamp(x, 0, 1);
    }
    float clamp01(float x) {
        return clamp(x, 0.0, 1.0);
    }

    int pow2(int x) {
        return x * x;
    }
    float pow2(float x) {
        return x * x;
    }
    vec2 pow2(vec2 x) {
        return x * x;
    }
    vec3 pow2(vec3 x) {
        return x * x;
    }
    vec4 pow2(vec4 x) {
        return x * x;
    }

    float pow1_5(float x) { // Faster pow(x, 1.5) approximation (that isn't accurate at all) if x is between 0 and 1
        return x - x * pow2(1.0 - x); // Thanks to SixthSurge
    }
    vec2 pow1_5(vec2 x) {
        return x - x * pow2(1.0 - x);
    }
    vec3 pow1_5(vec3 x) {
        return x - x * pow2(1.0 - x);
    }
    vec4 pow1_5(vec4 x) {
        return x - x * pow2(1.0 - x);
    }

    float sqrt1(float x) { // Faster sqrt() approximation (that isn't accurate at all) if x is between 0 and 1
        return x * (2.0 - x); // Thanks to Builderb0y
    }
    vec2 sqrt1(vec2 x) {
        return x * (2.0 - x);
    }
    vec3 sqrt1(vec3 x) {
        return x * (2.0 - x);
    }
    vec4 sqrt1(vec4 x) {
        return x * (2.0 - x);
    }
    float sqrt2(float x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    vec2 sqrt2(vec2 x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    vec3 sqrt2(vec3 x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    vec4 sqrt2(vec4 x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    float sqrt3(float x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    vec2 sqrt3(vec2 x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    vec3 sqrt3(vec3 x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    vec4 sqrt3(vec4 x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    float sqrt4(float x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    vec2 sqrt4(vec2 x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    vec3 sqrt4(vec3 x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }
    vec4 sqrt4(vec4 x) {
        x = 1.0 - x;
        x *= x;
        x *= x;
        x *= x;
        x *= x;
        return 1.0 - x;
    }

    float smoothstep1(float x) {
        return x * x * (3.0 - 2.0 * x);
    }

// 62 75 74 20 74 68 4F 73 65 20 77 68 6F 20 68 6F 70 65 20 69 6E 20 74 68 65 20 6C 69 6D 69 4E 61 6C 0A 77 69 6C 6C 20 72 65 6E 65 77 20 74 68 65 69 72 20 73 54 72 65 6E 67 74 48 2E 0A 74 68 65 79 20 77 69 6C 6C 20 73 6F 41 72 20 6F 6E 20 65 6C 79 54 72 61 73 20 6C 69 6B 65 20 70 68 61 6E 74 6F 6D 73 3B 0A 74 68 65 79 20 77 69 6C 6C 20 72 75 6E 20 61 6E 44 20 6E 6F 74 20 67 72 6F 77 20 77 65 41 72 79 2C 0A 74 68 65 59 20 77 69 6C 6C 20 77 61 6C 6B 20 61 6E 64 20 6E 6F 74 20 62 65 20 66 61 69 6E 74 2E
