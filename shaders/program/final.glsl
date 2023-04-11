////////////////////////////////////////
// Complementary Reimagined by EminGT //
////////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

//Uniforms//
uniform float viewWidth, viewHeight;

uniform sampler2D colortex3;

#ifdef UNDERWATER_DISTORTION
	uniform int isEyeInWater;

	uniform float frameTimeCounter;
#endif

//Pipeline Constants//
#include "/lib/misc/pipelineSettings.glsl"

//Common Variables//

//Common Functions//
#if IMAGE_SHARPENING > 0
	vec2 viewD = 1.0 / vec2(viewWidth, viewHeight);

	vec2 sharpenOffsets[4] = vec2[4](
		vec2( viewD.x,  0.0),
		vec2( 0.0,  viewD.x),
		vec2(-viewD.x,  0.0),
		vec2( 0.0, -viewD.x)
	);

	void SharpenImage(inout vec3 color, vec2 texCoordM) {
		float mult = 0.0125 * IMAGE_SHARPENING;
		color *= 1.0 + 0.05 * IMAGE_SHARPENING;

		for (int i = 0; i < 4; i++) {
			color -= texture2D(colortex3, texCoordM + sharpenOffsets[i]).rgb * mult;
		}
	}
#endif

//Includes//
#include "/lib/util/text.glsl"

//Program//
void main() {
	vec2 texCoordM = texCoord;

	#ifdef UNDERWATER_DISTORTION
		if (isEyeInWater == 1) texCoordM += 0.0007 * sin((texCoord.x + texCoord.y) * 25.0 + frameTimeCounter * 3.0);
	#endif

	vec3 color = texture2D(colortex3, texCoordM).rgb;

	#if IMAGE_SHARPENING > 0
		SharpenImage(color, texCoordM);
	#endif
	
	if (MC_SHADOW_QUALITY != 1.0) {
		
		const float textlength = 45 * 6.0 + 4.0;
		
		float minimumSize = min(viewHeight * 1.77,viewWidth);
			
		float mult = minimumSize/textlength;
		
		float offset = viewHeight/mult;
		
		beginText(ivec2(gl_FragCoord.xy/mult), ivec2((viewWidth/mult-textlength) * 0.5 + 2.0, viewHeight/mult * 0.5 + 8.0));
		printString((_p,_l,_e,_a,_s,_e,_space,_s,_e,_t,_space,_y,_o,_u,_r,_space,_O,_p,_t,_i,_f,_i,_n,_e,_space,_S,_h,_a,_d,_o,_w,_space,_Q,_u,_a,_l,_i,_t,_y,_space,_t,_o,_space,_1,_x));
		printLine();
		printString((_space,_space,_space,_space,_space,_space,_space,_space,_space,_space,_space,_space,_o,_r,_space,_s,_h,_a,_d,_o,_w,_s,_space,_a,_r,_e,_space,_b,_r,_o,_k,_e,_n,_space,_space,_space,_space,_space,_space,_space,_space,_space,_space,_space,_space));
		endText(color);
	}

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

//Uniforms//

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
	gl_Position = ftransform();
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
