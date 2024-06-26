////////////////////////////////////////
// Complementary Reimagined by EminGT //
////////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

flat in float vlFactor;

noperspective in vec2 texCoord;

flat in vec3 upVec, sunVec;

//Uniforms//
uniform int isEyeInWater;

uniform float viewWidth, viewHeight;
vec2 view = vec2(viewWidth, viewHeight);

uniform vec3 cameraPosition;

uniform mat4 gbufferProjectionInverse;

uniform sampler2D colortex0;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

	#undef BL_SHADOW_MODE
	#undef PP_BL_SHADOWS
	#undef PP_SUN_SHADOWS
	#ifndef PER_BLOCK_LIGHT
		#define PER_BLOCK_LIGHT
	#endif
#if defined LIGHTSHAFTS_ACTIVE || WATER_QUALITY >= 3
	uniform float frameTimeCounter;
	uniform float far, near;

	uniform mat4 gbufferProjection;
	uniform mat4 gbufferModelViewInverse;
	uniform mat4 shadowModelView;
	uniform mat4 shadowProjection;

	uniform sampler2D noisetex;
	
	#if LIGHTSHAFT_BEHAVIOUR == 1
		uniform mat4 shadowModelViewInverse;
		uniform mat4 shadowProjectionInverse;

		#include "/lib/util/textRendering.glsl"

		void beginTextM(int textSize, vec2 offset) {
			beginText(ivec2(vec2(viewWidth, viewHeight) * texCoord) / textSize, ivec2(0 + offset.x, viewHeight / textSize - offset.y));
			text.bgCol = vec4(0.0);
		}
	#endif
#endif

#ifdef LIGHTSHAFTS_ACTIVE
	uniform int frameCounter;

	//uniform float viewWidth, viewHeight;
	uniform float blindness;
	uniform float darknessFactor;
	uniform float frameTime;
	uniform float frameTimeSmooth;

	uniform ivec2 eyeBrightness;
	uniform ivec2 eyeBrightnessSmooth;
	uniform ivec2 atlasSize;

	uniform vec3 skyColor;
	uniform vec3 previousCameraPosition;

	uniform sampler2D colortex15;
	#define ATLASTEX colortex15
	uniform sampler2D colortex3;
	uniform sampler2D shadowtex0;
	uniform sampler2DShadow shadowtex1;
	uniform sampler2D shadowcolor1;
#endif

#if WATER_QUALITY >= 3
	uniform sampler2D colortex1;
#endif

//Pipeline Constants//
//const bool colortex0MipmapEnabled = true;

//Common Variables//
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;

#ifdef LIGHTSHAFTS_ACTIVE
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

#ifdef LIGHTSHAFTS_ACTIVE
	#ifdef END
		#include "/lib/atmospherics/enderBeams.glsl"
	#endif
	#include "/lib/atmospherics/volumetricLight.glsl"

	#ifdef ATM_COLOR_MULTS
		#include "/lib/colors/colorMultipliers.glsl"
	#endif
#endif

#if WATER_QUALITY >= 3
	#include "/lib/util/spaceConversion.glsl"

	#include "/lib/materials/materialMethods/refraction.glsl"
#endif

