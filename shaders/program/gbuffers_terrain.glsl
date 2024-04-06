////////////////////////////////////////
// Complementary Reimagined by EminGT //
////////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

flat in int mat;

in vec2 texCoord;
in vec2 lmCoord;
in vec2 signMidCoordPos;
flat in vec2 absMidCoordPos;
flat in vec2 midCoord;

flat in vec3 upVec, sunVec, northVec, eastVec;
in vec3 normal;

in vec4 glColorRaw;

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat in vec3 binormal, tangent;
#endif

#ifdef POM
    in vec3 viewVector;

    in vec4 vTexCoordAM;
#endif

#if ANISOTROPIC_FILTER > 0
    in vec4 spriteBounds;
#endif

//Uniforms//
uniform int isEyeInWater;
uniform int frameCounter;
uniform int heldItemId;
uniform int heldItemId2;

uniform float viewWidth;
uniform float viewHeight;
uniform float nightVision;
uniform float frameTimeCounter;

uniform vec3 skyColor;
uniform vec3 cameraPosition;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform sampler2D tex;
uniform sampler2D noisetex;

#if defined IPBR || defined POM
    uniform ivec2 atlasSize;
#endif

#if RAIN_PUDDLES >= 1
    #if RAIN_PUDDLES < 3
        uniform float wetness;
        uniform float inRainy;
    #else
        float wetness = 1.0;
        float inRainy = 1.0;
    #endif
#endif

#if HELD_LIGHTING_MODE == 0 && SHOW_LIGHT_LEVEL == 2
    uniform int heldBlockLightValue;
    uniform int heldBlockLightValue2;
#endif

#ifdef CUSTOM_PBR
    uniform sampler2D normals;
    uniform sampler2D specular;
#endif

#ifdef LIGHT_COLORING
    layout (rgba8) uniform image2D colorimg3;
#endif

//Pipeline Constants//

//Common Variables//
float NdotU = dot(normal, upVec);
float NdotUmax0 = max(NdotU, 0.0);
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

vec4 glColor = glColorRaw;

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    mat3 tbnMatrix = mat3(
        tangent.x, binormal.x, normal.x,
        tangent.y, binormal.y, normal.y,
        tangent.z, binormal.z, normal.z
    );
#endif

//Common Functions//
void DoFoliageColorTweaks(inout vec3 color, inout vec3 shadowMult, inout float snowMinNdotU, float lViewPos) {
    float factor = max(80.0 - lViewPos, 0.0);
    shadowMult *= 1.0 + 0.004 * noonFactor * factor;

    if (signMidCoordPos.x < 0.0) color.rgb *= 1.08;
    else color.rgb *= 0.93;

    #ifdef SNOWY_WORLD
        if (glColor.g - glColor.b > 0.01)
            snowMinNdotU = min(pow2(pow2(max0(color.g * 2.0 - color.r - color.b))) * 5.0, 0.1);
        else
            snowMinNdotU = min(pow2(pow2(max0(color.g * 2.0 - color.r - color.b))) * 3.0, 0.1) * 0.25;
    #endif
}

void DoBrightBlockTweaks(vec3 color, float minLight, inout vec3 shadowMult, inout float highlightMult) {
    float factor = mix(minLight, 1.0, pow2(pow2(color.r)));
    shadowMult = vec3(factor);
    highlightMult /= factor;
}

void DoOceanBlockTweaks(inout float smoothnessD) {
    smoothnessD *= max0(lmCoord.y - 0.95) * 20.0;
}

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/lighting/mainLighting.glsl"

#ifdef TAA
    #include "/lib/antialiasing/jitter.glsl"
#endif

#if defined GENERATED_NORMALS || defined COATED_TEXTURES
    #include "/lib/util/miplevel.glsl"
#endif

#ifdef GENERATED_NORMALS
    #include "/lib/materials/materialMethods/generatedNormals.glsl"
#endif

#ifdef COATED_TEXTURES
    #include "/lib/materials/materialMethods/coatedTextures.glsl"
#endif

#ifdef CUSTOM_PBR
    #include "/lib/materials/materialHandling/customMaterials.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/misc/colorCodedPrograms.glsl"
