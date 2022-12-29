////////////////////////////////////////
// Complementary Reimagined by EminGT //
////////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

flat in int mat;

in vec2 texCoord;

flat in vec3 sunVec, upVec;

in vec4 position;
flat in vec4 glColor;

//Uniforms//
uniform int isEyeInWater;

uniform vec3 cameraPosition;

uniform sampler2D tex;
uniform sampler2D noisetex;

#if WATER_STYLE >= 3
	uniform float frameTimeCounter;
#endif

//Pipeline Constants//

//Common Variables//
float SdotU = dot(sunVec, upVec);
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;

//Common Functions//

//Includes//

//Program//
void main() {
	vec4 color1 = texture2DLod(tex, texCoord, 0);
	vec4 color2 = color1;
	
	color2.rgb *= 0.25;

	if (mat < 31008) {
		if (mat < 31000) {
			if (mat >= 30000) { // Natural Shadow Color Calculation
				color1.rgb *= glColor.rgb;
				color1.rgb = mix(vec3(1.0), color1.rgb, pow(color1.a, (1.0 - color1.a) * 0.5) * 1.05);
				color1.rgb *= 1.0 - pow(color1.a, 64.0);
				color1.rgb *= 0.25; // Natural Strength

				color2.rgb = normalize(color1.rgb) * 0.5;
			} else { // Lower limit
				color1.rgb *= 0.25; // Natural Strength
			}
		} else {
			if (mat == 31000) { // Water
				vec3 worldPos = position.xyz + cameraPosition;

				#if WATER_STYLE < 3
					color1.rgb = color1.rgb * pow2(GetLuminance(color1.rgb));
				#else
					vec2 causticWind = vec2(frameTimeCounter * 0.04, 0.0);
					float caustic = texture2D(noisetex, worldPos.xz * 0.05 + causticWind).g;
					      caustic += texture2D(noisetex, worldPos.xz * 0.1 - causticWind).g;
					color1.rgb = vec3(pow2(caustic) * 0.3 + 0.1);
				#endif
				color1.rgb *= glColor.rgb * vec3(0.6, 0.8, 1.1);
				
				vec2 waterWind = vec2(syncedTime * 0.01, 0.0);
				float waterNoise = texture2D(noisetex, worldPos.xz * 0.012 + waterWind).g;

				float factor = max(2.5 - 0.025 * length(position.xz), 0.8333);
				waterNoise = pow(waterNoise, factor) * factor * 1.3;

				color2.rgb = normalize(sqrt1(glColor.rgb)) * vec3(0.24, 0.22, 0.26) * waterNoise * (1.0 + sunVisibility - rainFactor);
			} else /*if (mat == 31004)*/ { // Ice
				color1.rgb *= color1.rgb;
				color1.rgb *= color1.rgb;
				color1.rgb = mix(vec3(1.0), color1.rgb, pow(color1.a, (1.0 - color1.a) * 0.5) * 1.05);
				color1.rgb *= 1.0 - pow(color1.a, 64.0);
				color1.rgb *= 0.35;

				color2.rgb = normalize(pow(color1.rgb, vec3(0.25))) * 0.5;
			}
		}
	} else {
		if (mat < 31020) { // Glass, Glass Pane, Beacon (31008, 31012, 31016)
			if (color1.a > 0.5) color1 = vec4(0.0, 0.0, 0.0, 1.0);
			else color1 = vec4(vec3(0.25 * (1.0 - GLASS_OPACITY)), 1.0);
			color2.rgb = vec3(0.3);
		} else {
			//if (mat == 31020) { //

			//} /*else : Upper limit*/
		}
	}

    gl_FragData[0] = color1; // Shadow Color
    gl_FragData[1] = color2; // Light Shaft Color
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out int mat;

out vec2 texCoord;

flat out vec3 sunVec, upVec;

out vec4 position;
flat out vec4 glColor;

//Uniforms//
uniform mat4 shadowProjection, shadowProjectionInverse;
uniform mat4 shadowModelView, shadowModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#if defined WAVING_ANYTHING_TERRAIN || defined WAVING_WATER_VERTEX
	uniform float frameTimeCounter;

	uniform vec3 cameraPosition;
#endif

//Attributes//
attribute vec4 mc_Entity;

#if defined PERPENDICULAR_TWEAKS || defined WAVING_ANYTHING_TERRAIN || defined WAVING_WATER_VERTEX
	attribute vec4 mc_midTexCoord;
#endif

//Common Variables//
#if (defined WAVING_ANYTHING_TERRAIN || defined WAVING_WATER_VERTEX) && defined NO_WAVING_INDOORS
	vec2 lmCoord = vec2(0.0);
#endif

//Common Functions//

//Includes//
#include "/lib/util/spaceConversion.glsl"

#if defined WAVING_ANYTHING_TERRAIN || defined WAVING_WATER_VERTEX
	#include "/lib/materials/wavingBlocks.glsl"
#endif

//Program//
void main() {
	texCoord = gl_MultiTexCoord0.xy;
	glColor = gl_Color;

	sunVec = GetSunVector();
	upVec = normalize(gbufferModelView[1].xyz);

	mat = int(mc_Entity.x + 0.5);

	position = gl_Vertex;

	#if defined WAVING_ANYTHING_TERRAIN || defined WAVING_WATER_VERTEX
		#ifdef NO_WAVING_INDOORS
			lmCoord = GetLightMapCoordinates();
		#endif

		DoWave(position.xyz, mat);
	#endif

	#ifdef PERPENDICULAR_TWEAKS
		if (mat == 10004 || mat == 10016) {
			vec2 midCoord = (gl_TextureMatrix[0] * mc_midTexCoord).st;
			vec2 texMinMidCoord = texCoord - midCoord;
			if (texMinMidCoord.y < 0.0) {
				vec3 normal = gl_NormalMatrix * gl_Normal;
				position.xyz += normal * 0.35;
			}
		}
	#endif

	gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * position;

	float lVertexPos = sqrt(gl_Position.x * gl_Position.x + gl_Position.y * gl_Position.y);
	float distortFactor = lVertexPos * shadowMapBias + (1.0 - shadowMapBias);
	gl_Position.xy *= 1.0 / distortFactor;
	gl_Position.z = gl_Position.z * 0.2;
}

#endif
