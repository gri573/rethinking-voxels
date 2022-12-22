////////////////////////////////////////
// Complementary Reimagined by EminGT //
////////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

in vec2 texCoord;
in vec2 lmCoord;

flat in vec3 upVec, sunVec;
in vec3 normal;

flat in vec4 glColor;

#ifdef CLOUD_SHADOWS
	flat in vec3 eastVec;
#endif

//Uniforms//
uniform int isEyeInWater;
uniform int frameCounter;

uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float nightVision;
uniform float blindness;
uniform float darknessFactor;

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
uniform sampler2D gaux1;

#ifdef CLOUD_SHADOWS
	uniform sampler2D gaux3;
#endif

#if defined PP_BL_SHADOWS || defined PP_SUN_SHADOWS
	#define ATLASTEX tex
#endif

#if HELD_LIGHTING_MODE >= 1
	uniform int heldItemId;
	uniform int heldItemId2;
#endif

//Pipeline Constants//

//Common Variables//
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

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/lighting/mainLighting.glsl"
#include "/lib/util/dither.glsl"

#if MC_VERSION >= 11500
	#include "/lib/atmospherics/fog/mainFog.glsl"
#endif

//Program//
void main() {
	vec4 color = texture2D(tex, texCoord);
	vec4 colorP = color;
	color *= glColor;

	vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
	vec3 viewPos = ScreenToView(screenPos);
	float lViewPos = length(viewPos);
    vec3 playerPos = ViewToPlayer(viewPos);
	
	float dither = Bayer64(gl_FragCoord.xy);
	#ifdef TAA
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	#endif

	#if defined OVERWORLD && CLOUD_QUALITY > 0
		float cloudLinearDepth = texelFetch(gaux1, texelCoord, 0).r;

		if (cloudLinearDepth > 0.0) // Because Iris changes the pipeline position of opaque particles
		if (pow2(cloudLinearDepth + OSIEBCA * dither) * far < min(lViewPos, far)) discard;
	#endif

	vec3 shadowMult = vec3(1.0);
	vec2 lmCoordM = lmCoord;
	float emission = 0.0, materialMask = OSIEBCA * 4.0; // No SSAO, No TAA

	#ifdef IPBR
	if (atlasSize.x < 900.0) { // We don't want to detect particles from the block atlas
		if (color.b > 1.15 * (color.r + color.g) && color.g > color.r * 1.25 && color.g < 0.425 && color.b > 0.75) { // Water Particle
			color.rgb = sqrt3(color.rgb) * 0.35;
		} else if (color.r == color.g && color.r - 0.5 * color.b < 0.06) { // Underwater Particle
			if (isEyeInWater == 1) {
				color.rgb = sqrt2(color.rgb) * 0.35;
				if (fract(playerPos.y + cameraPosition.y) > 0.25) discard;
			}
		} else if (color.a < 0.99 && dot(color.rgb, color.rgb) < 1.0) { // Campfire Smoke
			color.a *= 0.2;
			materialMask = 0.0;
		} else if (max(abs(colorP.r - colorP.b), abs(colorP.b - colorP.g)) < 0.001) { // Grayscale Particles
			float dotColor = dot(color.rgb, color.rgb);
			if (dotColor > 0.25 && color.g < 0.5 && (color.b > color.r * 1.1 && color.r > 0.3 || color.r > (color.g + color.b) * 3.0)) {
				// Ender Particle, Crying Obsidian Particle, Redstone Particle
				emission = max(color.r, 0.2) * 4.0;
				color.rgb *= color.rgb;
				lmCoordM = vec2(0.0);
			}
		}
		//color.rgb = vec3(fract(float(frameCounter) * 0.01), fract(float(frameCounter) * 0.015), fract(float(frameCounter) * 0.02));
	}

	bool noSmoothLighting = false;
	#else
	bool noSmoothLighting = true;
	#endif

	DoLighting(color.rgb, shadowMult, playerPos, viewPos, lViewPos, normal, lmCoordM,
	           noSmoothLighting, false, false, 0,
			   0.0, 1.0, emission, 0);

	#ifdef IPBR
		color.rgb *= 1.5;
	#endif

	#if MC_VERSION >= 11500
		vec3 nViewPos = normalize(viewPos);

		float VdotU = dot(nViewPos, upVec);
		float VdotS = dot(nViewPos, sunVec);

		DoFog(color.rgb, lViewPos, playerPos, VdotU, VdotS, dither);
	#endif

	// Blending
	vec3 translucentMult = mix(vec3(1.0), color.rgb, sqrt1(color.a)) * (1.0 - pow(color.a, 64.0));
	translucentMult.r += OSIEBCA;
	
	/* DRAWBUFFERS:013 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(0.0, materialMask, 0.0, 1.0);
	gl_FragData[2] = vec4(translucentMult, 1.0);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;
out vec2 lmCoord;

flat out vec3 upVec, sunVec;
out vec3 normal;

flat out vec4 glColor;

#ifdef CLOUD_SHADOWS
	flat out vec3 eastVec;
#endif

//Uniforms//

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
	gl_Position = ftransform();

	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmCoord  = GetLightMapCoordinates();

	glColor = gl_Color;

	normal = normalize(gl_NormalMatrix * gl_Normal);
	upVec = normalize(gbufferModelView[1].xyz);
	sunVec = GetSunVector();
	
	#ifdef FLICKERING_FIX
		gl_Position.z -= 0.000002;
	#endif

	#ifdef CLOUD_SHADOWS
		eastVec = normalize(gbufferModelView[0].xyz);
	#endif
}

#endif