#endif

#if ANISOTROPIC_FILTER > 0
    #include "/lib/materials/materialMethods/anisotropicFiltering.glsl"
#endif

//Program//
void main() {
    #if ANISOTROPIC_FILTER == 0
        vec4 color = texture2D(tex, texCoord);
    #else
        vec4 color = textureAF(tex, texCoord);
    #endif

    float smoothnessD = 0.0, materialMask = 0.0, skyLightFactor = 0.0;
    vec3 normalM = normal;

    #if !defined POM || !defined POM_ALLOW_CUTOUT
        if (color.a <= 0.00001) discard;
    #endif

    vec3 colorP = color.rgb;
    color.rgb *= glColor.rgb;

    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif
    float lViewPos = length(viewPos);
    vec3 playerPos = ViewToPlayer(viewPos);

    int subsurfaceMode = 0;
    bool noSmoothLighting = false, noDirectionalShading = false, noVanillaAO = false, centerShadowBias = false, noGeneratedNormals = false;
    float smoothnessG = 0.0, highlightMult = 1.0, emission = 0.0, noiseFactor = 1.0, snowMinNdotU = 0.0, snowFactor = 1.0, noPuddles = 0.0;
    vec2 lmCoordM = lmCoord;
    vec3 shadowMult = vec3(1.0);
	
	#if defined IPBR_OVERRIDE || !defined IPBR
        #ifdef CUSTOM_PBR
            GetCustomMaterials(color, normalM, lmCoordM, NdotU, shadowMult, smoothnessG, smoothnessD, highlightMult, emission, materialMask, viewPos, lViewPos);
        #endif

        if (mat == 10000) { // No directional shading
            noDirectionalShading = true;
        } else if (mat == 10004) { // Grounded Waving Foliage
            subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
            DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, lViewPos);
        } else if (mat == 10008) { // Leaves
            #include "/lib/materials/specificMaterials/terrain/leaves.glsl"
        } else if (mat == 10012) { // Vine
            shadowMult = vec3(1.7);
            centerShadowBias = true;
        } else if (mat == 10016) { // Non-waving Foliage
            subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
        } else if (mat == 10020) { // Upper Waving Foliage
            subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
            DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, lViewPos);
        } else if (mat == 10744) { // Cobweb
            subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
            centerShadowBias = true;
        }

        #ifdef SNOWY_WORLD
        else if (mat == 10132) { // Grass Block:Normal
            if (glColor.b < 0.999) { // Grass Block:Normal:Grass Part
                snowMinNdotU = min(pow2(pow2(color.g)) * 1.9, 0.1);
                color.rgb = color.rgb * 0.5 + 0.5 * (color.rgb / glColor.rgb);
            }
        }
        #endif

        else if (lmCoord.x > 0.99999) lmCoordM.x = 0.95;
    #endif
	
	#ifdef IPBR
        vec3 maRecolor = vec3(0.0);
        #include "/lib/materials/materialHandling/terrainMaterials.glsl"

        #ifdef GENERATED_NORMALS
            if (!noGeneratedNormals) GenerateNormals(normalM, colorP);
        #endif

        #ifdef COATED_TEXTURES
            CoatTextures(color.rgb, noiseFactor, playerPos);
        #endif
    #endif

    #ifdef SNOWY_WORLD
        snowFactor *= 1000.0 * max(NdotU - 0.9, snowMinNdotU) * max0(lmCoord.y - 0.9) * (0.9 - clamp(lmCoord.x, 0.8, 0.9));
        if (snowFactor > 0.0001) {
            const float packSizeSW = 16.0;
            vec3 worldPos = playerPos + cameraPosition;
            vec2 noiseCoord = floor(packSizeSW * worldPos.xz + 0.001) / packSizeSW;
                    noiseCoord += floor(packSizeSW * worldPos.y + 0.001) / packSizeSW;
            float noiseTexture = dot(vec2(0.25, 0.75), texture2D(noisetex, noiseCoord * 0.45).rg);
            vec3 snowColor = mix(vec3(0.65, 0.8, 0.85), vec3(1.0, 1.0, 1.0), noiseTexture * 0.75 + 0.125);

            color.rgb = mix(color.rgb, snowColor + color.rgb * emission * 0.2, snowFactor);
            smoothnessG = mix(smoothnessG, 0.25 + 0.25 * noiseTexture, snowFactor);
            highlightMult = mix(highlightMult, 2.0 - subsurfaceMode * 0.666, snowFactor);
            smoothnessD = mix(smoothnessD, 0.0, snowFactor);
            emission *= 1.0 - snowFactor * 0.85;
        }
    #endif

    #if RAIN_PUDDLES >= 1
        float puddleLightFactor = max0(lmCoord.y * 32.0 - 31.0) * clamp((1.0 - 1.15 * lmCoord.x) * 10.0, 0.0, 1.0);
        float puddleNormalFactor = pow2(max0(NdotUmax0 - 0.5) * 2.0);
        float puddleMixer = puddleLightFactor * inRainy * puddleNormalFactor;
        if (pow2(pow2(wetness)) * puddleMixer - noPuddles > 0.00001) {
            vec2 worldPosXZ = playerPos.xz + cameraPosition.xz;
            vec2 puddleWind = vec2(frameTimeCounter) * 0.03;
            #if WATER_STYLE == 1
                vec2 puddlePosNormal = floor(worldPosXZ * 16.0) * 0.0625;
            #else
                vec2 puddlePosNormal = worldPosXZ;
            #endif

            puddlePosNormal *= 0.1;
            vec2 pNormalCoord1 = puddlePosNormal + vec2(puddleWind.x, puddleWind.y);
            vec2 pNormalCoord2 = puddlePosNormal + vec2(puddleWind.x * -1.5, puddleWind.y * -1.0);
            vec3 pNormalNoise1 = texture2D(noisetex, pNormalCoord1).rgb;
            vec3 pNormalNoise2 = texture2D(noisetex, pNormalCoord2).rgb;
            float pNormalMult = 0.03;

            vec3 puddleNormal = vec3((pNormalNoise1.xy + pNormalNoise2.xy - vec2(1.0)) * pNormalMult, 1.0);
            puddleNormal = clamp(normalize(puddleNormal * tbnMatrix), vec3(-1.0), vec3(1.0));

            #if RAIN_PUDDLES == 1 || RAIN_PUDDLES == 3
                vec2 puddlePosForm = puddlePosNormal * 0.05;
                float pFormNoise  = texture2D(noisetex, puddlePosForm).b        * 3.0;
                      pFormNoise += texture2D(noisetex, puddlePosForm * 0.5).b  * 5.0;
                      pFormNoise += texture2D(noisetex, puddlePosForm * 0.25).b * 8.0;
                      pFormNoise *= sqrt1(wetness) * 0.5625 + 0.4375;
                      pFormNoise  = clamp(pFormNoise - 7.0, 0.0, 1.0);
            #else
                float pFormNoise = wetness;
            #endif
            puddleMixer *= pFormNoise;

            float puddleSmoothnessG = 0.7 - rainFactor * 0.3;
            float puddleHighlight = (1.5 - subsurfaceMode * 0.6 * invNoonFactor);
            smoothnessG = mix(smoothnessG, puddleSmoothnessG, puddleMixer);
            highlightMult = mix(highlightMult, puddleHighlight, puddleMixer);
            smoothnessD = mix(smoothnessD, 1.0, sqrt1(puddleMixer));
            normalM = mix(normalM, puddleNormal, puddleMixer * rainFactor);
        }
    #endif

    #if SHOW_LIGHT_LEVEL > 0
        #include "/lib/misc/showLightLevels.glsl"
    #endif

    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, normalM, lmCoordM,
                noSmoothLighting, noDirectionalShading, noVanillaAO, centerShadowBias,
                subsurfaceMode, smoothnessG, highlightMult, emission);

    #ifdef IPBR
        color.rgb += maRecolor;
    #endif

    #ifdef PBR_REFLECTIONS
        #ifdef OVERWORLD
            skyLightFactor = pow2(max(lmCoord.y - 0.7, 0.0) * 3.33333);
        #else
            skyLightFactor = dot(shadowMult, shadowMult) / 3.0;
        #endif
    #endif

    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color);
    #endif

    /* DRAWBUFFERS:065 */
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(smoothnessD, materialMask, skyLightFactor, 1.0);
    gl_FragData[2] = vec4(mat3(gbufferModelViewInverse) * normalM, 1.0);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out int mat;

