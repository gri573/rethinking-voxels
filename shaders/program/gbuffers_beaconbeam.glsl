////////////////////////////////////////
// Complementary Reimagined by EminGT //
////////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

in vec2 texCoord;

in vec4 glColor;

//Uniforms//
uniform float viewWidth, viewHeight;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform sampler2D tex;

//Pipeline Constants//

//Common Variables//

//Common Functions//

//Includes//
#include "/lib/util/spaceConversion.glsl"

#ifdef TAA
	#include "/lib/util/jitter.glsl"
#endif

//Program//
void main() {
	vec4 color = texture2D(tex, texCoord);
	vec3 colorP = color.rgb;
	color *= glColor;

	vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
	#ifdef TAA
		vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
	#else
		vec3 viewPos = ScreenToView(screenPos);
	#endif
	float lViewPos = length(viewPos);

	#ifdef IPBR
		float emission = dot(colorP, colorP);

		if (color.a < 0.5) {
			color.a = 0.101;
			emission = pow2(pow2(emission)) * 0.1;
		}

		color.rgb *= color.rgb * emission * 1.75;
		color.rgb += emission * 0.05;
	#else
		color.rgb *= color.rgb * 4.0;
	#endif

	color.rgb *= 0.5 + 0.5 * exp(- lViewPos * 0.04);

    /* DRAWBUFFERS:01 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(0.0, 0.0, 0.0, 1.0);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;

out vec4 glColor;

//Uniforms//
#ifdef TAA
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
	gl_Position = ftransform();
	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif

	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	glColor = gl_Color;
}

#endif
