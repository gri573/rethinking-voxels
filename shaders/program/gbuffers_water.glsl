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

flat in vec3 upVec, sunVec, northVec, eastVec;
in vec3 normal;

in vec4 glColor;

#if WATER_STYLE >= 2 || RAIN_PUDDLES >= 1 && WATER_STYLE == 1 || defined GENERATED_NORMALS
	flat in vec3 binormal, tangent;
#endif

#if WATER_STYLE >= 2 || defined FANCY_NETHERPORTAL || defined GENERATED_NORMALS
	in vec2 signMidCoordPos;
	flat in vec2 absMidCoordPos;
#endif

#if defined FANCY_NETHERPORTAL || WATER_STYLE >= 3
	in vec3 viewVector;
#endif

//Uniforms//
uniform int isEyeInWater;
uniform int frameCounter;

uniform float near;
uniform float far;
uniform float nightVision;
uniform float blindness;
uniform float darknessFactor;
uniform float frameTimeCounter;

uniform ivec2 atlasSize;

uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float viewWidth;
uniform float viewHeight;

uniform sampler2D tex;

#if defined PP_BL_SHADOWS || defined PP_SUN_SHADOWS
	#define ATLASTEX tex
#endif

#if WATER_QUALITY >= 2 || WATER_STYLE >= 2 || defined FANCY_NETHERPORTAL
	uniform sampler2D noisetex;
#endif

#if defined OVERWORLD && CLOUD_QUALITY > 0
	uniform sampler2D gaux1;
#endif

#if WATER_QUALITY >= 2 || REFLECTION_QUALITY >= 2
	uniform sampler2D depthtex1;
#endif

#if REFLECTION_QUALITY >= 2
	uniform mat4 gbufferProjection;

	uniform sampler2D gaux2;
#endif

#if RAIN_PUDDLES >= 1
	uniform float isRainy;
#endif

#ifdef CLOUD_SHADOWS
	uniform sampler2D gaux3;
#endif

#if HELD_LIGHTING_MODE >= 1
	uniform int heldItemId;
	uniform int heldItemId2;
#endif

//Pipeline Constants//

//Common Variables//
float NdotU = dot(normal, upVec);
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

#ifdef OVERWORLD
	vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
	vec3 lightVec = sunVec;
#endif

//Common Functions//
float GetLinearDepth(float depth) {
	return (2.0 * near) / (far + near - depth * (far - near));
}

#if REFLECTION_QUALITY >= 2
	vec3 nvec3(vec4 pos) {
		return pos.xyz/pos.w;
	}

	vec4 nvec4(vec3 pos) {
		return vec4(pos.xyz, 1.0);
	}

	float cdist(vec2 coord) {
		return max(abs(coord.s-0.5) * 1.82, abs(coord.t-0.5) * 2.0);
	}
#endif

#if WATER_STYLE >= 3
	float GetWaterHeightMap(vec2 waterPos, vec3 nViewPos, vec2 wind) {
		vec2 noiseA = 0.5 - texture2D(noisetex, waterPos - wind * 0.6).rg;
		vec2 noiseB = 0.5 - texture2D(noisetex, waterPos * 2.0 + wind).rg;

		return noiseA.r - noiseA.r * noiseB.r + noiseB.r * 0.6 + (noiseA.g + noiseB.g) * 2.5;
	}
#endif

//Includes//
#include "/lib/util/dither.glsl"
#include "/lib/util/spaceConversion.glsl"
#include "/lib/lighting/mainLighting.glsl"
#include "/lib/atmospherics/fog/mainFog.glsl"

#if REFLECTION_QUALITY >= 2 && defined OVERWORLD
	#include "/lib/atmospherics/sky.glsl"
#endif

#ifdef TAA
	#include "/lib/util/jitter.glsl"
#endif

#if WATER_STYLE >= 2 || defined GENERATED_NORMALS || defined COATED_TEXTURES
	#include "/lib/util/miplevel.glsl"
#endif

#ifdef GENERATED_NORMALS
	#include "/lib/materials/generatedNormals.glsl"
#endif