out vec2 texCoord;
out vec2 lmCoord;
out vec2 signMidCoordPos;
flat out vec2 absMidCoordPos;
flat out vec2 midCoord;

flat out vec3 upVec, sunVec, northVec, eastVec;
out vec3 normal;

out vec4 glColorRaw;

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat out vec3 binormal, tangent;
#endif

#ifdef POM
    out vec3 viewVector;

    out vec4 vTexCoordAM;
#endif

#if ANISOTROPIC_FILTER > 0
    out vec4 spriteBounds;
#endif

//Uniforms//
#ifdef TAA
    uniform float viewWidth, viewHeight;
#endif

#ifdef WAVING_ANYTHING_TERRAIN
    uniform float frameTimeCounter;

    uniform vec3 cameraPosition;

    uniform mat4 gbufferModelViewInverse;
#endif

//Attributes//
attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    attribute vec4 at_tangent;
#endif

//Common Variables//
vec4 glColor = vec4(1.0);

//Common Functions//

//Includes//
#ifdef TAA
    #include "/lib/antialiasing/jitter.glsl"
#endif

#ifdef WAVING_ANYTHING_TERRAIN
    #include "/lib/materials/materialMethods/wavingBlocks.glsl"
#endif

//Program//
void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = GetLightMapCoordinates();

    glColorRaw = gl_Color;
    if (glColorRaw.a < 0.1) glColorRaw.a = 1.0;
    glColor = glColorRaw;

    normal = normalize(gl_NormalMatrix * gl_Normal);
    upVec = normalize(gbufferModelView[1].xyz);
    eastVec = normalize(gbufferModelView[0].xyz);
    northVec = normalize(gbufferModelView[2].xyz);
    sunVec = GetSunVector();

    midCoord = (gl_TextureMatrix[0] * mc_midTexCoord).st;
    vec2 texMinMidCoord = texCoord - midCoord;
    signMidCoordPos = sign(texMinMidCoord);
    absMidCoordPos  = abs(texMinMidCoord);

    mat = int(mc_Entity.x + 0.5);

    #ifdef WAVING_ANYTHING_TERRAIN
        vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;

        DoWave(position.xyz, mat);

        gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
    #else
        gl_Position = ftransform();

        #ifndef WAVING_LAVA
            if (mat == 10068) { // Lava
                // G8FL735 Fixes Optifine-Iris parity. Optifine has 0.9 gl_Color.rgb on a lot of versions
                glColorRaw.rgb = min(glColorRaw.rgb, vec3(0.9));
            }
        #endif
    #endif

    #ifdef TAA
        gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
    #endif

    #if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
        binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
        tangent  = normalize(gl_NormalMatrix * at_tangent.xyz);
    #endif

    #ifdef POM
        mat3 tbnMatrix = mat3(
            tangent.x, binormal.x, normal.x,
            tangent.y, binormal.y, normal.y,
            tangent.z, binormal.z, normal.z
        );

        viewVector = tbnMatrix * (gl_ModelViewMatrix * gl_Vertex).xyz;

        vTexCoordAM.zw  = abs(texMinMidCoord) * 2;
        vTexCoordAM.xy  = min(texCoord, midCoord - texMinMidCoord);
    #endif

    #if ANISOTROPIC_FILTER > 0
        vec2 spriteRadius = abs(texCoord - mc_midTexCoord.xy);
        vec2 bottomLeft = mc_midTexCoord.xy - spriteRadius;
        vec2 topRight = mc_midTexCoord.xy + spriteRadius;
        spriteBounds = vec4(bottomLeft, topRight);
    #endif
}

#endif
