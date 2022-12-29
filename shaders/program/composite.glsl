////////////////////////////////////////
// Complementary Reimagined by EminGT //
////////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

flat in float vlFactor;

noperspective in vec2 texCoord;

#if defined BLOOM_FOG && !defined MOTION_BLURRING || LIGHTSHAFT_QUALITY > 0 && (defined OVERWORLD || defined END)
	flat in vec3 upVec, sunVec;
#endif

//Uniforms//
uniform int isEyeInWater;

uniform vec3 fogColor;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

#if defined BLOOM_FOG  && !defined MOTION_BLURRING || LIGHTSHAFT_QUALITY > 0
	uniform vec3 cameraPosition;
	uniform mat4 gbufferProjectionInverse;
#endif

#if LIGHTSHAFT_QUALITY > 0
	#undef OCCLUSION_FILTER
	#undef PP_BL_SHADOWS
	#undef PP_SUN_SHADOWS
	uniform int frameCounter;

	uniform float viewWidth, viewHeight;
	uniform float far, near;
	uniform float blindness;
	uniform float darknessFactor;
	uniform float frameTime;
	uniform float frameTimeCounter;
	uniform float frameTimeSmooth;

	uniform ivec2 eyeBrightness;
	uniform ivec2 atlasSize;

	uniform vec3 skyColor;
	uniform vec3 previousCameraPosition;

	uniform mat4 gbufferProjection;
	uniform mat4 gbufferModelViewInverse;
	uniform mat4 shadowModelView;
	uniform mat4 shadowModelViewInverse;
	uniform mat4 shadowProjection;

	uniform sampler2D colortex3;
	uniform sampler2D noisetex;
#endif

//Pipeline Constants//
//const bool colortex0MipmapEnabled = true;

//Common Variables//
#if defined BLOOM_FOG && !defined MOTION_BLURRING || LIGHTSHAFT_QUALITY > 0 && (defined OVERWORLD || defined END)
	float SdotU = dot(sunVec, upVec);
	float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
#endif

vec2 view = vec2(viewWidth, viewHeight);

#if LIGHTSHAFT_QUALITY > 0 && (defined OVERWORLD || defined END)
	float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
	float sunVisibility2 = sunVisibility * sunVisibility;
	float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
	float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
	float shadowTime = shadowTimeVar2 * shadowTimeVar2;
	float vlTime = min(abs(SdotU) - 0.05, 0.15) / 0.15;
	
	#ifdef OVERWORLD
		vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
	#else
		vec3 lightVec = sunVec;
	#endif
#endif

//Common Functions//

//Includes//
#include "/lib/atmospherics/fog/waterFog.glsl"

#if defined BLOOM_FOG && !defined MOTION_BLURRING
	#include "/lib/atmospherics/fog/bloomFog.glsl"
#endif

#if LIGHTSHAFT_QUALITY > 0
	#ifdef END
		#include "/lib/atmospherics/enderBeams.glsl"
	#endif
	#include "/lib/atmospherics/volumetricLight.glsl"
#endif

//Program//
void main() {
	vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;
	float z0 = texelFetch(depthtex0, texelCoord, 0).r;
	float z1 = texelFetch(depthtex1, texelCoord, 0).r;

	#if LIGHTSHAFT_QUALITY > 0
		vec4 volumetricLight = vec4(0.0);
		float vlFactorM = vlFactor;

		vec3 translucentMult = texelFetch(colortex3, texelCoord, 0).rgb;
		if (translucentMult == vec3(0.0)) translucentMult = vec3(1.0);

		vec4 screenPos = vec4(texCoord, z1, 1.0);
		vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
		viewPos /= viewPos.w;
		float lViewPos = length(viewPos.xyz);
		vec3 nViewPos = normalize(viewPos.xyz);
		#if defined OVERWORLD || defined END
		float VdotL = dot(nViewPos, lightVec);
		float VdotU = dot(nViewPos, upVec);
		#else
		float VdotL = 0.0;
		float VdotU = 0.0;
		#endif

		float dither = texture2D(noisetex, texCoord * view / 128.0).b;
		#ifdef TAA
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif

		volumetricLight = GetVolumetricLight(vlFactorM, translucentMult, lViewPos, nViewPos, VdotL, VdotU, texCoord, z0, z1, dither);

	#endif
	
	if (isEyeInWater == 1) {
		if (z0 == 1.0) color.rgb = waterFogColor;

		const vec3 underwaterMult = vec3(0.65, 0.75, 0.95) * 0.8;
		color.rgb *= underwaterMult;

		#if LIGHTSHAFT_QUALITY > 0
			volumetricLight.rgb *= pow2(underwaterMult);
		#endif
	} else if (isEyeInWater == 2) {
		if (z1 == 1.0) color.rgb = fogColor * 5.0;
		
		#if LIGHTSHAFT_QUALITY > 0
			volumetricLight.rgb *= 0.0;
		#endif
	}
	
	color = pow(color, vec3(2.2));
	
	#if LIGHTSHAFT_QUALITY > 0
		#ifndef OVERWORLD
			volumetricLight.rgb *= volumetricLight.rgb;
		#endif

		color.rgb *= 1.0 - volumetricLight.a * rainFactor * 0.5;
		color += volumetricLight.rgb;
	#endif

	#if defined BLOOM_FOG && !defined MOTION_BLURRING
		vec4 screenPos0 = vec4(texCoord, z0, 1.0);
		vec4 viewPos0 = gbufferProjectionInverse * (screenPos0 * 2.0 - 1.0);
		viewPos0 /= viewPos0.w;
		float lViewPos0 = length(viewPos0.xyz);

		color *= GetBloomFog(lViewPos0); // Reminder: Bloom Fog moves between composite and composite2 depending on Motion Blur
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
	#if defined SCENE_AWARE_LIGHT_SHAFTS && LIGHTSHAFT_QUALITY > 0
		/* DRAWBUFFERS:04 */
		gl_FragData[1] = vec4(vlFactorM, 0.0, 0.0, 1.0);
	#endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out float vlFactor;

noperspective out vec2 texCoord;

#if defined BLOOM_FOG && !defined MOTION_BLURRING || LIGHTSHAFT_QUALITY > 0 && (defined OVERWORLD || defined END)
	flat out vec3 upVec, sunVec;
#endif

//Uniforms//
#ifdef SCENE_AWARE_LIGHT_SHAFTS
	uniform float viewWidth, viewHeight;
	
	uniform sampler2D colortex4;
#endif

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
	gl_Position = ftransform();

	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	#if defined BLOOM_FOG && !defined MOTION_BLURRING || LIGHTSHAFT_QUALITY > 0 && (defined OVERWORLD || defined END)
		upVec = normalize(gbufferModelView[1].xyz);
		sunVec = GetSunVector();
	#endif

	#ifdef SCENE_AWARE_LIGHT_SHAFTS
		vlFactor = texelFetch(colortex4, ivec2(viewWidth-1, viewHeight-1), 0).r;
	#else
		vlFactor = 0.0;
	#endif
}

#endif