//Program//
void main() {
	vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;
	vec3 tex4val = texelFetch(colortex4, texelCoord, 0).rgb;
	float z0 = texelFetch(depthtex0, texelCoord, 0).r;
	float z1 = texelFetch(depthtex1, texelCoord, 0).r;

	#if defined LIGHTSHAFTS_ACTIVE || WATER_QUALITY >= 3 || defined BLOOM_FOG && !defined MOTION_BLURRING
		vec4 screenPos = vec4(texCoord, z0, 1.0);
		vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
		viewPos /= viewPos.w;
		float lViewPos = length(viewPos.xyz);
	#endif

	#if WATER_QUALITY >= 3
		DoRefraction(color, z0, z1, viewPos.xyz, lViewPos);
	#endif

	vec4 volumetricLight = vec4(0.0);

	#ifdef LIGHTSHAFTS_ACTIVE
		float vlFactorM = vlFactor;

		/* The "1.0 - translucentMult" trick is done because of the default color attachment
		value being vec3(0.0). This makes it vec3(1.0) to avoid issues especially on improved glass */
		vec3 translucentMult = 1.0 - texelFetch(colortex3, texelCoord, 0).rgb;

		vec3 nViewPos = normalize(viewPos.xyz);
		#if defined OVERWORLD && defined REALTIME_SHADOWS || defined END
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

		vec4 screenPos1 = vec4(texCoord, z1, 1.0);
		vec4 viewPos1 = gbufferProjectionInverse * (screenPos1 * 2.0 - 1.0);
		viewPos1 /= viewPos1.w;
		float lViewPos1 = length(viewPos1.xyz);

		volumetricLight = GetVolumetricLight(color, vlFactorM, translucentMult, lViewPos1, nViewPos, VdotL, VdotU, texCoord, z0, z1, dither);
		
		#ifdef ATM_COLOR_MULTS
			volumetricLight.rgb *= GetAtmColorMult();
		#endif
	#endif

	/*color.rgb = vec3(lViewPos);
	if (gl_FragCoord.x > 960)
	color.rgb = vec3(GetApproxDistance(z1));
	color.rgb *= 0.02;
	color.rgb = min(color.rgb, vec3(2.0));*/
	
	if (isEyeInWater == 1) {
		if (z0 == 1.0) color.rgb = waterFogColor;

		const vec3 underwaterMult = vec3(0.80, 0.87, 0.97);
		color.rgb *= underwaterMult * 0.85;

		volumetricLight.rgb *= pow2(underwaterMult * 0.71);
	} else if (isEyeInWater == 2) {
		if (z1 == 1.0) color.rgb = fogColor * 5.0;
		
		volumetricLight.rgb *= 0.0;
	}
	
	color = pow(color, vec3(2.2));
	
	#ifdef LIGHTSHAFTS_ACTIVE
		#ifndef OVERWORLD
			volumetricLight.rgb *= volumetricLight.rgb;
		#endif
		color += volumetricLight.rgb;
	#endif

	#if defined BLOOM_FOG && !defined MOTION_BLURRING
		color *= GetBloomFog(lViewPos); // Reminder: Bloom Fog moves between composite and composite2 depending on Motion Blur
	#endif
	
	/*//if (texCoord.x < 0.25 && texCoord.y < 0.25)
	vec4 wpos = vec4(shadowModelView[3][0], shadowModelView[3][1], shadowModelView[3][2], shadowModelView[3][3]);
	wpos = shadowProjection * wpos;
	wpos /= wpos.w;
	vec4 shadowPosition = DistortShadow(wpos, 1.0 - shadowMapBias);
	float checkS = texture2D(shadowtex0, texCoord).x;
	vec3 checkColor = vec3(1.0 - checkS);
	checkColor *= mix(vec3(0,1,0), vec3(0,0,1), clamp((checkS-shadowPosition.z)*65536.0,0.0,1.0));
	if (checkS > 0.55) checkColor = vec3(checkColor.g + checkColor.b,0,0) * 3.0;
	color += checkColor * 2.0;*/

	//if (texCoord.y < 0.05 && vlFactor > texCoord.x) color = vec3(1,0,1);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
	#if LIGHTSHAFT_QUALITY > 0 && defined OVERWORLD && defined REALTIME_SHADOWS || defined END // Can't use LIGHTSHAFTS_ACTIVE on Optifine
		/* DRAWBUFFERS:04 */
		gl_FragData[1] = vec4(tex4val, vlFactorM);
	#endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out float vlFactor;

noperspective out vec2 texCoord;

flat out vec3 upVec, sunVec;

//Uniforms//
#if LIGHTSHAFT_BEHAVIOUR == 1 || defined END
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

	upVec = normalize(gbufferModelView[1].xyz);
	sunVec = GetSunVector();

	#if LIGHTSHAFT_BEHAVIOUR == 1 || defined END
		vlFactor = texelFetch(colortex4, ivec2(viewWidth-1, viewHeight-1), 0).a;
	#else
		#if LIGHTSHAFT_BEHAVIOUR == 2
			vlFactor = 0.0;
		#elif LIGHTSHAFT_BEHAVIOUR == 3
			vlFactor = 1.0;
		#endif
	#endif
}

#endif
