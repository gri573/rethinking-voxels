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

flat in vec3 upVec, sunVec, northVec, eastVec;
in vec3 normal;

in vec4 glColor;

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS
	flat in vec3 binormal, tangent;
#endif

//Uniforms//
uniform int isEyeInWater;
uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;
uniform float nightVision;
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

uniform sampler2D tex;

#if defined PP_BL_SHADOWS || defined PP_SUN_SHADOWS
	#define ATLASTEX tex
#endif

#if defined NETHER || RAIN_PUDDLES >= 1 || defined COATED_TEXTURES
	uniform sampler2D noisetex;
#endif

#if RAIN_PUDDLES >= 1
	uniform float wetness;
	uniform float isRainy;
#endif

#ifdef CLOUD_SHADOWS
	uniform sampler2D gaux3;
#endif

#if SHOW_LIGHT_LEVEL == 1 || HELD_LIGHTING_MODE >= 1
	uniform int heldItemId;
	uniform int heldItemId2;
#endif

#if HELD_LIGHTING_MODE == 0 && SHOW_LIGHT_LEVEL == 2
	uniform int heldBlockLightValue;
	uniform int heldBlockLightValue2;
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
void DoFoliageColorTweaks(inout vec3 color, inout vec3 shadowMult, float lViewPos) {
	float factor = max(80.0 - lViewPos, 0.0);
	shadowMult *= 1.0 + 0.005 * noonFactor * factor;

	if (signMidCoordPos.x < 0.0) shadowMult *= 1.15;
	else shadowMult *= 0.87;
}

void DoBrightBlockTweaks(inout vec3 shadowMult, inout float highlightMult) {
	shadowMult = vec3(0.7);
	highlightMult *= 1.428;
}

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/lighting/mainLighting.glsl"

#ifdef TAA
	#include "/lib/util/jitter.glsl"
#endif

#if defined GENERATED_NORMALS || defined COATED_TEXTURES
	#include "/lib/util/miplevel.glsl"
#endif

#ifdef GENERATED_NORMALS
	#include "/lib/materials/generatedNormals.glsl"
#endif

#ifdef COATED_TEXTURES
	#include "/lib/materials/coatedTextures.glsl"
#endif