//Program//
void main() {
	vec4 colorP = texture2D(tex, texCoord);
	vec4 color = colorP * vec4(glColor.rgb, 1.0);

	vec2 screenCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
	vec3 screenPos = vec3(screenCoord, gl_FragCoord.z);
	#ifdef TAA
		vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
	#else
		vec3 viewPos = ScreenToView(screenPos);
    #endif
	float lViewPos = length(viewPos);

	float dither = Bayer64(gl_FragCoord.xy);
	#ifdef TAA
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	#endif

	#if defined OVERWORLD && CLOUD_QUALITY > 0
		float cloudLinearDepth = texelFetch(gaux1, texelCoord, 0).r;

		if (pow2(cloudLinearDepth + OSIEBCA * dither) * far < min(lViewPos, far)) discard;
	#endif

	vec3 nViewPos = normalize(viewPos);
    vec3 playerPos = ViewToPlayer(viewPos);
	float VdotU = dot(nViewPos, upVec);
	float VdotS = dot(nViewPos, sunVec);
	float VdotN = dot(nViewPos, normal);

	// Materials
	vec4 translucentMult = vec4(1.0);
	bool noSmoothLighting = false, noDirectionalShading = false, translucentMultAlreadyCalculated = false;
	#ifdef GENERATED_NORMALS
		bool noGeneratedNormals = false;
	#endif
	float smoothnessG = 0.0, highlightMult = 1.0, reflectMult = 1.0, emission = 0.0;
	vec2 lmCoordM = lmCoord;
	vec3 normalM = VdotN > 0.0 ? -normal : normal; // Iris' Broken Water Normal Workaround
	vec3 shadowMult = vec3(1.0);
	float fresnel = pow2(clamp(1.0 + dot(normalM, nViewPos), 0.0, 1.0));

	#ifdef IPBR
		#include "/lib/materials/translucentMaterials.glsl"

		#ifdef GENERATED_NORMALS
			if (!noGeneratedNormals) GenerateNormals(normalM, colorP.rgb * colorP.a * 1.5);
		#endif
	#else
		if (mat == 31000) { // Water
			#include "/lib/materials/specificMaterials/translucents/water.glsl"
		} else {
			fresnel *= 0.7;
		}
	#endif

	// Blending
	if (!translucentMultAlreadyCalculated) {
		translucentMult = vec4(mix(vec3(1.0), normalize(pow2(color.rgb)) * pow2(color.rgb), sqrt1(color.a)) * (1.0 - pow(color.a, 64.0)), 1.0);
		translucentMult = mix(translucentMult, vec4(1.0), min1(lViewPos * TRANSLUCENT_BLEND_FALLOFF_MULT));
	}

	// Lighting
	DoLighting(color.rgb, shadowMult, playerPos, viewPos, lViewPos, normalM, lmCoordM,
	           noSmoothLighting, noDirectionalShading, false, 0,
			   smoothnessG, highlightMult, emission, mat);

	// Reflections
	#if REFLECTION_QUALITY >= 2
		if (fresnel > 0.000001) {
			#include "/lib/materials/translucentReflections.glsl"
		}
    #endif

	DoFog(color.rgb, lViewPos, playerPos, VdotU, VdotS, dither);

	/* DRAWBUFFERS:03 */
	gl_FragData[0] = color;
	gl_FragData[1] = translucentMult;
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out int mat;

out vec2 texCoord;
out vec2 lmCoord;

flat out vec3 upVec, sunVec, northVec, eastVec;
out vec3 normal;

out vec4 glColor;

#if WATER_STYLE >= 2 || RAIN_PUDDLES >= 1 && WATER_STYLE == 1 || defined GENERATED_NORMALS
	flat out vec3 binormal, tangent;
#endif

#if WATER_STYLE >= 2 || defined FANCY_NETHERPORTAL || defined GENERATED_NORMALS
	out vec2 signMidCoordPos;
	flat out vec2 absMidCoordPos;
#endif

#if defined FANCY_NETHERPORTAL || WATER_STYLE >= 3
	out vec3 viewVector;
#endif

//Uniforms//
#ifdef TAA
	uniform float viewWidth, viewHeight;
#endif

//Attributes//
attribute vec4 mc_Entity;

#if WATER_STYLE >= 2 || defined FANCY_NETHERPORTAL || RAIN_PUDDLES >= 1 && WATER_STYLE == 1 || defined GENERATED_NORMALS
	attribute vec4 mc_midTexCoord;

	attribute vec4 at_tangent;
#endif

//Common Variables//

//Common Functions//

//Includes//
#ifdef TAA
	#include "/lib/util/jitter.glsl"
#endif

//Program//
void main() {
	gl_Position = ftransform();
	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif

	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmCoord  = GetLightMapCoordinates();

	glColor = gl_Color;

	normal = normalize(gl_NormalMatrix * gl_Normal);
	upVec = normalize(gbufferModelView[1].xyz);
	eastVec = normalize(gbufferModelView[0].xyz);
	northVec = normalize(gbufferModelView[2].xyz);
	sunVec = GetSunVector();

	mat = int(mc_Entity.x + 0.5);

	#if WATER_STYLE >= 2 || RAIN_PUDDLES >= 1 && WATER_STYLE == 1 || defined GENERATED_NORMALS
		binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
		tangent  = normalize(gl_NormalMatrix * at_tangent.xyz);
	#endif

	#if WATER_STYLE >= 2 || defined FANCY_NETHERPORTAL || defined GENERATED_NORMALS
		vec2 midCoord = (gl_TextureMatrix[0] * mc_midTexCoord).st;
		vec2 texMinMidCoord = texCoord - midCoord;
		signMidCoordPos = sign(texMinMidCoord);
		absMidCoordPos  = abs(texMinMidCoord);
	#endif

	#if defined FANCY_NETHERPORTAL || WATER_STYLE >= 3
		#ifndef GENERATED_NORMALS
			vec3 binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
			vec3 tangent  = normalize(gl_NormalMatrix * at_tangent.xyz);
		#endif

        mat3 tbnMatrix = mat3(
            tangent.x, binormal.x, normal.x,
            tangent.y, binormal.y, normal.y,
            tangent.z, binormal.z, normal.z
        );

		viewVector = tbnMatrix * (gl_ModelViewMatrix * gl_Vertex).xyz;
	#endif

	gl_Position.z -= 0.0001;
}

#endif
