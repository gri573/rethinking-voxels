//////////////////////////////////
// Complementary Base by EminGT //
//////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

flat in vec2 lmCoord;

flat in vec3 upVec, sunVec, northVec, eastVec;
in vec3 normal;

flat in vec4 glColor;

//Uniforms//
uniform int isEyeInWater;
uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;
uniform float nightVision;

uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform ivec2 atlasSize;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#ifdef CLOUD_SHADOWS
	uniform sampler2D gaux3;
#endif

#if defined PP_BL_SHADOWS || defined PP_SUN_SHADOWS
	uniform sampler2D tex;
	#define ATLASTEX tex
#endif

#if SELECTION_OUTLINE == 1
	uniform float frameTimeCounter;
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

#ifdef TAA
	#include "/lib/util/jitter.glsl"
#endif

//Program//
void main() {
	vec4 color = glColor;

	vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
	#ifdef TAA
		vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
	#else
		vec3 viewPos = ScreenToView(screenPos);
    #endif
	float lViewPos = length(viewPos);
	vec3 playerPos = ViewToPlayer(viewPos);

	vec3 shadowMult = vec3(1.0);
	DoLighting(color.rgb, shadowMult, playerPos, viewPos, lViewPos, normal, lmCoord,
	           false, false, false, 0,
			   0.0, 0.0, 0.0, 0);

	#if SELECTION_OUTLINE > 0
	if (abs(color.a - 0.4) + dot(color.rgb, color.rgb) < 0.01) {
		#if SELECTION_OUTLINE == 1 // Rainbow
			float posFactor = playerPos.x + playerPos.y + playerPos.z + cameraPosition.x + cameraPosition.y + cameraPosition.z;
			color.rgb = clamp(abs(mod(fract(frameTimeCounter*0.25 + posFactor*0.2) * 6.0 + vec3(0.0,4.0,2.0), 6.0) - 3.0) - 1.0,
						0.0, 1.0) * vec3(3.0, 2.0, 3.0);
		#elif SELECTION_OUTLINE == 2 // White
			color.rgb = vec3(2.0);
		#elif SELECTION_OUTLINE == 3 // Red
			color.rgb = vec3(3.0, 0.0, 0.0);
		#elif SELECTION_OUTLINE == 4 // Green
			color.rgb = vec3(0.0, 2.0, 0.0);
		#elif SELECTION_OUTLINE == 5 // Blue
			color.rgb = vec3(0.0, 0.0, 3.0);
		#elif SELECTION_OUTLINE == 6 // Yellow
			color.rgb = vec3(2.0, 2.0, 0.0);
		#elif SELECTION_OUTLINE == 7 // Cyan
			color.rgb = vec3(0.0, 2.0, 2.5);
		#elif SELECTION_OUTLINE == 8 // Magenta
			color.rgb = vec3(2.0, 0.0, 2.0);
		#endif
	}
	#endif

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;

	#ifdef TEMPORAL_FILTER
		/* DRAWBUFFERS:06 */
		gl_FragData[1] = vec4(0.0, 0.0, 0.0, 0.0);
	#endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out vec2 lmCoord;

flat out vec3 upVec, sunVec, northVec, eastVec;
out vec3 normal;

flat out vec4 glColor;

//Uniforms//
#if defined GBUFFERS_LINE || defined TAA
	uniform float viewWidth, viewHeight;
#endif

//Attributes//

//Common Variables//

//Common Functions//

//Includes//
#ifdef TAA
	#include "/lib/util/jitter.glsl"
#endif

//Program//
void main() {
	#ifndef GBUFFERS_LINE
		gl_Position = ftransform();
	#else
		float lineWidth = 2.0;
		vec2 screenSize = vec2(viewWidth, viewHeight);
		const mat4 VIEW_SCALE = mat4(mat3(1.0 - (1.0 / 256.0)));
		vec4 linePosStart = projectionMatrix * VIEW_SCALE * modelViewMatrix * vec4(vaPosition, 1.0);
		vec4 linePosEnd = projectionMatrix * VIEW_SCALE * modelViewMatrix * (vec4(vaPosition + vaNormal, 1.0));
		vec3 ndc1 = linePosStart.xyz / linePosStart.w;
		vec3 ndc2 = linePosEnd.xyz / linePosEnd.w;
		vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * screenSize);
		vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * lineWidth / screenSize;
		if (lineOffset.x < 0.0)
			lineOffset *= -1.0;
		if (gl_VertexID % 2 == 0)
			gl_Position = vec4((ndc1 + vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
		else
			gl_Position = vec4((ndc1 - vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
	#endif

	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif

	lmCoord  = GetLightMapCoordinates();

	glColor = gl_Color;

	normal = normalize(gl_NormalMatrix * gl_Normal);

	upVec = normalize(gbufferModelView[1].xyz);
	eastVec = normalize(gbufferModelView[0].xyz);
	northVec = normalize(gbufferModelView[2].xyz);
	sunVec = GetSunVector();
}

#endif