//Program//
void main() {
	vec4 color = texture2D(tex, texCoord);

	float smoothnessD = 0.0, materialMask = 0.0, skyLightFactor = 0.0;
	vec3 normalM = normal;
	if (color.a > 0.00001) {
		#ifdef GENERATED_NORMALS
			vec3 colorP = color.rgb;
		#endif
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
		bool noSmoothLighting = false, noDirectionalShading = false, noVanillaAO = false;
		#if RAIN_PUDDLES >= 1
			float noPuddles = 0.0;
		#endif
		#ifdef GENERATED_NORMALS
			bool noGeneratedNormals = false;
		#endif
		float smoothnessG = 0.0, highlightMult = 1.0, emission = 0.0, noiseFactor = 1.0;
		vec2 lmCoordM = lmCoord;
		vec3 shadowMult = vec3(1.0);
		#ifdef IPBR
			#include "/lib/materials/terrainMaterials.glsl"

			#ifdef GENERATED_NORMALS
				if (!noGeneratedNormals) GenerateNormals(normalM, colorP);
			#endif

			#ifdef COATED_TEXTURES
				CoatTextures(color.rgb, noiseFactor, playerPos);
			#endif
		#else
			if (mat == 10000) { // No directional shading
				noDirectionalShading = true;
			} else if (mat == 10004) { // Grounded Waving Foliage
				subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
			} else if (mat == 10008) { // Leaves
				#include "/lib/materials/specificMaterials/leaves.glsl"
			} else if (mat == 10012) { // Vine
				#include "/lib/materials/specificMaterials/leaves.glsl"
				shadowMult = vec3(1.2);
			} else if (mat == 10016) { // Non-waving Foliage
				subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
			} else if (mat == 10020) { // Upper Waving Foliage
				subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
			}

			else if (lmCoord.x > 0.99999) lmCoordM.x = 0.95;
		#endif

		#if RAIN_PUDDLES >= 1
			float puddleLightFactor = max0(lmCoord.y * 32.0 - 31.0) * clamp((1.0 - 1.15 * lmCoord.x) * 10.0, 0.0, 1.0);
			float puddleMixer = puddleLightFactor * isRainy;
			if (NdotU + pow2(pow2(wetness)) * puddleMixer - noPuddles > 1.0001) {
				mat3 tbnMatrix = mat3(
					tangent.x, binormal.x, normal.x,
					tangent.y, binormal.y, normal.y,
					tangent.z, binormal.z, normal.z
				);

				vec2 worldPosXZ = playerPos.xz + cameraPosition.xz;
				#if WATER_STYLE == 1
					vec2 puddlePosNormal = floor(worldPosXZ * 16.0) * 0.0625;
					vec2 puddleWind = vec2(frameTimeCounter) * 0.015;
				#else
					vec2 puddlePosNormal = worldPosXZ;
					vec2 puddleWind = vec2(frameTimeCounter) * 0.03;
				#endif

				puddlePosNormal *= 0.1;
				vec2 pNormalCoord1 = puddlePosNormal + vec2(puddleWind.x, puddleWind.y);
				vec2 pNormalCoord2 = puddlePosNormal + vec2(puddleWind.x * -1.5, puddleWind.y * -1.0);
				vec3 pNormalNoise1 = texture2D(noisetex, pNormalCoord1).rgb;
				vec3 pNormalNoise2 = texture2D(noisetex, pNormalCoord2).rgb;
				float pNormalMult = 0.03;
            
				vec3 puddleNormal = vec3((pNormalNoise1.xy + pNormalNoise2.xy - vec2(1.0)) * pNormalMult, 1.0);
				puddleNormal = clamp(normalize(puddleNormal * tbnMatrix), vec3(-1.0), vec3(1.0));

				#if RAIN_PUDDLES < 2
					vec2 puddlePosForm = puddlePosNormal * 0.05;
					float pFormNoise  = texture2D(noisetex, puddlePosForm).b   * 3.0;
						  pFormNoise += texture2D(noisetex, puddlePosForm * 0.5).b  * 5.0;
						  pFormNoise += texture2D(noisetex, puddlePosForm * 0.25).b * 8.0;
						  pFormNoise *= sqrt1(wetness) * 0.5625 + 0.4375;
						  pFormNoise  = clamp(pFormNoise - 7.0, 0.0, 1.0);
				#else
					float pFormNoise = wetness;
				#endif
				puddleMixer *= pFormNoise;

				float puddleSmoothnessG = 0.7 - rainFactor * 0.3;
				float puddleHighlight = (1.5 - subsurfaceMode * 0.6 * (1.0 - noonFactor));
				smoothnessG = mix(smoothnessG, puddleSmoothnessG, puddleMixer);
				highlightMult = mix(highlightMult, puddleHighlight, puddleMixer);
				smoothnessD = mix(smoothnessD, 1.0, sqrt1(puddleMixer));
				normalM = mix(normalM, puddleNormal, puddleMixer * rainFactor);
			}
		#endif

		#if SHOW_LIGHT_LEVEL > 0
			#include "/lib/misc/showLightLevels.glsl"
		#endif

		DoLighting(color.rgb, shadowMult, playerPos, viewPos, lViewPos, normalM, lmCoordM,
		           noSmoothLighting, noDirectionalShading, noVanillaAO, subsurfaceMode,
				   smoothnessG, highlightMult, emission, mat);

		#ifdef PBR_REFLECTIONS
			#ifdef OVERWORLD
				skyLightFactor = pow2(max(lmCoord.y - 0.7, 0.0) * 3.33333);
			#else
				skyLightFactor = dot(shadowMult, shadowMult) / 3.0;
			#endif
		#endif

		normalM = mat3(gbufferModelViewInverse) * normalM;
	} else discard;

	/* DRAWBUFFERS:01 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(smoothnessD, materialMask, skyLightFactor, 1.0);

	#if REFLECTION_QUALITY >= 3 && RP_MODE != 0
		/* DRAWBUFFERS:015 */
		gl_FragData[2] = vec4(normalM, 1.0);
	#endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out int mat;

out vec2 texCoord;
out vec2 lmCoord;
out vec2 signMidCoordPos;
flat out vec2 absMidCoordPos;

flat out vec3 upVec, sunVec, northVec, eastVec;
out vec3 normal;

out vec4 glColor;

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS
	flat out vec3 binormal, tangent;
#endif

//Uniforms//
#ifdef TAA
	uniform float viewWidth, viewHeight;
#endif

#ifdef WAVING_ANYTHING
	uniform float frameTimeCounter;

	uniform vec3 cameraPosition;

	uniform mat4 gbufferModelViewInverse;
#endif

//Attributes//
attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS
	attribute vec4 at_tangent;
#endif

//Common Variables//

//Common Functions//

//Includes//
#ifdef TAA
	#include "/lib/util/jitter.glsl"
#endif

#ifdef WAVING_ANYTHING
	#include "/lib/materials/wavingBlocks.glsl"
#endif

//Program//
void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmCoord  = GetLightMapCoordinates();

	glColor = gl_Color;
	if (glColor.a < 0.1) glColor.a = 1.0;

	normal = normalize(gl_NormalMatrix * gl_Normal);
	upVec = normalize(gbufferModelView[1].xyz);
	eastVec = normalize(gbufferModelView[0].xyz);
	northVec = normalize(gbufferModelView[2].xyz);
	sunVec = GetSunVector();

	vec2 midCoord = (gl_TextureMatrix[0] * mc_midTexCoord).st;
	vec2 texMinMidCoord = texCoord - midCoord;
	signMidCoordPos = sign(texMinMidCoord);
	absMidCoordPos  = abs(texMinMidCoord);

	mat = int(mc_Entity.x + 0.5);
	mat = 10000 * (mat / 10000) + 4 * ((mat % 2000) / 4);

	#ifdef WAVING_ANYTHING
		vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;

		DoWave(position.xyz, mat);

		#ifdef FLICKERING_FIX
			//position.y += max0(0.002 - abs(mat - 10256.0)); // Iron Bars
		#endif

		gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
	#else
		gl_Position = ftransform();
	
		#ifdef FLICKERING_FIX
			//if (mat == 10256) gl_Position.z -= 0.00001; // Iron Bars
		#endif
	#endif

	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif

	#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS
		binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
		tangent  = normalize(gl_NormalMatrix * at_tangent.xyz);
	#endif
}

#endif
